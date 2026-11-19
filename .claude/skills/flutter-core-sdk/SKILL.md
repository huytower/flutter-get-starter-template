---
name: flutter-core-sdk
description: Use when adding, changing, moving, or consuming anything in shared/cc_core_sdk (cc_sdk, cc_sdk_ui, cc_mixin, cc_sdk_data) — the Flutter engine meant to be reused across many apps AND many business domains. Covers the cross-domain "second-domain test", ring structure (core / optional capabilities / design system), dependency budget, API stability, known domain leaks to relocate, the submodule commit workflow, and adopting the SDK in a new project.
---

# Flutter Core SDK (`shared/cc_core_sdk`)

The SDK is the **universal engine** shared by every app built from this template — finance today, but also
e-commerce, health, education, or anything else tomorrow. Its value is reuse across **projects and domains**:
a change here is felt by every consumer, so it must stay **project-blind**, **domain-blind** and
**state-management agnostic**. Repo-wide rules live in `AGENTS.md`; this skill covers only the SDK layer.

## Goal and the second-domain test

Before putting anything in the SDK, ask: *"Would an e-commerce, health, or education app use this exactly as is?"*

- **Yes** → SDK.
- **Only after renaming or removing business terms** → generalize it first (parameters, generics, interfaces),
  then put it in the SDK.
- **No** (it knows money, wallets, categories of expense, receipts, budgets, loans, ...) → it belongs in
  `modules/domain_features` or the app shell, built on SDK primitives.

Neutral vocabulary only: no domain nouns in class names, doc comments, enum values, or default text.

## Rings (what may depend on what)

1. **Core (domain-free, always present):** `CcFailure`, `.Log()`, `ccGson`, `CcScale`, `CcWindowSizeClass`,
   tokens (`CcBaseColors`, `CcSpace*`), mixins, generic entities (user, device, message), pagination.
2. **Optional capabilities (vendor- or platform-specific):** analytics, crash reporting, AI/Gemini, speech, Slack
   feedback, location, phone-number helpers. Each sits behind an interface in the core ring and its vendor
   implementation lives in its own package, so an app that does not use it does not pull its dependencies.
3. **Design system:** generic components only (buttons, cards, inputs, dialogs, adaptive layout, state views).
   Domain-shaped widgets (wallet, expense category) do not belong here.

Inner rings never import outer rings. The core ring has no vendor SDK dependency.

## Dependency budget

- Every new `pubspec` dependency in the core ring needs a justification a second domain would also accept.
- Heavy or vendor packages (Firebase, AI, speech, maps) go in the capability ring behind an interface, never
  in the core ring's `pubspec.yaml`.
- Prefer injected abstractions (`Analytics`, `CrashReporter`, `AiClient`) over static calls to a vendor.
- Reference pattern already in the SDK: `CcNetworkInfo` (`cc_sdk`) and `CcMessagingService` (`cc_sdk_data`) are
  abstract interfaces; the Firebase implementation of messaging lives outside the core
  (`cc_micro_features/lib/features/messaging/data/services/`). Canonical capability example: `CcAnalytics`
  (interface + `CcNoopAnalytics` in `cc_sdk`) implemented by `CcFirebaseAnalytics` in the `cc_sdk_firebase` package,
  registered `@LazySingleton(as: CcAnalytics)` and wired through `ExternalModule(CcSdkFirebasePackageModule)`.
  Copy this shape for every new vendor capability.
- Do not add new static-only vendor helpers (private constructor + static methods calling a vendor SDK): they
  cannot be mocked or swapped. All former static vendor helpers are migrated (AI, analytics, crash reporting,
  app attestation, Slack, speech, location, phone); keep it that way.
