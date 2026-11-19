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
  domain_features/lib/features/   # App-specific business verticals (wallet, transaction, budget, loan,
                                   # reconciliation, report, user_level, category, comment, profile, ...)
  data_config/                    # App-specific data implementations; implements Repository interfaces
                                   # that domain_features/cc_micro_features define
  app_config/                     # Env management, storage, DI discovery
  bridge/                         # NavigationBridgeService — app-level post-boot orchestration (user level,
                                   # data services, authenticated sync, reminders). NOT a duplicate of cc_bridge.
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
    cc_sdk_firebase/              #   capability ring: Firebase impls of core interfaces (CcAnalytics, ...)
    cc_sdk_slack/                 #   capability ring: Slack webhook impls (crash alerts, user feedback)
cc_bridge/                        # Root-level cross-module contracts (*Coordinator / *Contract / *Provider)
                                   # (contracts only; the app-level service lives in modules/bridge)
```

`shared/cc_core_sdk` is a **git submodule**; commits there don't land by editing files in this repo — they must
be committed and pushed inside the submodule itself, then the parent repo's submodule pointer updated separately.

## I. Architectural integrity (the laws)

1. **Hybrid-Modular Super App Design (CRITICAL)** — three layers, strictly separated: App Shell (`lib/`, pure
   orchestrator, no business logic/feature UI), Domain Features (`modules/domain_features/`, app-specific
   verticals), Micro-Features (`shared/cc_micro_features/`, project-blind reusable verticals), Shared Core
   (`shared/cc_core_sdk/`, universal engine), Bridge Layer (`cc_bridge/`, cross-module contracts).
2. **Project-Blind Dependency Rules (STRICT)**:
    - `cc_micro_features` and `domain_features` **must not** import from `lib/` (App Shell) or `modules/data_config`.
    - `cc_micro_features` must not import from `domain_features`.
    - Every feature defines its own `Repository` interface in its own `domain/` layer; `lib/` or
      `modules/data_config` implements it and injects the impl via DI. Never import a concrete repository impl
      across a module boundary.
3. **State-Management Agnostic Core (STRICT)**:
    - `cc_core_sdk` (`cc_sdk`, `cc_sdk_ui`, `cc_mixin`) and `cc_bridge` must stay state-management agnostic — no
      Bloc/GetX reactive state.
    - **Pragmatic exception**: `cc_sdk_ui` (and transitively `cc_sdk`) uses the `get` package for lightweight
      navigation/context helpers only (`Get.context!`, `Get.dialog`, `Get.back()` in `CcDialogHelper`). This is
      NOT state management — never introduce `GetxController`/`Obx` into the core.
    - Presentation layers are free to use Bloc or GetX; the project deliberately supports both, chosen per feature.
4. **Interface-Driven Communication (the Bridge)** — all cross-module interactions (navigation, session
   management) are mediated by contracts in `cc_bridge`. Naming: `*Coordinator` (flow/navigation), `*Contract`
   (shared state), `*Provider` (shared logic). Features depend on abstractions, never concrete impls of other
   features. `cc_bridge` holds only project-blind contracts (auth, session) and must not import any app module;
   app-specific coordinators (wallet, transaction, comment, home) live in
   `modules/domain_features/lib/core/navigation/coordinator/`, implemented by the App Shell.
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
    3. `CcAppCheckHelper.initialize()` and other non-critical services fire-and-forget, non-blocking.
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
    `CcFailure` lives in `cc_sdk`).
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

22. **Forbidden import boundaries** (rules #2, #3, #5): grep for illegal imports before finishing a change —
    `shared/cc_micro_features/**/domain/**` and `**/data/**` must not import `*/presentation/**`, `lib/`,
    `modules/data_config`, or `domain_features`; `cc_core_sdk/**` and `cc_bridge/**` must not import `bloc`,
    `flutter_bloc`, or reactive `get` (except the documented `cc_sdk_ui` navigation-helper exception). A
    `melos run check:imports` CI script for this is recommended but not yet built — until it exists, this is a
    manual check.
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
