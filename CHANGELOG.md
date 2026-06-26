# Project Template

### RELEASED

#### [31/05/2026] Dependency Injection Revamp (Micro-Packages)

**BREAKING CHANGES**

- **Architecture**: Migrated DI to the **Injectable Micro-Package** pattern. Libraries and modules are now
  self-contained DI units automatically discovered by the main app.
- **Naming Convention**:
    - Standardized DI entry point for all modules at `lib/core/di/di.dart`.
    - Standardized DI locator name to `getIt` across all packages.
    - Removed module-specific locators (e.g., `ccSdkLocator`, `appConfigLocator`, `getItData`) in favor of a shared
      `getIt` instance.
- **Initialization**:
    - Simplified app startup sequence. Main `init()` call now automatically handles all micro-package registrations.
    - Updated `InjectableInit` to use `externalPackageModulesBefore` for better cross-package dependency resolution.

**Fixes & Improvements**

- Resolved registration conflict for `CcNetworkHelper`.
- Fixed missing dependency warnings for third-party types (`Dio`, `SharedPreferences`) using `ignoreUnregisteredTypes`.
- Resolved `PaginatedResponse` build warning by adding missing `part` directive and `@JsonKey` mappings.

---

#### Version 30 [28/10/2022]

[//]: # (- request update version when resume app, at Android)
