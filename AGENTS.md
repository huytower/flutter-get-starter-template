# AGENTS.md

Canonical, tool-agnostic instructions for any AI coding agent (Claude Code, Gemini, GitHub Copilot, Kilo Code,
Devin, or otherwise) working in this repository. This is the single source of truth — `CLAUDE.md`, `GEMINI.md`,
and `.github/copilot-instructions.md` are thin pointers to this file; do not duplicate rules into them.

## What this is

A Flutter "Hybrid-Modular Super App" starter template built on Clean Architecture + SOLID, organized as a Melos
workspace of independent packages instead of one monolithic app. `docs/AI_CONTEXT.md` has the fuller rationale
for *why* the architecture looks this way; this file is the actionable rulebook — read it first, and treat it as
authoritative if the two ever disagree (report the disagreement rather than guessing which is stale).

## Before you start: canonical example, and what NOT to copy

When scaffolding a new feature or screen, base the structure on **`modules/domain_features/lib/features/wallet/`**
— it is the most complete, up-to-date feature and follows every rule below. Do not pattern-match on:

- `modules/domain_features/lib/features/examples/` — tutorial/demo scaffolding (bloc/cubit tutorials), not a
  real feature pattern, even though it is technically live-routed.
- `shared/cc_micro_features/feature_template.md`'s *pre-2026-09 versions* if you're looking at git history/blame
  — it used to show a wrong per-feature `di/{name}_module.dart` pattern that contradicted the real DI convention
  (see below). The current version on disk is correct.
- Any file whose imports, spacing, or DI shape visibly disagree with the rules below — an older file being wrong
  is not evidence the rule is optional, it's a bug to flag or fix, not a pattern to extend.

Two similarly-named features are **not** duplicates — both are real and live:
- `modules/domain_features/lib/features/crashlog/` — app-specific crash-log **upload** logic (data/domain only).
- `shared/cc_micro_features/lib/features/crash_log/` — the reusable crash-log **viewer UI**.

## Commands

```bash
melos bootstrap              # bootstrap the workspace (run after pulling / editing pubspec.yaml)
melos run setup:firebase     # generate local Firebase config files from templates (needed before first run)
melos run gen                # dart run build_runner build --delete-conflicting-outputs, across all packages
melos run rebuild            # flutter clean && flutter pub get && build_runner build, across all packages
melos run analyze            # flutter analyze, across all packages
melos run test                # flutter test, across all packages
melos run check:imports       # import boundaries (section VI), also the first CI quality-gate step
```

- **Workspace scripts are defined once**, in root `pubspec.yaml` under `melos.scripts` — melos 8.10.0 reads
  scripts from `pubspec.yaml`, not `melos.yaml`. Never add a duplicate `scripts:` block to `melos.yaml`.
- To run/generate for a single package, `cd` into it and run the plain `flutter`/`dart` command (e.g.
  `cd modules/domain_features && flutter analyze`) rather than melos, when you only touched that package.
- Run a single test file: `flutter test path/to/foo_test.dart` (from the package root that owns it).
- Run the app: `flutter run -d <device> --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json` (flavor: `prod`; entry point `lib/main_prod.dart` delegating to `lib/main.dart` via `EnvironmentRunner`).
- App settings are `--dart-define`s from `env/prod.json` (git-ignored copy of `env/prod.example.json`; generated in CI
  from GitHub Variables + Secrets, the single source of truth). Only `PrjEnv` (`modules/app_config`) reads them; the
  SDK gets its share via `CcSdkConfig.configure()` in `initEnv()`. No code reads `.env` files or `flutter_dotenv`.
- Firebase config is git-ignored; `melos run setup:firebase` copies `.template` files into
  `android/app/src/{flavor}/google-services.json` and `ios/Firebase/{flavor}/GoogleService-Info.plist`.
