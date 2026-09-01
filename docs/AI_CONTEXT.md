# AI Context - Flutter Get Starter Template

A modular Flutter starter built around **Clean Architecture** and **SOLID principles**, with reusable packages for core
SDK, UI, and feature modules.

**The actionable rulebook lives in `/AGENTS.md`** (repo root) — read it first. This document is the deeper
narrative/rationale layer: *why* the architecture looks this way, the full project-structure reference, and
detail that doesn't belong in a rule list. If anything here appears to contradict `AGENTS.md`, `AGENTS.md` is
authoritative — treat the discrepancy as a bug in this file and flag it rather than following the older text.

## Why the layers are split this way

The project is divided into layers so that features can be moved, replaced, or extracted into a different app
without code changes elsewhere (`AGENTS.md` rules #1–#5 state the resulting import-boundary laws):

- **App Shell** (`lib/`) is a pure orchestrator on purpose — if it accumulated business logic, every feature
  would become entangled with app-specific glue code, defeating the "Super App" premise of reusable verticals.
- **Domain Features vs. Micro-Features** is a reusability boundary, not a folder-naming preference: anything
  that assumes *this specific app* (its wallet/budget/transaction domain) belongs in `domain_features`; anything
  that could be dropped into an unrelated app unchanged (auth, biometric, crash reporting UI) belongs in
  `cc_micro_features`.
- **Dependency Inversion** (features define their own `Repository` interface; `lib/` or `data_config` implements
  it) exists so the same feature package can be pointed at a different backend per app without touching feature
  code.
- **State-management agnosticism in the core** exists because the template deliberately supports both Bloc and
  GetX in `presentation/` — baking either into `cc_core_sdk` would force every consuming app onto one choice.
  The historical incident that motivated the strict `domain`/`presentation` layer-purity rule (rule #5): the
  `auth` feature once leaked a Bloc-shaped event type across that boundary, which is why cross-layer streams now
  use a sealed `*Status`/`*Entity` domain type (see `PhoneAuthStatus`) instead.

## Full project structure (reference)

```
flutter-get-starter-template/
├── lib/                          # App Shell (Pure Orchestrator)
│   ├── core/                     # Core app logic (Global DI, Root Routing)
│   ├── data/                     # Project-specific data (Impl, Adapters)
│   ├── presentation/             # Shell UI (NavigationBar, Root Scaffold)
│   └── main*.dart               # Entry points
├── modules/domain_features/      # Business Verticals (Vertical Features)
│   └── lib/features/            # Home, Comment, Wallet, Transaction, etc.
├── shared/cc_micro_features/     # Global Legos (Micro-Features)
│   └── lib/features/            # Auth, Biometric, Splash, etc.
├── shared/cc_core_sdk/           # Shared Core (Engine) — GIT SUBMODULE
│   ├── cc_sdk/                  # Core SDK (network, device, failures, ccGson)
│   ├── cc_sdk_ui/               # UI component library (CcContextExtension)
│   ├── cc_mixin/                # Reusable mixins
│   └── cc_sdk_data/             # Core data entities/models
├── cc_bridge/                   # Bridge for communication (root level)
├── modules/                      # App-specific modules
│   ├── app_config/              # Configuration, Storage
│   ├── message/                 # i18n/localization (CcLocaleKeys)
│   └── theme/                   # Theming system (PrjColors, CcTextStyle)
└── docs/                        # Documentation
```

Each package under `modules/`, `shared/`, and `cc_bridge/` has its own package-scoped `AGENTS.md` covering what's
distinctive about it, plus a `README.md` as the source of truth for its technical API surface — check both
before making non-trivial changes inside a package.

## Multi-screen & orientation support (detail)

Breakpoints and the `context.resp*` API are covered in `AGENTS.md` rule #9. Platform-level configuration that
backs those breakpoints:

- **Android**: `android:screenOrientation="unspecified"` in `AndroidManifest.xml`.
- **iOS iPhone**: Portrait, LandscapeLeft, LandscapeRight in `Info.plist`.
- **iOS iPad**: all orientations supported (Portrait, PortraitUpsideDown, LandscapeLeft, LandscapeRight).
- Use `context.isPortrait` / `context.isLandscape` for orientation-specific layout branches, and
  `LayoutBuilder`/`OrientationBuilder` where a widget needs to react to orientation directly.
- Landscape is worth deliberately designing for on data-heavy screens (dashboards, tables, charts), not just
  tolerating.

## Key technologies

- **DI**: `get_it` (service locator) + `injectable` (codegen, v3.0+), Micro-Package pattern. Annotations in use:
  `@injectable`, `@module`, `@preResolve`, `@named`, `@singleton`, `@lazySingleton`,
  `@InjectableInit.microPackage()`. The concrete file/method/locator conventions are in `AGENTS.md` section IV.
- **State management**: no lock-in. `cc_sdk`, `cc_sdk_ui`, `cc_mixin`, `cc_micro_features` domain/data layers
  stay agnostic; `presentation/` layers choose Bloc or GetX per feature, via abstract interfaces implemented
  with either.
- **Melos workspace**: scripts are defined once, in root `pubspec.yaml`'s `melos.scripts` — melos 7.8.1 reads
  scripts from `pubspec.yaml`, not `melos.yaml`. Keep `melos.yaml` free of a `scripts:` section to avoid drift
  between two divergent script definitions.

## SOLID, applied

- **Single Responsibility**: each class/module has one reason to change — this is why `build()` methods get
  split into `_buildHeader`/`_buildListItem`/etc. (`AGENTS.md` rule #16): a change to the header shouldn't force
  a diff touching the list item too.
- **Open/Closed**: extend via new implementations behind existing interfaces, not by modifying shared code paths.
- **Liskov Substitution**: any `Repository` implementation must be swappable for another without breaking the
  UseCase that depends on it — this is what makes the dependency-inversion rule (`AGENTS.md` rule #2) work in
  practice.
- **Interface Segregation**: prefer several small `Repository`/`Coordinator` interfaces over one broad one that
  forces unrelated features to depend on methods they don't use.
- **Dependency Inversion**: depend on abstractions (`domain/repositories/*.dart`), never on a concrete
  `*_repository_impl.dart` from another module.

## See also

- `/AGENTS.md` — canonical rulebook (read first).
- `docs/onboarding.md` — new-developer fast path.
- `docs/CONTRIBUTING.md` — PR checklist, doc-sync obligations.
- `shared/cc_micro_features/feature_template.md` — full copy-pasteable file templates for a new feature.