- Configuration comes in through `CcSdkConfig.configure()` (core settings) and each vendor helper's
  `configure(...)` (e.g. Slack webhook, Gemini model), called by the app at boot. The SDK never reads `.env`
  files, `dotenv` or `--dart-define` keys itself; `CcFeatureFlags`, `CcRouteConfig`, `CcAppTrackName` and
  `CcCrashLogEnv` are read-only views of `CcSdkConfig.current`.

## Known domain leaks to relocate (audit of the current SDK)

Found by file names, keyword search and `pubspec` review; confirm coupling depth before moving. A move is a
structural change: present a plan and get the user's confirmation first (`AGENTS.md` rule 20).

| Where | Why it leaks | Direction |
|---|---|---|
| `cc_sdk/.../cc_receipt_scan_helper.dart` | receipt scanning is a finance use case | **Done (2.0.0):** removed; the app owns `ReceiptImagePickerHelper` |
| `cc_sdk_ui/lib/widgets/wallet/cc_wallet_item.dart` | wallet widget | **Done (2.0.0):** removed; the app owns `PrjWalletItem` |
| `cc_sdk_ui/lib/widgets/category/*` | expense-category shaped | **Done (2.0.0):** removed; the app owns `PrjCategory*` |
| `cc_gemini_helper`, `cc_slack_*`, `cc_speech_helper` | tied to one vendor | **Done (2.0.0):** `CcAiClient`, `CcFeedbackReporter`, `CcSpeechRecognizer` + capability packages |
| `cc_sdk/pubspec.yaml` (was 27 dependencies) | every consumer inherited every vendor SDK | **Done (2.0.0):** 15 left, no vendor service SDK. Still in core: `catcher_2`, `connectivity_plus`, `internet_connection_checker_plus`, `device_info_plus`, `package_info_plus`, `flutter_udid`, `path_provider`, `shared_preferences` (platform plugins for universal concerns), `dartx` (re-exported as public API), `ansicolor` (vendored gson) |
| `CcFeatureFlags.isVipModeEnabled` (`ENABLE_VIP_MODE`) | product concept in a core config type | **Done (2.0.0):** removed; the app reads it via `PrjFeatureFlags` |
| `CcUserEntity.linkedProviderIds` doc | described the field in Firebase terms | **Done:** described provider-neutrally |
| `cc_micro_features`: `FirebaseAuthRepository` (in `domain/`) | the abstraction is named after its vendor | **Done:** renamed `AuthRepository` (exported from `export_auth.dart`); `FirebaseAuthRepositoryImpl` stays in `data/` |

## Stability and versioning

- The public API is what the barrel files export. Treat it as a contract: additive changes by default;
  renames and removals go through `@Deprecated('use X, removed in <version>')` for at least one release.
- Version the SDK with semver in the submodule repo; tag releases so consumers pin a tag, not `main`.
- Keep a minimal example app (or the test suite) that uses the SDK with **no** domain features, as proof the
  SDK stands alone. A change that breaks it is a domain leak or a hidden dependency.
- Record breaking changes and the migration step in the package `CHANGELOG.md`.

## Package map

