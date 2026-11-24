# Changelog

Changes to the app and workspace (this repository). Dates are `YYYY-MM-DD`. The SDK (`shared/cc_core_sdk`, a git
submodule) keeps its own `CHANGELOG.md` in each package, with its own version numbers; entries here only note when
the app moved to a new SDK commit.

New entries go under `## Unreleased` until the next store release (`docs/CONTRIBUTING.md`).

## Unreleased

Summary of the work since 2026-05-31. The app version in `pubspec.yaml` is still `1.0.0`; store builds are
numbered by CI (`docs/tech/development/BUILD.md`).

### Breaking (for contributors)

- **App settings come from `--dart-define`s**, not `.env` files: `env/prod.json` (copy of
  `env/prod.example.json`, generated in CI from GitHub Variables and Secrets), read by `PrjEnv`. `flutter_dotenv`
  and the UAT environment were removed; only the `prod` flavor exists. See `docs/tech/development/CONFIG_ENV.md`.
- **The App Shell reaches features only through `modules/bridge`** (`AppLifecycleProvider`, `MainShellProvider`,
  `RegionalSettingsContract`); every coordinator impl lives there. Cross-feature calls use `*Provider` contracts
  (`FinancialRefreshProvider`, `UserLevelProvider`, `GuidelineProvider`) instead of other features' controllers.
- **Shared entities moved** to `modules/domain_features/lib/core/domain/entities/`; package cycles removed
  (`app_config` no longer depends on `data_config`).
- **The SDK is imported only through its `export_*.dart` barrels**; it no longer depends on `get`, and vendor code
  moved to capability packages (`cc_sdk_firebase`, `cc_sdk_catcher`, `cc_sdk_slack`, `cc_sdk_device`,
  `cc_sdk_phone`). The app injects `CcAnalytics`, `CcCrashReporter`, `CcAppAttestation`, `CcAiClient`,
  `CcFeedbackReporter`, `CcSpeechRecognizer`, `CcLocationService`, `CcPhoneNumberValidator`.
- **Naming rules**: one public type per file, file named after it; canonical folder names (`models/`, `get_x/`,
  purpose-named folders instead of `helper/` / `util/`); `Prj` prefix for app types; `has` prefix for booleans.
- **Dependency injection**: constructor injection everywhere, `getIt` only at the composition root
  (`AGENTS.md` section IV); quick entry uses a controller-owned `QuickEntrySession` instead of mixins.

### Added

- Reusable widgets moved to the SDK, phase 1 (`docs/plans/widget-reuse-to-shared.md`):
  `showAdaptiveBottomSheet` → `CcAdaptiveBottomSheet.show` (also used by `CcDialogHelper` sheets),
  `revealRowCard` → `CcScrollReveal.reveal`, `ReportCardPair` → `CcTwoColumnPair`,
  `PrjCategoryShimmerList` → `CcShimmerList`, `PrjPageBackground` → `CcGradientBackground.page`.
  The asset-row sizes stay in the app as `AssetCardMetrics`.
- `melos run check:imports` (`scripts/check_imports.dart`): import boundaries, package cycles, naming and DI rules,
  run first in CI. Existing debt is frozen in `scripts/check_imports_baseline.txt`.
- CI release pipeline on push to `qltc`: Android AAB to Google Play alpha, iOS IPA to TestFlight
  (`docs/CICD_SETUP.md`). Firebase App Distribution was removed.
- Adaptive layouts: one scale curve (`CcScale`), navigation rail on wide windows, two columns on landscape
  tablets, three-column lists, one orientation policy for phones and tablets.
- AI Smart Entry: text, voice, receipt photo and multi-image parsing, location-based suggestions, AI financial
  advice; a Profile switch gates Gemini.
- Forced app update driven by Firebase Remote Config.
- Privacy policy page; deleting the account also deletes its cloud data.
- Caught repository errors are reported to Crashlytics and Slack.

### Changed

- Upgraded to Flutter 3.50 and AGP 9 with built-in Kotlin; iOS builds with Xcode 27.2 / iOS 27 SDK in CI.
- The whole book is kept in the primary currency, with exact math.

### Fixed

- A liability repayment or collection can no longer exceed what is still owed; payments work against synthetic
  liabilities; a missing liability record no longer crashes.
- Deleting a transaction now syncs to the cloud; guest data is discarded before signing in to cloud data.

## 2026-05-31 — Dependency injection revamp (micro-packages)

### Breaking

- **Architecture**: DI moved to the **Injectable micro-package** pattern. Each package is a self-contained DI unit
  that the app shell wires in.
- **Naming**:
  - One DI entry point per package, at `lib/core/di/di.dart`, method `initMicroPackage()`.
  - One locator name, `getIt`, shared by all packages.
  - Removed module-specific locators (`ccSdkLocator`, `appConfigLocator`, `getItData`).
- **Initialization**:
  - The app shell's `initializeDependencies()` (`lib/core/di/di.dart`) now registers every micro-package.
  - `@InjectableInit` uses `externalPackageModulesBefore` to resolve dependencies across packages.

### Fixed

- Registration conflict for `CcNetworkHelper`.
- Missing-dependency warnings for third-party types (`Dio`, `SharedPreferences`), using `ignoreUnregisteredTypes`.
- `PaginatedResponse` build warning (missing `part` directive and `@JsonKey` mappings).

## 2022-10-28 — Version 30

No notes were recorded for this release.
