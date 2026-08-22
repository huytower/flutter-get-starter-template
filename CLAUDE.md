# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Flutter "Hybrid-Modular Super App" starter template built on Clean Architecture + SOLID, organized as a Melos
workspace of independent packages instead of one monolithic app. The full architectural rulebook lives in
`docs/AI_CONTEXT.md` — read it before making structural changes; this file summarizes what's needed for day-to-day
work and defers to it for anything not covered here. `docs/onboarding.md` and `docs/CONTRIBUTING.md` cover
new-feature scaffolding steps in more detail than reproduced here.

## Commands

```bash
melos bootstrap              # bootstrap the workspace (run after pulling / editing pubspec.yaml)
melos run setup:firebase     # generate local Firebase config files from templates (needed before first run)
melos run gen                # dart run build_runner build --delete-conflicting-outputs, across all packages
melos run rebuild             # flutter clean && flutter pub get && build_runner build, across all packages
melos run analyze            # flutter analyze, across all packages
melos run test                # flutter test, across all packages
```

- **Workspace scripts are defined once**, in root `pubspec.yaml` under `melos.scripts` — melos 7.8.1 reads scripts
  from `pubspec.yaml`, not `melos.yaml`. Never add a duplicate `scripts:` block to `melos.yaml`.
- To run/generate for a single package, `cd` into it and run the plain `flutter`/`dart` command (e.g.
  `cd modules/domain_features && flutter analyze`) rather than melos, when you only touched that package.
- Run a single test file: `flutter test path/to/foo_test.dart` (from the package root that owns it).
- Run the app: `flutter run -d <device> --flavor uat -t lib/main_uat.dart` (flavors: `uat`, `prod`; entry points
  `lib/main_uat.dart`, `lib/main_prod.dart`, both delegating to `lib/main.dart` via `EnvironmentRunner`).
- Firebase config is git-ignored; `melos run setup:firebase` (wraps `scripts/setup_firebase_configs.sh`) copies
  `.template` files into `android/app/src/{flavor}/google-services.json` and
  `ios/Firebase/{flavor}/GoogleService-Info.plist`.
- CI (`.github/workflows/firebase-app-distribution.yml`) is currently fully disabled (`if: false` on every job,
  triggers removed) — treat `melos run analyze`/`melos run test` locally as the only quality gate until it's
  re-enabled.

## Workspace layout

```
lib/                              # App Shell — pure orchestrator only (DI wiring, routing, boot sequence).
                                   # MUST NOT contain business logic or feature-specific UI.
modules/
  domain_features/lib/features/   # App-specific business verticals (wallet, transaction, budget, loan,
                                   # reconciliation, report, user_level, category, comment, profile, ...)
  data_config/                    # App-specific data implementations; implements Repository interfaces
                                   # that domain_features/cc_micro_features define
  app_config/                     # Env management, storage, DI discovery
  theme/                          # SSOT for colors/typography (PrjColors, CcTextStyle, CcThemes)
  message/                        # SSOT for i18n strings (CcLocaleKeys)
shared/
  cc_micro_features/lib/features/ # Project-blind, reusable-across-apps verticals (auth, biometric,
                                   # crash_log, messaging, splash, web)
  cc_core_sdk/                    # GIT SUBMODULE (huytower/cc_core_sdk) — universal engine:
    cc_sdk/                       #   network, failures, logging (.Log()), ccGson serialization
    cc_sdk_ui/                    #   design system / widget catalog (CcContextExtension)
    cc_mixin/                     #   reusable behavior mixins (pagination, back-button, etc.)
    cc_sdk_data/                  #   core data entities/models
cc_bridge/                        # Root-level cross-module contracts (*Coordinator / *Contract / *Provider)
```

`shared/cc_core_sdk` is a **git submodule**; commits there don't land by editing files in this repo — they must be
committed and pushed inside the submodule itself, then the parent repo's submodule pointer updated separately.

### Dependency direction (STRICT — this is the whole point of the template)

- `cc_micro_features` and `domain_features` **must not** import from `lib/` (App Shell) or `modules/data_config`.
- `cc_micro_features` must not import from `domain_features`.
- Every feature defines its own `Repository` interface in its own `domain/` layer; `lib/` or `modules/data_config`
  implements it and injects the impl via DI. Never import a concrete repository impl across a module boundary.
- Within a single feature, `domain/` and `data/` must never import from `presentation/` (no Bloc `Event`/`State`,
  `Obx`, `GetxController`, or widgets leaking into domain/data). Cross-layer streams use domain types (e.g. a sealed
  `*Status`/`*Entity`), not presentation event classes.
- `cc_core_sdk` (`cc_sdk`, `cc_sdk_ui`, `cc_mixin`) and `cc_bridge` must stay state-management agnostic — no
  Bloc/GetX reactive state. The one documented exception: `cc_sdk_ui` uses `get` for lightweight navigation helpers
  only (`Get.context!`, `Get.dialog`, `Get.back()`), never `GetxController`/`Obx`.