- CI (`.github/workflows/firebase-app-distribution.yml`) is **active**. It runs on push/PR to `qltc` (docs-only
  changes are ignored): quality gate (`melos run gen/analyze/test`), then — on push to `qltc` or manual dispatch —
  **a real release**: Android AAB to Google Play alpha, and IPA to TestFlight.
  Pushing to `qltc` therefore publishes builds; don't push without the user's explicit go-ahead. Details in
  `docs/CICD_SETUP.md`.
- **Do not run `flutter build`/`flutter run`/`xcodebuild`/`adb` yourself** unless the user explicitly asks — the
  user tests changes manually. Static checks (`analyze`, `test`) plus clear manual-test steps are the deliverable.

## Workspace layout

```
lib/                              # App Shell — pure orchestrator only (DI wiring, routing, boot sequence).
                                   # MUST NOT contain business logic or feature-specific UI.
modules/
  domain_features/lib/features/   # App-specific business verticals: wallet, transaction, budget_allocation,
                                   # budget_limit, liability, reconciliation, report, category, comment,
                                   # profile (incl. profile/user_level), guideline, notification, firestore
                                   # (sync), crashlog, examples (demo only)
  data_config/                    # App-wide data infrastructure (Dio/Retrofit setup, exchange rates). Implements
                                   # only repository interfaces that live in domain_features/lib/core/ (rule 2)
  app_config/                     # Env management, storage, DI discovery, DomainUserEntity (+ Hive adapter)
  bridge/                         # The App Shell's gateway to features: shell contracts (AppLifecycleProvider,
                                   # MainShellProvider, RegionalSettingsContract), every coordinator impl, and
                                   # the impls of the cross-feature *Provider contracts (see rule 4).
                                   # NOT a duplicate of cc_bridge (which holds project-blind contracts only).
  theme/                          # SSOT for colors/typography (PrjColors, CcTextStyle, CcThemes)
  message/                        # SSOT for i18n strings (CcLocaleKeys)
shared/
  cc_micro_features/lib/features/ # Project-blind, reusable-across-apps verticals (app_update, auth,
                                   # biometric, crash_log, messaging, splash, web)
  cc_core_sdk/                    # GIT SUBMODULE (huytower/cc_core_sdk) — universal engine:
    cc_sdk/                       #   network, failures, logging (.Log()), crash-reporter interface
    cc_sdk_ui/                    #   design system / widget catalog (CcContextExtension) + widget-building mixins
    cc_mixin/                     #   behavior-only mixins (pagination, back-button); depends on cc_sdk_data only
    cc_sdk_data/                  #   core data entities/models
    cc_sdk_firebase/              #   capability ring: Firebase impls of core interfaces (CcAnalytics, ...)
    cc_sdk_catcher/               #   capability ring: uncaught-error handling on catcher_2 (CcCatcherBootstrap)
    cc_sdk_slack/                 #   capability ring: Slack webhook impls (crash alerts, user feedback)
    cc_sdk_device/                #   capability ring: device-plugin impls (location, speech recognition)
    cc_sdk_phone/                 #   capability ring: phone number validation (phone_numbers_parser)
cc_bridge/                        # Root-level cross-module contracts (*Coordinator / *Contract / *Provider)
                                   # (contracts only; the app-level service lives in modules/bridge)
```

`shared/cc_core_sdk` is a **git submodule**; commits there don't land by editing files in this repo — they must
be committed and pushed inside the submodule itself, then the parent repo's submodule pointer updated separately.

**Submodule branch rule (STRICT):** inside `shared/cc_core_sdk`, work only on `main`, or on a short-lived branch
that goes into `main` through a PR on `huytower/cc_core_sdk`. Never move the submodule off `main` on your own:
no `git submodule update`, no `git checkout <commit>` / `--detach`, no switching its branch, unless the user asks.
If the parent branch records a different SDK commit than the one checked out, **report the mismatch** instead of
fixing it. To take a newer SDK: `git -C shared/cc_core_sdk pull` on `main`, then commit the new pointer in the
parent repo. (This checkout sets `submodule.cc_core_sdk.update = none` locally, so `git submodule update` skips it.)

