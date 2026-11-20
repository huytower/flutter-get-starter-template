// Enforces the import boundaries of AGENTS.md (rules 2, 3, 4, 5, 10, 22) and of
// the flutter-core-sdk skill, so they do not depend on anyone re-reading docs.
//
// Run from the repo root: `melos run check:imports`
// (or `dart scripts/check_imports.dart`). Exits 1 and lists every violation
// as `path:line [rule] message`. Generated files are skipped.
//
// Uses dart:io only, so it runs the same on Windows, macOS and CI.

import 'dart:io';

/// Package name -> folder, for every package the checks know about.
const Map<String, String> _packages = {
  'mobile_flutter_template': '.',
  'app_config': 'modules/app_config',
  'bridge': 'modules/bridge',
  'data_config': 'modules/data_config',
  'domain_features': 'modules/domain_features',
  'message': 'modules/message',
  'theme': 'modules/theme',
  'cc_bridge': 'cc_bridge',
  'cc_micro_features': 'shared/cc_micro_features',
  'cc_sdk': 'shared/cc_core_sdk/cc_sdk',
  'cc_sdk_ui': 'shared/cc_core_sdk/cc_sdk_ui',
  'cc_sdk_data': 'shared/cc_core_sdk/cc_sdk_data',
  'cc_mixin': 'shared/cc_core_sdk/cc_mixin',
  'cc_sdk_firebase': 'shared/cc_core_sdk/cc_sdk_firebase',
  'cc_sdk_slack': 'shared/cc_core_sdk/cc_sdk_slack',
  'cc_sdk_device': 'shared/cc_core_sdk/cc_sdk_device',
  'cc_sdk_phone': 'shared/cc_core_sdk/cc_sdk_phone',
};

/// The universal engine (git submodule): core ring + capability packages.
const Set<String> _sdk = {
  'cc_sdk',
  'cc_sdk_ui',
  'cc_sdk_data',
  'cc_mixin',
  'cc_sdk_firebase',
  'cc_sdk_slack',
  'cc_sdk_device',
  'cc_sdk_phone',
};

/// The SDK core ring: no vendor SDK, no reactive state management.
const Set<String> _sdkCore = {'cc_sdk', 'cc_sdk_ui', 'cc_sdk_data', 'cc_mixin'};

/// App-specific packages that project-blind code must never import.
const Set<String> _appPackages = {
  'mobile_flutter_template',
  'app_config',
  'bridge',
  'data_config',
  'domain_features',
  'message',
  'theme',
};

/// Vendor / heavy plugin packages that belong in a capability package
/// (cc_sdk_firebase, cc_sdk_slack, cc_sdk_device, cc_sdk_phone), not the core.
final RegExp _vendorPackage = RegExp(
  r'^(firebase_[a-z_]+|cloud_firestore|google_mlkit_[a-z_]+|geolocator|'
  r'geocoding|speech_to_text|phone_numbers_parser|permission_handler|'
  r'image_picker|google_sign_in|sign_in_with_apple|flutter_dotenv)$',
);

/// Reactive GetX / Bloc usage that the state-agnostic core must not contain.
final RegExp _reactiveState = RegExp(
  r'\b(GetxController|GetxService|GetBuilder|GetX<|Obx\(|Rx[A-Z]\w*<|BlocBuilder|BlocProvider)\b|\.obs\b',
);

/// `import`/`export`/`part` with one or more adjacent string literals (a URI
/// may be split across lines, e.g. `'package:a/b' '.dart'`).
final RegExp _directive = RegExp(
  r'''^[ \t]*(import|export|part)\s+((?:'[^'\n]*'\s*|"[^"\n]*"\s*)+)''',
  multiLine: true,
);
final RegExp _literal = RegExp(r'''['"]([^'"\n]*)['"]''');

/// What the App Shell (root `lib/`) may import from domain_features: wiring
/// only (DI module, route classes, generated Hive registrar). Every call into a
/// feature goes through `package:bridge/export_bridge.dart` (AGENTS.md rule 4).
const Set<String> _shellWiringIntoFeatures = {
  'core/di/di.module.dart',
  'core/navigation/domain_router.gr.dart',
  'hive_registrar.g.dart',
};

/// Known package cycles (AGENTS.md rule 2, tech debt): the back-edge of each
/// cycle, with the only URIs it may import. Every other edge between our
/// packages must form a DAG, and these back-edges must not grow — import a
/// new file across one and `package-cycle` fails. Shrink this list as the
/// cycles are broken; never add to it.
const Map<(String, String), Set<String>> _knownBackEdges = {
  ('app_config', 'data_config'): {
    'package:data_config/data/adapters/domain_user_entity_adapter.dart',
    'package:data_config/data/converters/domain_user_entity_converter.dart',
    'package:data_config/domain/entities/auth/domain_user_entity.dart',
  },
};