- Presentation layers are free to use Bloc or GetX; the project deliberately supports both, chosen per feature.

If you're not sure a change belongs where you're about to put it, that uncertainty is a signal — check
`docs/AI_CONTEXT.md` rule numbers 1-4 before proceeding.

## DI convention (get_it + injectable)

Every package/feature that needs DI exposes `lib/core/di/di.dart` with a `void initMicroPackage()` function
annotated `@InjectableInit.microPackage()`; generated output is `di.module.dart` (or `di.config.dart` at the app
shell level). The service locator is always named `getIt`. The App Shell consolidates everything in
`lib/core/di/di.dart` via `@InjectableInit` with `externalPackageModulesBefore`. Heavy/infra services **must** be
`@lazySingleton`, not `@singleton` — eager singletons break the boot-time budget below.

New reusable feature → add it under `shared/cc_micro_features/lib/features/{name}/` (or
`modules/domain_features/lib/features/{name}/` if app-specific) with `core/di`, `data/`, `domain/`,
`presentation/` subfolders, then export it from `export_micro_features.dart` / `export_domain_features.dart`.

## Boot sequence (`lib/main.dart`) — don't break this

Startup target is **< 2 seconds**. The sequence is intentionally strict:
1. `await initEnv()` first and alone (DI/feature flags depend on env being loaded).
2. `await Future.wait([Firebase.initializeApp(), initializeDependencies(), _initHive(), CcLocalization.initialize()])`
   — these four run in parallel, not sequentially.
3. `CcAppCheckHelper.initialize()` and other non-critical services fire-and-forget, non-blocking.
4. UI launch.
Any new startup dependency should go into step 2's parallel block only if it's truly required before first frame;
otherwise defer it to step 3 or lazily via `NavigationLogicMixin` in the nav bar shell.

## Design system & responsiveness (non-negotiable in UI code)

- Colors: `CcBaseColors` → `PrjColors` → `context.ccColorScheme`. Never hardcode hex or use `Colors.*`.
- Typography: `context.ccTextTheme` (Plus Jakarta Sans). Never hardcode font size/weight/family.
- Spacing: use `CcSpace*` (XS=4, SM=8, MD=12, LG=16, XL=24) instead of raw `SizedBox(height: context.respDim(N))`
  for token values; raw `SizedBox` is fine only for non-token gaps or sizing shapes/icons/charts.
- Dimensions: `context.respPadding()`, `context.respFontSize()`, `context.respDim()`; layouts via
  `CcResponsiveContainer`/`CcResponsiveFlex`. Breakpoints: small-mobile <360, mobile 360-600, tablet 600-900,
  desktop >900. Verify both portrait and landscape.
- Strings: `el.tr(CcLocaleKeys.key)`, never hardcoded. New strings require all three in sync: `en.json`, `vi.json`
  (both under `modules/message/assets/translations/`), and `CcLocaleKeys` constant + `CodegenLoader` entry in
  `modules/message/lib/cc_locale_keys.dart`. This trio has no build step enforcing sync — treat drift as a bug.
- Prefer extending `cc_core_sdk/cc_sdk_ui` components over hand-rolling new widgets.

## Naming & style conventions

- Suffix-first, `lower_snake_case` files: `*_entity.dart`, `*_usecase.dart`, `*_repository.dart` /
  `*_repository_impl.dart`, `*_model.dart`, `*_page.dart`, `*_bloc.dart`/`*_cubit.dart`,
  `*_state.dart`/`*_event.dart`.
- Import order: Flutter/Dart → external packages → project modules → local relative. Enforced by
  `directives_ordering: error` in `analysis_options.yaml`; fix violations with `dart fix --apply`, don't disable
  the rule.
- Prefer centralized package exports (`package:cc_micro_features/export_micro_features.dart`) over reaching into a
  specific file inside another module; never import both the export and a specific file from the same module.
- All UseCases/Repositories return `Result<T, CcFailure>` (the `multiple_result` package; `CcFailure` lives in
  `cc_sdk`).
- Logging: the `.Log()` extension from `cc_sdk` only — never `print()` or `developer.log()` in production code.
- Keep files ~200-300 lines; split large `build()` methods into `_buildHeader`/`_buildListItem`/etc. helpers rather
  than one large method. `const` everything that can be const.
- `analysis_options.yaml` disables many default lints (see the file for the full list) — don't re-enable them
  piecemeal without checking why they were turned off first.

<!-- codegraph:start -->
# CodeGraph — Code Intelligence

This project is indexed by CodeGraph (a `.codegraph/` directory exists at the repo root). Reach for it BEFORE
grep/find or reading files when you need to understand or locate code.

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant
  symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow.
  Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load
  it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

The index lags writes by ~1s through the file watcher; no manual re-index step is normally needed.
<!-- codegraph:end -->