## I. Architectural integrity (the laws)

1. **Hybrid-Modular Super App Design (CRITICAL)** — three layers, strictly separated: App Shell (`lib/`, pure
   orchestrator, no business logic/feature UI), Domain Features (`modules/domain_features/`, app-specific
   verticals), Micro-Features (`shared/cc_micro_features/`, project-blind reusable verticals), Shared Core
   (`shared/cc_core_sdk/`, universal engine), Bridge Layer (`cc_bridge/`, cross-module contracts).
2. **Project-Blind Dependency Rules (STRICT)**:
    - `cc_micro_features` and `domain_features` **must not** import from `lib/` (App Shell) or `modules/data_config`.
    - `cc_micro_features` must not import from `domain_features` or any app module (`modules/*`).
    - **Repositories — where each piece lives:**
      | Piece | Location | Example |
      |---|---|---|
      | Interface owned by one feature | that feature's `domain/repositories/` | `features/transaction/domain/repositories/transaction_repository.dart` |
      | Implementation of it | the **same** feature's `data/repositories/`, annotated `@LazySingleton(as: XRepository)` | `features/transaction/data/repositories/transaction_repository_impl.dart` |
      | Interface for an app-wide concept that no single feature owns | `modules/domain_features/lib/core/` | `ExchangeRateRepository` in `core/exchange_rates/` |
      | Implementation of a `core/` interface | `modules/data_config` | `ExchangeRateRepositoryImpl` |
      | Implementation of a `cc_micro_features` interface that needs app config | App Shell `lib/data/repositories/` | `AppUpdateConfigRepositoryImpl` |
    - Another feature **may** depend on a repository **interface** (e.g. `report` uses `TransactionRepository`):
      import it from the owning feature's `domain/` and inject it as section IV describes.
    - Nothing may import a `*_repository_impl.dart` except its own feature's tests. Only the generated DI file
      (`di.module.dart` / `di.config.dart`) references implementations.
    - Repository interfaces are **not** moved to `core/` just because several features use them — only shared
      *entities* are (`core/domain/entities/`: `TransactionEntity`, `WalletEntity`, `CategoryEntity`,
      `LiabilityEntity`, `UserLevelStatusEntity`).
    - **No package cycles.** Workspace packages form a DAG (`data_config` → `domain_features` → `app_config`;
      `app_config` depends on neither). A new import that adds a back-edge between packages is a bug: move the
      shared type down into the lower package instead. Enforced by `check:imports` (`package-cycle`).
3. **State-Management Agnostic Core (STRICT)**:
    - `cc_core_sdk` (`cc_sdk`, `cc_sdk_ui`, `cc_mixin`) and `cc_bridge` must stay state-management agnostic — no
      Bloc/GetX reactive state.
    - The SDK does not depend on the `get` package at all (dialog and keyboard helpers take a `BuildContext`
      or use `Navigator` / `FocusManager`); don't add it back, not even for navigation helpers.
    - Presentation layers are free to use Bloc or GetX; the project deliberately supports both, chosen per feature.