| Package | Owns | Entry point |
|---|---|---|
| `cc_sdk` | Network/device helpers, DI core, config (`CcFeatureFlags`, route config), crash reporting, `ccGson`, the `.Log()` extension, `CcScale`, `CcWindowSizeClass` | `export_cc_sdk.dart` |
| `cc_sdk_ui` | Design system and widget catalog (adaptive layout, buttons, cards, dialogs, inputs, text, shimmer, navigation), tokens (`CcBaseColors`, `CcSpace*`), `CcContextExtension`, `CcMaxWidth`, `CcTwoColumn` | `export_cc_sdk_ui.dart` |
| `cc_mixin` | Reusable behavior mixins: pagination, refresh/load-more, back-button, navigation, view config | `export_cc_mixin.dart` |
| `cc_sdk_data` | Core entities/models, `CcFailure` hierarchy, shared domain services | `export_cc_sdk_data.dart` |
| `cc_sdk_firebase` | Capability ring: Firebase implementations of core interfaces (`CcFirebaseAiClient`, `CcFirebaseAnalytics`, `CcFirebaseCrashReporter`, `CcFirebaseAppAttestation`). Only package allowed to import Firebase SDKs (migration in progress) | `export_cc_sdk_firebase.dart` |
| `cc_sdk_slack` | Capability ring: Slack webhook implementations (`CcSlackHandler` crash alerts, `CcSlackFeedbackReporter` as `CcFeedbackReporter`); captions come translated from the app | `export_cc_sdk_slack.dart` |
| `cc_sdk_device` | Capability ring: device-plugin implementations (`CcDeviceLocationService` as `CcLocationService`, `CcSpeechToTextRecognizer` as `CcSpeechRecognizer`) | `export_cc_sdk_device.dart` |
| `cc_sdk_phone` | Capability ring: `CcLibPhoneNumberValidator` (`phone_numbers_parser`) as `CcPhoneNumberValidator`; `cc_sdk` ships the dependency-free `CcBasicPhoneNumberValidator` | `export_cc_sdk_phone.dart` |

Dependency direction (verified from `pubspec.yaml` and imports): `cc_mixin` → `cc_sdk_ui` → `cc_sdk` →
`cc_sdk_data`; capability packages (`cc_sdk_firebase`, `cc_sdk_slack`, `cc_sdk_device`, `cc_sdk_phone`) → `cc_sdk`. Never the reverse, never a cycle. `cc_mixin` depending on the whole design system is a known
weakness: a new mixin should depend only on `cc_sdk_data` / `cc_sdk` unless it genuinely needs a widget.

Encapsulation: every SDK package keeps its implementation in `lib/src/`; the only public entry points are the
`export_*.dart` barrel and, by the DI convention, `lib/core/di/` (`di.dart` / `di.module.dart`). Consumers and
sibling SDK packages import barrels only (no `package:x/src/...`). New files go under `lib/src/`, and only what
consumers need is exported from the barrel.

## Hard rules (a violation breaks reuse)

1. **Project- and domain-blind.** No import of `lib/` (App Shell), `modules/*`, `cc_micro_features`, `domain_features`, or any
   app name, brand, URL, key, or business term. If a widget needs app text/colors/behavior, take it as a
   parameter or an abstract interface the app implements.
2. **No reactive state management.** No `bloc`, `flutter_bloc`, `GetxController`, `Obx`, `.obs`. Only exception:
   `cc_sdk_ui` uses `get` for navigation/context helpers (`Get.context!`, `Get.dialog`, `Get.back()`). Never extend it.
3. **No i18n coupling.** The `message` module is app-specific. SDK widgets receive already-translated `String`s.
4. **Colors/typography.** Use `CcBaseColors` and `context.ccColorScheme` / `context.ccTextTheme`. No `Colors.*`,
   hex, or hardcoded font size/weight/family.
5. **Scale and layout.** Sizes via `context.respDim/respPadding/respIconSize/respFontSize` (single `CcScale` curve,
   never a private `width / 360`). Layout branches on `CcWindowSizeClass` measured from the space given
   (`CcAdaptiveBuilder`, `LayoutBuilder`), never on `Platform` or device type.
6. **Results and errors.** UseCases/repositories return `Result<T, CcFailure>` (`multiple_result`); add a new
   failure as a subclass of `CcFailure` in `cc_sdk_data/lib/src/domain/failures/`.
7. **Logging.** `.Log()` only; never `print()` or `developer.log()` directly.
8. **DI.** Services are `@lazySingleton`, never eager `@singleton` (the SDK is on the boot path, target < 2 s).
   One `lib/core/di/di.dart` per package; annotate classes in place.
9. **Naming and files.** Suffix-first `lower_snake_case`, `Cc` class prefix, ~200–300 lines per file, `const`
   wherever possible, export through the package's `export_*.dart` barrel only.