/// One `lib/` import from one of our packages into another.
class _Edge {
  _Edge(this.path, this.line, this.uri);
  final String path;
  final int line;
  final String uri;
}

/// (from, to) -> every lib/ import that creates that package edge.
final Map<(String, String), List<_Edge>> _edges = {};

final RegExp _generated = RegExp(
  r'\.(g|module|config|gr|freezed|mocks)\.dart$',
);

class _Violation {
  _Violation(this.path, this.line, this.rule, this.message);
  final String path;
  final int line;
  final String rule;
  final String message;

  @override
  String toString() => '$path:$line [$rule] $message';
}

void main() {
  final root = Directory.current;
  if (!File('${root.path}/melos.yaml').existsSync()) {
    stderr.writeln('Run from the repository root (where melos.yaml is).');
    exit(2);
  }

  final violations = <_Violation>[];
  var files = 0;
  for (final MapEntry(key: owner, value: folder) in _packages.entries) {
    for (final sub in ['lib', 'test']) {
      final dir = Directory('$folder/$sub');
      if (!dir.existsSync()) continue;
      for (final file in dir.listSync(recursive: true).whereType<File>()) {
        final path = file.path.replaceAll(r'\', '/');
        if (!path.endsWith('.dart') || _generated.hasMatch(path)) continue;
        if (path.contains('/.dart_tool/') || path.contains('/build/')) continue;
        // The root package's lib/ folder also contains modules/ and shared/
        // only by path prefix; skip files that belong to another package.
        if (owner == 'mobile_flutter_template' && !path.startsWith('./$sub/')) {
          continue;
        }
        files++;
        violations.addAll(_check(owner, path.replaceFirst('./', ''), file));
      }
    }
  }

  violations.addAll(_checkCycles());

  if (violations.isEmpty) {
    stdout.writeln('check:imports: $files files, no violations.');
    return;
  }
  violations.sort((a, b) => a.toString().compareTo(b.toString()));
  violations.forEach(stdout.writeln);
  stdout.writeln(
    '\ncheck:imports: ${violations.length} violation(s) in $files files. '
    'See AGENTS.md "VI. Enforcement".',
  );
  exit(1);
}

Iterable<_Violation> _check(String owner, String path, File file) sync* {
  final source = file.readAsStringSync();
  final isTest = path.contains('/test/') || path.startsWith('test/');

  // Cross-module coordinators are implemented in one place, the bridge.
  if (path.endsWith('_coordinator_impl.dart') && owner != 'bridge') {
    yield _Violation(
      path,
      1,
      'coordinator-home',
      'coordinator implementations live in modules/bridge/lib/src/coordinators/',
    );
  }

  for (final match in _directive.allMatches(source)) {
    final uri = _literal
        .allMatches(match.group(2)!)
        .map((m) => m.group(1)!)
        .join();
    final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
    yield* _checkUri(owner, path, line, uri, isTest);
  }

  if (_sdkCore.contains(owner) || owner == 'cc_bridge') {
    final lines = source.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final code = lines[i].trimLeft();
      if (code.startsWith('//') || code.startsWith('*')) continue;
      final hit = _reactiveState.firstMatch(lines[i]);
      if (hit != null) {
        yield _Violation(
          path,
          i + 1,
          'state-agnostic-core',
          '`${hit.group(0)}`: no reactive GetX / Bloc state in $owner',
        );
      }
    }
  }
}