4. **Interface-Driven Communication (the Bridge)** — all cross-module interactions (navigation, session
   management) are mediated by contracts in `cc_bridge`. Naming: `*Coordinator` (flow/navigation), `*Contract`
   (shared state), `*Provider` (shared logic). Features depend on abstractions, never concrete impls of other
   features. `cc_bridge` holds only project-blind contracts (auth, session) and must not import any app module;
   an app-specific coordinator contract, when one is needed, goes in
   `modules/domain_features/lib/core/navigation/coordinator/`. Two directions, one gateway:
    - **Shell → features:** `lib/` calls features only through `package:bridge/export_bridge.dart`
      (`AppLifecycleProvider` for boot/post-boot work, `MainShellProvider` + `MainTab` for the tab pages, badges
      and refresh, `RegionalSettingsContract` for detected regional settings). Its only direct imports from
      `domain_features` are wiring: `core/di/di.module.dart`, `core/navigation/domain_router.gr.dart`,
      `hive_registrar.g.dart`.
    - **Features → outside their package:** through a `*Coordinator` contract. **Every** coordinator impl lives in
      `modules/bridge/lib/src/coordinators/`; inside `domain_features`, navigate with its own typed routes
      directly. The only string-path hop is `AuthCoordinatorImpl.navigateToDashboard` (`MainNavigationRoute` is
      in `lib/`, which the bridge cannot import).
    - **Feature → feature:** a feature never imports another feature's **controller** (GetX controller / Bloc).
      To refresh another feature's screen, read the user level, or read/advance the onboarding guideline, use the
      typed `*Provider` contracts in `modules/domain_features/lib/core/contracts/`: `FinancialRefreshProvider`,
      `UserLevelProvider`, `GuidelineProvider`. Their implementations live in `modules/bridge/lib/src/impl/` (the
      orchestrator — the only place that knows the concrete controllers), registered with
      `@LazySingleton(as: XProvider)`. Receive providers like any other dependency — see **section IV,
      "Injecting dependencies"**. New cross-feature need → add a method to the matching provider (or a new
      `*Provider` + bridge impl); never route by string/event keys.
    - **Legacy, do not copy:** 46 older uses of other features' controllers still exist (mainly
      `WalletController`, the liability/lend form controllers hosted by `transaction`, `TransactionController`,
      `BudgetLimitController`, `BudgetAllocationController`, `CategorySettingsController`). They are debt to
      migrate, not a pattern: they are frozen per file in `scripts/check_imports_baseline.txt`, and
      `check:imports` fails on any new one (`feature-controller`); route the new need through a provider instead.
    - Contracts the features consume stay in `domain_features` or `cc_bridge` — a contract in `modules/bridge`
      that `domain_features` imports would be a package cycle.
    - **CodeGraph-friendly hops** (each contract → impl → destination must be a static edge an indexer can
      follow): an `abstract interface class` with exactly one `implements` impl annotated
      `@LazySingleton(as: X)` (no hand registration); resolve with constructor injection or a typed `getIt<X>()` /
      `Get.find<X>()` (no `instanceName`, `tag`, or string lookup); no `dynamic` in a contract signature; typed
      Route classes, not string paths; no global `Rx`/stream as a cross-module call channel — wrap it in a
      `*Contract`; one class per file, file name = snake_case(class), suffix `_coordinator` / `_provider` /
      `_contract` (`_impl` for the implementation).
5. **Layer Purity Within a Feature (STRICT)** — `domain/` and `data/` MUST NOT import from their own (or any
   other) `presentation/` layer. Presentation types (Bloc `Event`/`State`, `Obx`, `GetxController`, widgets)
   never flow into `domain/`/`data/`. Streams/data crossing the `domain`↔`presentation` boundary use domain types
   (e.g. a sealed `*Status`/`*Entity`), not presentation event classes. (The `auth` feature's `PhoneAuthStatus`
   is the reference example.)
6. **Clean Bootstrap Integrity (CRITICAL PERF)** — `main.dart` stays a lean, service-only entry point. Startup
   target **< 2 seconds**. Boot sequence (STRICT):
    1. `await initEnv()` first and alone (hands `PrjEnv` values to `CcSdkConfig`, which DI and logging read).
    2. `await Future.wait([Firebase.initializeApp(), initializeDependencies(), _initHive(), CcLocalization.initialize()])`
       — parallel, not sequential.
    3. `getIt<CcAppAttestation>().activate()` (App Check) and other non-critical services fire-and-forget,
       non-blocking.
    4. UI launch.
    Any new startup dependency goes into step 2's parallel block only if truly required before first frame;
    otherwise defer to step 3, or lazily via `NavigationLogicMixin` in the nav bar shell.
    All heavy/infra services **must** be `@lazySingleton`, never eager `@singleton`.