## Reuse-first workflow

Before writing any widget, helper, extension, or mixin:

1. Search the SDK with CodeGraph (`codegraph_explore "<what you need>"`); fall back to `rg` under
   `shared/cc_core_sdk` only for non-indexed files.
2. If something close exists, **extend it** (new parameter, named constructor, variant) rather than adding a
   parallel one.
3. Decide where new code belongs:
   - Generic, no app knowledge, useful to a second project → **SDK** (this skill applies).
   - Knows about this app's entities, copy, colors (`PrjColors`), or flows → `modules/domain_features` or the app
     shell, built on top of SDK pieces.
   - Reusable vertical with its own data/domain/presentation (auth, biometric, ...) → `shared/cc_micro_features`.
4. Check blast radius before editing an existing SDK symbol: `codegraph_explore "<SymbolName>"` lists callers
   across the app. Prefer additive, backward-compatible changes; a breaking change needs a plan and the user's OK.

## Adding to the SDK: checklist

- [ ] Passes the second-domain test, ring placement and dependency budget above.
- [ ] Passes the Hard rules above (grep the new files for `package:message`, `bloc`, `Colors.`, `print(`).
- [ ] Exported from the correct `export_*.dart` barrel; no consumer imports a deep file path.
- [ ] Public API documented with a `///` doc comment and a one-line usage example.
- [ ] Widgets: verified compact → large, portrait and landscape, no overflow, touch targets adequate.
- [ ] Tests added under the package's `test/` (see `cc_sdk_ui/test/widgets/adaptive/` for the pattern).
- [ ] `flutter analyze` clean in the package; `dart run build_runner build --delete-conflicting-outputs` run if DI
      or generated code changed.
- [ ] If the SDK's public surface changed, update the package `README.md` / `AGENTS.md`.

## Submodule workflow (important)

`shared/cc_core_sdk` is a **git submodule** (`huytower/cc_core_sdk`). Editing files here does not commit them to
the parent repo.

1. Commit and push **inside** `shared/cc_core_sdk` (on its own branch/remote).
2. Then, in the parent repo, commit the updated submodule pointer as a separate change.
3. Never push without the user's explicit go-ahead.
4. Stray local noise (e.g. `.dart_tool/` files showing as modified) is not part of an SDK change; do not commit it.

## Adopting the SDK in a new project

1. Add the submodule: `git submodule add <cc_core_sdk url> shared/cc_core_sdk`.
2. Reference the four packages by `path:` in the workspace/app `pubspec.yaml`, add them to `melos.yaml`
   packages, run `melos bootstrap`.
3. Call the SDK's DI entry (`initMicroPackage()`) from the app's `@InjectableInit` via
   `externalPackageModulesBefore`; follow the boot order in `AGENTS.md` (env first, then parallel init).
4. Provide the app-owned pieces the SDK deliberately does not: theme (`PrjColors` built on `CcBaseColors`),
   translations, repository implementations, feature flags values.
5. Import only through the barrels: `package:cc_sdk/export_cc_sdk.dart`,
   `package:cc_sdk_ui/export_cc_sdk_ui.dart`, `package:cc_mixin/export_cc_mixin.dart`,
   `package:cc_sdk_data/export_cc_sdk_data.dart`.

## Quick reference

- Logging: `value.Log('tag')`; serialization: `ccGson.encode(obj)` / `ccGson.decode(str)`.
- Spacing tokens: `CcSpaceXS/SM/MD/LG/XL` (4/8/12/16/24).
- Content cap: `CcMaxWidth.content` (840 dp); scroll views use `padding: CcMaxWidth.insetFor(width)`.
- Landscape tablets: `CcTwoColumn` (check `CcTwoColumn.shouldUse(context)`); list pages: `CcMultiColumn`.
- Window classes: compact < 600, medium 600–840, expanded 840–1200, large 1200–1600, extraLarge ≥ 1600.