Iterable<_Violation> _checkUri(
  String owner,
  String path,
  int line,
  String uri,
  bool isTest,
) sync* {
  final pkg = uri.startsWith('package:')
      ? uri.substring(8, uri.contains('/') ? uri.indexOf('/') : uri.length)
      : null;
  final rest = pkg == null ? '' : uri.substring(8 + pkg.length + 1);

  if (pkg != null && pkg != owner && _packages.containsKey(pkg) && !isTest) {
    _edges.putIfAbsent((owner, pkg), () => []).add(_Edge(path, line, uri));
  }

  if (pkg == 'flutter_dotenv') {
    yield _Violation(
      path,
      line,
      'no-dotenv',
      'settings come from --dart-define via PrjEnv; do not use flutter_dotenv',
    );
  }

  // Our own packages only: third-party `src/` imports are the analyzer's
  // `implementation_imports` lint (a test may need one to fake a plugin).
  if (pkg != null &&
      pkg != owner &&
      _packages.containsKey(pkg) &&
      rest.startsWith('src/')) {
    yield _Violation(
      path,
      line,
      'private-src',
      '$uri is private to $pkg; import its barrel',
    );
  } else if (pkg != null &&
      pkg != owner &&
      (_sdk.contains(pkg) || pkg == 'bridge') &&
      !RegExp(r'^export_[a-z_]+\.dart$').hasMatch(rest) &&
      !rest.startsWith('core/di/')) {
    yield _Violation(
      path,
      line,
      pkg == 'bridge' ? 'bridge-barrel' : 'sdk-barrel',
      '$uri: import $pkg through its export_*.dart barrel',
    );
  }

  // The bridge barrel publishes contracts only; implementations stay behind DI.
  if (path == 'modules/bridge/lib/export_bridge.dart' &&
      uri.endsWith('_impl.dart')) {
    yield _Violation(
      path,
      line,
      'bridge-barrel',
      '$uri: export_bridge.dart exports contracts, never an implementation',
    );
  }

  // The App Shell reaches features only through the bridge.
  if (owner == 'mobile_flutter_template' &&
      pkg == 'domain_features' &&
      !_shellWiringIntoFeatures.contains(rest)) {
    yield _Violation(
      path,
      line,
      'shell-via-bridge',
      '$uri: the App Shell calls features through '
          'package:bridge/export_bridge.dart (allowed wiring: '
          '${_shellWiringIntoFeatures.join(', ')})',
    );
  }

  if (_sdkCore.contains(owner) && pkg != null) {
    if (pkg == 'bloc' || pkg == 'flutter_bloc' || pkg == 'get') {
      yield _Violation(path, line, 'state-agnostic-core', '$pkg in $owner');
    }
    if (_vendorPackage.hasMatch(pkg) && !isTest) {
      yield _Violation(
        path,
        line,
        'sdk-core-vendor',
        '$pkg in the core ring: put it behind an interface in a capability '
            'package (cc_sdk_firebase / cc_sdk_slack / cc_sdk_device / cc_sdk_phone)',
      );
    }
  }

  if (owner == 'cc_bridge' && pkg != null) {
    if (pkg == 'bloc' || pkg == 'flutter_bloc' || pkg == 'get') {
      yield _Violation(path, line, 'state-agnostic-core', '$pkg in cc_bridge');
    }
  }

  final projectBlind =
      _sdk.contains(owner) ||
      owner == 'cc_bridge' ||
      owner == 'cc_micro_features';
  if (projectBlind && pkg != null && _appPackages.contains(pkg)) {
    yield _Violation(
      path,
      line,
      'project-blind',
      '$owner must not import app package $pkg',
    );
  }
  if ((_sdk.contains(owner) || owner == 'cc_bridge') &&
      (pkg == 'cc_micro_features' || (pkg == 'cc_bridge' && owner != pkg))) {
    yield _Violation(
      path,
      line,
      'project-blind',
      '$owner must not import $pkg',
    );
  }

  // Layer purity: domain/ and data/ never import a presentation/ layer.
  final layer = RegExp(r'/features/[^/]+/(domain|data)/').firstMatch(path);
  if (layer != null && uri.contains('presentation/')) {
    yield _Violation(
      path,
      line,
      'layer-purity',
      '${layer.group(1)}/ must not import a presentation layer ($uri)',
    );
  }
}

/// Package cycles: with the known back-edges taken out, the graph of lib/
/// imports between our packages must be acyclic, and each known back-edge may
/// only import its listed URIs.
Iterable<_Violation> _checkCycles() sync* {
  for (final MapEntry(key: edge, value: imports) in _edges.entries) {
    final (from, to) = edge;
    final allowed = _knownBackEdges[edge];
    if (allowed != null) {
      for (final i in imports.where((i) => !allowed.contains(i.uri))) {
        yield _Violation(
          i.path,
          i.line,
          'package-cycle',
          '${i.uri} deepens the known $from <-> $to cycle; move the type '
              'into $from (or a lower package) instead',
        );
      }
      continue;
    }
    final back = _path(to, from);
    if (back == null) continue;
    final cycle = [from, ...back].join(' -> ');
    for (final i in imports) {
      yield _Violation(
        i.path,
        i.line,
        'package-cycle',
        '${i.uri} closes a package cycle ($cycle)',
      );
    }
  }
}

/// Shortest package path start -> ... -> goal over the edges that are not
/// known back-edges, or null if goal is unreachable.
List<String>? _path(String start, String goal) {
  final parent = <String, String>{start: start};
  final queue = [start];
  while (queue.isNotEmpty) {
    final node = queue.removeAt(0);
    if (node == goal) {
      final path = [node];
      for (var n = node; n != start; n = parent[n]!) {
        path.insert(0, parent[n]!);
      }
      return path;
    }
    for (final (from, to) in _edges.keys) {
      if (from != node ||
          parent.containsKey(to) ||
          _knownBackEdges.containsKey((from, to))) {
        continue;
      }
      parent[to] = node;
      queue.add(to);
    }
  }
  return null;
}
