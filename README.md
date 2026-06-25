# Flutter Hybrid-Modular Super App Template

A production-ready modular starter kit built around **Clean Architecture**, **SOLID principles**, and a **Hybrid-Modular Super App** vision. Designed for enterprise-scale applications where features are treated as independent, reusable "Micro-Features."

## 🚀 Architectural Vision: The Super App Ecosystem

This project is engineered as an ecosystem of independent Lego blocks rather than a single monolithic application. The architecture is split into three rigid layers:

1.  **App Shell (Host/Container)**: The lightweight `lib/` shell responsible for startup, security checks, routing, and dynamic orchestration of sub-features.
2.  **Micro-Features (Feature-as-a-Service)**: Located in `cc_micro_features/`, these are standalone, project-blind business verticals (e.g., Auth, Pay, Loyalty). They are designed to be "Global Lego Blocks" reusable across multiple different enterprise projects.
3.  **Shared Core Layer (Core SDK)**: Located in `cc_core_sdk/`, this is the "Universal Logic Layer" (Auth, Network, Encryption, Data Persistence). It is designed to mirror KMP (Kotlin Multiplatform) logic, making it ready for cross-platform binary sharing.

## 🎯 Critical Principle: State-Management Agnostic & Project-Blind

**Core libraries (`cc_sdk`, `cc_sdk_ui`, `cc_mixin`) and `cc_micro_features` MUST be state-management agnostic and 100% project-blind.**

### Why This Matters
-   **Zero Regression**: A change in the Booking flow cannot break the Payment gateway because they are isolated modules.
-   **Parallel Development**: Different teams can work on different Micro-Features simultaneously without merge conflicts.
-   **Infinite Reusability**: You can pick up `cc_micro_features/auth` and drop it into a completely different App Shell tomorrow with zero modifications.

### Key Guidelines for Micro-Features
-   ✅ **ALLOWED**: Imports from `cc_core_sdk` and 3rd party utilities.
-   ❌ **FORBIDDEN**: Imports from the App Shell (`lib/`) or app-specific modules (`modules/data`).
-   **Interface-Driven**: Micro-Features define their own `Repository` contracts. The App Shell or Data module implements these and injects them via DI.

## 🛠 Project Structure

```
flutter-get-starter-template/
├── lib/                          # App Shell (Project-Specific)
│   ├── core/                     # Startup, DI orchestration, Global Router
│   ├── data/                     # Project-specific data implementations
│   └── presentation/             # Local glue logic and UI
├── cc_micro_features/            # Global Reusable Features (Project-Blind)
│   ├── auth/                     # Auth Micro-Feature
│   ├── counter/                  # Counter Micro-Feature
│   └── ...                       # Other business verticals
├── cc_core_sdk/                  # Shared Core SDK (Universal Engine)
│   ├── cc_sdk/                  # Pure Logic, Network, Failures
│   ├── cc_sdk_ui/               # Design System & UI Components
│   └── cc_mixin/                # Reusable Behaviors
├── modules/                      # App Support Modules
│   ├── app_config/              # Env, Storage, Global DI
│   ├── theme/                   # Brand Design Tokens (EB Garamond)
│   └── message/                 # Centralized i18n
└── docs/                        # Architecture & Onboarding Docs
```

## 🏗 Naming Convention (Suffix-First)

To prevent name collisions in a Super App, we enforce strict suffixing:
-   **Entities**: `*_entity.dart`
-   **UseCases**: `*_usecase.dart`
-   **Repositories**: `*_repository.dart` (Interface) / `*_repository_impl.dart`
-   **Models**: `*_model.dart`
-   **Pages**: `*_page.dart`
-   **State Management**: `*_bloc.dart` / `*_state.dart`

## 🚦 Quick Start

1.  Read `docs/AI_CONTEXT.md` for the full "Constitution" of this project.
2.  Run `melos bootstrap` to set up the workspace.
3.  Run `melos run setup:firebase` to initialize config templates.
4.  Run `melos run gen` to generate all DI and serialization code.

---
**See `docs/onboarding.md` for a step-by-step developer guide.**