## II. Design system & UI (non-negotiable)

7. **Colors & Typography (SSOT)**: `CcBaseColors` → `PrjColors` → `context.ccColorScheme`. NEVER hardcode hex or
   use `Colors.*`. Typography via `context.ccTextTheme` (Plus Jakarta Sans) — never hardcode font size/weight/family.
8. **Spacing** — use `CcSpace*` (XS=4, SM=8, MD=12, LG=16, XL=24) instead of raw `SizedBox(height: context.respDim(N))`
   for token values. Raw `SizedBox` is fine only for non-token gaps or sizing shapes/icons/charts.
9. **Responsiveness (Adaptive-First)** — two separate concerns, never mixed:
    - **Scale** (sizes of text/icons/gaps) follows the window through one curve, `CcScale` (phones keep
      `width/360`, then a smooth rise to the max at 840 dp, flat beyond): `context.respDim()`, `context.respPadding()`,
      `context.respIconSize()`, `context.respFontSize()`, `context.ccTextTheme`. Never write your own
      `width / 360` factor. Hero headers use `context.respHeaderHeight(factor)` instead of a raw screen-height
      percentage.
    - Width-based sizing reads the space a widget is given (`LayoutBuilder`), not `MediaQuery` width — next to
      the navigation rail the two differ. Cap any remaining screen-ratio size (e.g. `.clamp(0, respDim(n))`).
    - **Full-bleed background, capped content**: page backgrounds and hero headers span the full width; the
      foreground (titles, forms, lists) stops at `CcMaxWidth.contentWidth` (840 dp) via `CcMaxWidth.content`, or,
      for a scroll view that must stay scrollable edge to edge, via `padding: CcMaxWidth.insetFor(width)`. Never
      cap a whole page (background included) — that leaves blank gutters on tablets and the web.
    - **Horizontal carousels bleed**: inside a `CcContentInset` area, wrap capped parts (cards, labels, buttons) in
      `CcContentPadding`, and give a carousel that is *not* inside a card a start padding of
      `base + CcContentInset.of(context)` and an end padding of `base` — it starts aligned with the content and
      scrolls out to the screen edge instead of being cut at the content edge. (Transaction page is the reference.)
    - **Landscape tablets use left / right**: pages and forms split into two columns with `CcTwoColumn`
      (3:2, capped at 1200 dp; `CcTwoColumn.shouldUse(context)` = landscape and >= 600 dp wide), primary content on
      the left, secondary content / actions on the right. Phones and portrait tablets keep the single column.
      List pages use three columns instead: `CcMultiColumn` (items of any height, left to right then down) or a
      3-column grid, inside `CcMaxWidth(maxWidth: CcTwoColumn.defaultMaxWidth)`.
    - **Layout** (navigation, pane count, grid columns) branches on Material 3 window size classes
      (`CcWindowSizeClass`: compact <600, medium 600–840, expanded 840–1200, large 1200–1600, extraLarge ≥1600),
      measured from the **space a widget is given**: `CcAdaptiveBuilder` / `CcResponsiveFlex` (LayoutBuilder-based),
      or `context.windowSizeClass` only for whole-window decisions (the navigation shell). Use
      `CcWindowHeightClass` for vertical-room decisions instead of fixed percentages of screen height. Never branch
      on device type or `Platform`.
    - Check every new screen against the shared matrix in `modules/domain_features/test/adaptive/` (phones,
      foldables, 7"/10" tablets, landscape, web desktop): touch-target size, text overflow, no layout overflow.
