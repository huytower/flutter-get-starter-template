// Enforces the import boundaries of AGENTS.md (rules 2, 3, 4, 5, 10, 22) and of
// the flutter-core-sdk skill, so they do not depend on anyone re-reading docs.
//
// Run from the repo root: `melos run check:imports`
// (or `dart scripts/check_imports.dart`). Exits 1 and lists every violation
// as `path:line [rule] message`. Generated files are skipped.
//
// Legacy debt of the `feature-controller` and `di-composition-root` rules is
// frozen per file in `scripts/check_imports_baseline.txt`: a file may keep (not
// add to) its recorded count, and an entry that went down must be lowered, so
// the baseline only ever shrinks. After paying debt off, run
// `dart scripts/check_imports.dart --write-baseline` and commit the smaller file.
//
// Uses dart:io only, so it runs the same on Windows, macOS and CI.

import 'dart:io';

/// Rules whose existing violations are tracked in the baseline file.
const Set<String> _baselinedRules = {
  'feature-controller',
  'di-composition-root',
};

const String _baselinePath = 'scripts/check_imports_baseline.txt';

/// The one file allowed to import dart:developer: the `.Log()` extension.
const String _logImplementation =
    'shared/cc_core_sdk/cc_sdk/lib/src/core/extensions/common/cc_logger_extension.dart';

/// A feature's screen controller / Bloc / Cubit (rule 4: never imported by
/// another feature).
final RegExp _controllerFile = RegExp(
  r'/features/[^/]+/presentation/.*_(controller|bloc|cubit)\.dart$',
);

/// The feature a file belongs to (top folder under lib/features/), for the
/// packages that hold features.
final RegExp _featurePath = RegExp(
  r'^(modules/domain_features|shared/cc_micro_features)/lib/(?:features/([^/]+)/)?',
);