10. **Localization** — `el.tr(CcLocaleKeys.key)`, never hardcoded strings. New strings require all three kept in
    sync (no build step enforces this — treat drift as a bug):
    1. `modules/message/assets/translations/en.json`
    2. `modules/message/assets/translations/vi.json`
    3. `modules/message/lib/cc_locale_keys.dart` (the key constant **and** its `CodegenLoader` map entry).

    `message` is app-specific: `cc_core_sdk` and `cc_micro_features` must not import it (`cc_sdk` no longer
    re-exports it — import `package:message/export_message.dart` directly). Shared widgets take user-facing text
    as parameters; `cc_micro_features` owns its strings in `shared/cc_micro_features/lib/l10n/`
    (`CcMfLocaleKeys` + `CcMfTranslations`, all keys under `mf.*`), which the App Shell merges in through
    `CcLocalization.wrapWithLocalization(packageTranslations: [...])`. Keys missing in a locale fall back to `en`.
11. **SDK-First Reuse** — prioritize extending `cc_core_sdk/cc_sdk_ui` components before hand-rolling new widgets.

## III. Code quality & naming

12. **Suffix-First Naming, `lower_snake_case` files**: `*_entity.dart`, `*_usecase.dart`, `*_repository.dart` /
    `*_repository_impl.dart`, `*_model.dart`, `*_page.dart`, `*_bloc.dart`/`*_cubit.dart`,
    `*_state.dart`/`*_event.dart`.
13. **Import Hygiene** — prefer centralized package exports (e.g. `package:cc_micro_features/export_micro_features.dart`)
    over reaching into a specific file inside another module; never import both the export and a specific file
    from the same module. Order: Flutter/Dart → external packages → project modules → local relative
    (`directives_ordering: error` in `analysis_options.yaml`; fix with `dart fix --apply`, don't disable the rule).
14. **Functional Results** — all UseCases/Repositories return `Result<T, CcFailure>` (`multiple_result` package;
    `CcFailure` lives in `cc_sdk_data`, import `package:cc_sdk_data/export_cc_sdk_data.dart`).
15. **Logging** — the `.Log()` extension from `cc_sdk` only. NEVER `print()` or `developer.log()` in production code.
16. **File size & composition** — keep files ~200–300 lines; split large `build()` methods into
    `_buildHeader`/`_buildListItem`/etc. helpers. `const` everything that can be const.
17. `analysis_options.yaml` disables many default lints deliberately — don't re-enable them piecemeal without
    checking why they were turned off first.

## IV. Dependency injection (get_it + injectable)

| Category | Convention |
|---|---|
| File location | **One** `lib/core/di/di.dart` per package (not per feature) |
| Method name | Always `initMicroPackage()` |
| Locator name | Always `getIt` |
| Generated file | `di.module.dart` (or `di.config.dart` at the App Shell level) |
| Annotation style | Annotate the class directly (`@LazySingleton(as: XRepository)` on `XRepositoryImpl`), not a `@module` block |

There is **no per-feature DI module file** — `@InjectableInit.microPackage()` on the package's single
`initMicroPackage()` scans the whole package for annotations. The App Shell consolidates everything in
`lib/core/di/di.dart` via `@InjectableInit` with `externalPackageModulesBefore`. New reusable feature → add it
under `shared/cc_micro_features/lib/features/{name}/` (or `modules/domain_features/lib/features/{name}/` if
app-specific) with `data/`, `domain/`, `presentation/` subfolders, then export it from
`export_micro_features.dart` / `export_domain_features.dart`. See `shared/cc_micro_features/feature_template.md`
for full file templates.

### Injecting dependencies (applies to every package: `lib/`, `modules/*`, `cc_bridge`, `shared/cc_micro_features`, `shared/cc_core_sdk`)

1. **Constructor injection, always.** A class receives every collaborator (repository, use case, service,
   `*Provider`, data source) through its constructor. DI-created classes (`@injectable` / `@lazySingleton`) get
   them from injectable; widgets get them as constructor arguments from the controller or caller that builds
   them (e.g. `AiConsentSheet.ensure(context, prefs)`, `QuickEntrySection(aiPreferences: ...)`).
2. **`getIt` only at the composition root**, which is exactly:
   - each package's `lib/core/di/di.dart` and the App Shell's DI / bootstrap code;
   - the screen entry point that creates its own controller or bloc (page, route, binding), e.g.
     `Get.put(getIt<ExpenseFormController>())`.
   Nowhere else: not in `domain/`, `data/`, controllers, services, mixins, or widgets below the page.
3. **Split, don't bundle.** If a constructor needs **more than 5 dependencies**, or the file passes ~300 lines
   (rule #16), extract one cohesive responsibility into its own `@injectable` class with 2–4 dependencies and
   inject that class instead. Never shorten a constructor by going back to `getIt` or by grouping unrelated
   dependencies into one "bag" object.
4. **Mixins carry no external dependencies.** Logic that needs services is a class injected into the
   controller (composition over inheritance); a mixin may only hold small behavior over its host's own state.
5. **Tests build the class directly with fakes.** If a test has to call `getIt.register…`, the class breaks
   point 1 or 2.

Example — `ProfileController` delegates each concern to a small injected class instead of taking 13
dependencies:

```dart
@injectable
class ProfileAppActions {                      // one concern (AI consent + feedback), 2 dependencies
  ProfileAppActions(this._aiPreferences, this.feedbackReporter);
  final AiFallbackPreferenceDataSource _aiPreferences;
  final CcFeedbackReporter feedbackReporter;
}

@lazySingleton
class ProfileController extends CcGetController {
  ProfileController(this._settingsActions, this._account, this._onboarding, this._app, this.userLevel); // 5
  final ProfileAppActions _app;
  final ProfileAccountActions _account;
}
```

**Reference for point 4:** quick entry. Each transaction form controller owns a `QuickEntrySession` (or
`QuickEntryBatchSession`) built from itself and an injected `QuickEntryHandler`; per-form behaviour comes from hooks
on `TransactionFormController` (`quickEntryCategoryType`, `applyQuickEntryCategory`, ...), not from a mixin.
The session itself only holds state and orchestration; each flow is a small class it owns: `QuickEntryTextInput`,
`QuickEntryImageInput`, `QuickEntryVoiceInput`, `QuickEntryCategoryCache`, plus the stateless
`QuickEntryIntentRouter`.
**Legacy, do not copy:** controllers above 5 dependencies (`ReportController`, ...) and widgets below the page that
still call `getIt` are debt to migrate, not patterns. The `getIt` calls are frozen per file in
`scripts/check_imports_baseline.txt` (`di-composition-root`); `check:imports` fails on any new one.
**Reference for points 1–3:** `wallet`. `WalletController` takes 5 collaborators: `LoadWalletOverviewUseCase`,
`WalletLedger` (balances from transactions), `EmergencyFundAccess` (the unlock rule shared with the add sheet),
`WalletChangeEffects` (what other features see, through `FinancialRefreshProvider` / `GuidelineProvider`),
and the repository. Its sheets are an extension (`WalletSheets`), not a mixin.

## V. Delivery workflow

18. **Evidence-Based Implementation** — verify current structure and linter compliance before and after changes;
    read the actual file, don't assume from a doc or an old memory of the codebase.
19. **Final-State Delivery** — provide final, production-ready implementation. Skip intermediate placeholders/TODOs.
20. **Collaborative Evolution** — for structural changes (file movements, return type updates, DI shifts),
    present a clear plan and proceed after developer confirmation.
21. **Verification checklist before delivery**:
    - [ ] No hardcoded strings/colors/typography.
    - [ ] Functional responsiveness (`context.resp*`) checked at all four breakpoints, both orientations.
    - [ ] Import hygiene and suffix-first naming.
    - [ ] Spacing uses `CcSpace*` (not raw `SizedBox(respDim(N))` gaps).
    - [ ] Localization: JSONs + `CcLocaleKeys` + `CodegenLoader` updated and in sync.
    - [ ] `melos run analyze` (or package-local `flutter analyze`) is clean.
    - [ ] DI: new classes annotated in place, no per-feature module file added, `melos run gen` was run.

## VI. Enforcement (machine-checkable, prefer this over re-reading docs)

Several rules above are currently only enforced by human/agent review — prefer running these checks over relying
on any doc having been read:

22. **Forbidden import boundaries** (rules #2, #3, #4, #5, #10): run `melos run check:imports` (`scripts/check_imports.dart`)
    before finishing a change; CI runs it first in the quality gate and fails on any violation. It checks:
    - `sdk-barrel` / `private-src`: other packages import an SDK package only through its `export_*.dart` barrel
      (or `core/di/`), and never any workspace package's `src/`.
    - `state-agnostic-core`: the SDK core ring and `cc_bridge` use no `bloc`, `flutter_bloc` or reactive GetX
      (no `package:get` either).
    - `sdk-core-vendor`: the SDK core ring imports no vendor SDK (Firebase, ML Kit, location, speech, phone parser,
      `catcher_2`, ...); those live in the capability packages.
    - `project-blind`: SDK, `cc_bridge` and `cc_micro_features` import no app package (`message`, `theme`,
      `domain_features`, `data_config`, `app_config`, `bridge`, the app shell); the SDK and `cc_bridge` import no
      `cc_micro_features`.
    - `layer-purity`: `features/*/domain/` and `data/` import no `presentation/` layer.
    - `no-dotenv`: no `flutter_dotenv` anywhere.
    - `no-developer-log` (rule #15): no `dart:developer` outside the `.Log()` extension itself (`print` is the
      analyzer's `avoid_print`).
    - `package-cycle`: `lib/` imports between workspace packages form no cycle (rule #2). `_knownBackEdges` in the
      script is empty and must stay so; a new cycle is fixed by moving the shared type down, not by an exception.
    - `shell-via-bridge` (rule #4): the App Shell imports from `domain_features` only the wiring files
      (`_shellWiringIntoFeatures`); every call goes through `package:bridge/export_bridge.dart`.
    - `bridge-barrel`: other packages import `bridge` only through `export_bridge.dart` (or `core/di/`), and that
      barrel exports contracts, never a `*_impl.dart`.
    - `coordinator-home`: a `*_coordinator_impl.dart` file lives only in `modules/bridge`.
    - `feature-controller` (rule #4): a feature (or `domain_features/lib/core/`) uses no other feature's
      `*_controller` / `*_bloc` / `*_cubit`, whether imported by package path, relative path, or through a
      barrel that re-exports it. Only `modules/bridge` may.
    - `di-composition-root` (section IV.2): `getIt` only in `core/di/`, the App Shell, a page (`*_page.dart`,
      `presentation/pages/`), or as `getIt<XController|XBloc|XCubit>()` at the entry point creating it.
    Existing `feature-controller` / `di-composition-root` debt is frozen per file in
    `scripts/check_imports_baseline.txt`: a file may not exceed its count, and a count that went down must be
    lowered (`dart scripts/check_imports.dart --write-baseline`), so the file only shrinks. Never add a line to it.
    A new rule goes into the script, not only into this file.
23. **Import order** (rule #13): rely on `dart analyze` with `directives_ordering` enabled, `dart fix --apply` to
    auto-sort.
24. **Pre-delivery checklist** (rule #21): treat each unchecked box as a blocking issue, not an FYI.

## See also

- `docs/AI_CONTEXT.md` — deeper rationale/history behind these rules, project structure diagrams, SOLID summary.
- `docs/onboarding.md` — new-developer fast path, most-important-files list.
- `docs/CONTRIBUTING.md` — PR checklist, doc-sync obligations.
- `shared/cc_micro_features/feature_template.md` — full copy-pasteable file templates for a new feature.

<!-- codegraph:start -->
## CodeGraph — Code Intelligence

This project is indexed by CodeGraph (a `.codegraph/` directory exists at the repo root). Reach for it BEFORE
grep/find or reading files when you need to understand or locate code.

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant
  symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow.
  Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load
  it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

The index lags writes by ~1s through the file watcher; no manual re-index step is normally needed.
<!-- codegraph:end -->