/// `getIt<X>()`, `getIt.get<X>()`, `getIt(...)` or `GetIt.instance`.
final RegExp _getItUse = RegExp(
  r'\bgetIt\s*(?:<\s*(\w+)|\.(?:get|call)\s*<\s*(\w+)|\.\w+|\()|\bGetIt\.instance\b',
);

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
  'cc_sdk_catcher': 'shared/cc_core_sdk/cc_sdk_catcher',
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
  'cc_sdk_catcher',
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
/// (cc_sdk_firebase, cc_sdk_catcher, cc_sdk_slack, cc_sdk_device, cc_sdk_phone),
/// not the core.
final RegExp _vendorPackage = RegExp(
  r'^(firebase_[a-z_]+|cloud_firestore|google_mlkit_[a-z_]+|geolocator|'
  r'geocoding|speech_to_text|phone_numbers_parser|permission_handler|'
  r'image_picker|google_sign_in|sign_in_with_apple|flutter_dotenv|catcher_2)$',
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

/// Known package cycles (AGENTS.md rule 2): the back-edge of each cycle, with
/// the only URIs it may import. Empty since `DomainUserEntity` moved into
/// app_config — every edge between our packages must form a DAG. Keep it
/// empty; never add to it.
const Map<(String, String), Set<String>> _knownBackEdges = {};

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

void main(List<String> args) {
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

  if (args.contains('--write-baseline')) {
    _writeBaseline(violations);
    return;
  }
  final frozen = _applyBaseline(violations);

  if (violations.isEmpty) {
    stdout.writeln(
      'check:imports: $files files, no violations '
      '($frozen legacy violation(s) frozen in $_baselinePath).',
    );
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

  if (!isTest) {
    yield* _checkFeatureControllers(path, source);
    yield* _checkComposition(owner, path, source);
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

  // Rule 15: logging goes through `.Log()`; only its implementation may use
  // dart:developer (`print` is the analyzer's avoid_print lint).
  if (uri == 'dart:developer' && !isTest && path != _logImplementation) {
    yield _Violation(
      path,
      line,
      'no-developer-log',
      'log through the `.Log()` extension of cc_sdk, not dart:developer',
    );
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
            'package (cc_sdk_firebase / cc_sdk_catcher / cc_sdk_slack / cc_sdk_device / cc_sdk_phone)',
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

/// Rule 4: a feature (or `core/`) never uses another feature's controller,
/// Bloc or Cubit, whether it imports the file directly (by package or relative
/// path) or through a barrel that re-exports it. The bridge, the orchestrator,
/// is the one place allowed to.
Iterable<_Violation> _checkFeatureControllers(
  String path,
  String source,
) sync* {
  final own = _featurePath.firstMatch(path);
  if (own == null) return;
  final ownFeature = own.group(2); // null for core/ and the barrels.

  for (final match in _directive.allMatches(source)) {
    if (match.group(1) != 'import') continue;
    final uri = _literal
        .allMatches(match.group(2)!)
        .map((m) => m.group(1)!)
        .join();
    final target = _resolve(path, uri);
    if (target == null) continue;
    final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;

    for (final controller in _controllersExportedBy(target)) {
      final feature = _featurePath.firstMatch(controller)?.group(2);
      if (feature == null || feature == ownFeature) continue;
      final name = _className(controller);
      final direct = controller == target;
      if (!direct && !RegExp('\\b$name\\b').hasMatch(source)) continue;
      yield _Violation(
        path,
        line,
        'feature-controller',
        '$name belongs to feature "$feature"; reach it through a *Provider '
            'contract (core/contracts/) implemented in modules/bridge',
      );
    }
  }
}

/// AGENTS.md section IV.2: `getIt` only at the composition root, which is a
/// package's `core/di/`, the App Shell, a page, or an entry point resolving
/// the controller / Bloc / Cubit it creates (`getIt<XController>()`).
Iterable<_Violation> _checkComposition(
  String owner,
  String path,
  String source,
) sync* {
  if (owner == 'mobile_flutter_template' ||
      path.contains('/core/di/') ||
      path.contains('/presentation/pages/') ||
      path.endsWith('_page.dart')) {
    return;
  }
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final code = lines[i].trimLeft();
    if (code.startsWith('//') || code.startsWith('*')) continue;
    for (final hit in _getItUse.allMatches(lines[i])) {
      final type = hit.group(1) ?? hit.group(2);
      // The controller the entry point creates, also as a generic page base's
      // type parameter (`getIt<T>()` in CcGetView).
      if (type != null &&
          RegExp(r'(Controller|Bloc|Cubit)$|^[A-Z]$').hasMatch(type)) {
        continue;
      }
      yield _Violation(
        path,
        i + 1,
        'di-composition-root',
        '`${hit.group(0)}`: take it through the constructor; getIt belongs '
            'in core/di/, a page, or the entry point creating its controller',
      );
    }
  }
}

/// The repo-relative path [uri] points to, for our packages and relative
/// URIs; null for anything else.
String? _resolve(String from, String uri) {
  if (uri.startsWith('dart:')) return null;
  if (uri.startsWith('package:')) {
    final slash = uri.indexOf('/');
    final folder = _packages[uri.substring(8, slash)];
    if (folder == null) return null;
    final base = folder == '.' ? 'lib' : '$folder/lib';
    return '$base/${uri.substring(slash + 1)}';
  }
  final parts = from.split('/')..removeLast();
  for (final part in uri.split('/')) {
    if (part == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else if (part != '.') {
      parts.add(part);
    }
  }
  return parts.join('/');
}

final Map<String, Set<String>> _exportCache = {};

/// Controller files reachable from [path]: itself, or through its `export`
/// directives (followed transitively).
Set<String> _controllersExportedBy(String path) {
  final cached = _exportCache[path];
  if (cached != null) return cached;
  final found = _exportCache[path] = <String>{};
  if (_controllerFile.hasMatch(path)) return found..add(path);

  final file = File(path);
  if (!file.existsSync()) return found;
  final source = file.readAsStringSync();
  for (final match in _directive.allMatches(source)) {
    if (match.group(1) != 'export') continue;
    final uri = _literal
        .allMatches(match.group(2)!)
        .map((m) => m.group(1)!)
        .join();
    final target = _resolve(path, uri);
    if (target != null) found.addAll(_controllersExportedBy(target));
  }
  return found;
}

/// `budget_limit_controller.dart` -> `BudgetLimitController`.
String _className(String path) => path
    .split('/')
    .last
    .replaceFirst('.dart', '')
    .split('_')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
    .join();

/// `rule path` -> number of violations, for the baselined rules.
Map<String, int> _countDebt(List<_Violation> violations) {
  final counts = <String, int>{};
  for (final v in violations.where((v) => _baselinedRules.contains(v.rule))) {
    final key = '${v.rule} ${v.path}';
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

void _writeBaseline(List<_Violation> violations) {
  final counts = _countDebt(violations);
  final keys = counts.keys.toList()..sort();
  File(_baselinePath).writeAsStringSync(
    '# Legacy violations of check_imports.dart, frozen per file. Format:\n'
    '# <rule> <path> <count>. Only ever lower these numbers or delete lines;\n'
    '# a new violation is fixed, never added here. See AGENTS.md section VI.\n'
    '${keys.map((k) => '$k ${counts[k]}').join('\n')}\n',
  );
  stdout.writeln(
    'check:imports: wrote ${keys.length} baseline entries '
    '(${counts.values.fold(0, (a, b) => a + b)} violations) to $_baselinePath.',
  );
}

/// Drops baselined violations that stay within their recorded count from
/// [violations]; adds a `baseline` violation for every entry that is now too
/// high (stale). Returns how many violations the baseline absorbed.
int _applyBaseline(List<_Violation> violations) {
  final baseline = <String, int>{};
  final file = File(_baselinePath);
  if (file.existsSync()) {
    for (final raw in file.readAsLinesSync()) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final cut = line.lastIndexOf(' ');
      baseline[line.substring(0, cut)] = int.parse(line.substring(cut + 1));
    }
  }

  final counts = _countDebt(violations);
  var frozen = 0;
  violations.removeWhere((v) {
    if (!_baselinedRules.contains(v.rule)) return false;
    final key = '${v.rule} ${v.path}';
    final allowed = baseline[key] ?? 0;
    if (counts[key]! > allowed) return false;
    frozen++;
    return true;
  });

  for (final MapEntry(key: key, value: allowed) in baseline.entries) {
    final now = counts[key] ?? 0;
    if (now >= allowed) continue;
    final space = key.indexOf(' ');
    violations.add(
      _Violation(
        key.substring(space + 1),
        1,
        'baseline',
        '${key.substring(0, space)} debt went down from $allowed to $now: '
            'run `dart scripts/check_imports.dart --write-baseline`',
      ),
    );
  }
  return frozen;
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
