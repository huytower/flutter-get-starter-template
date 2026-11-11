# Sổ Sách Xịn — Personal Finance Super App

**Sổ Sách Xịn** (Quản Lý Tài Chính) is an offline-first personal finance app built on a **Hybrid-Modular Super App**
architecture (Clean Architecture + SOLID), organised as a Melos workspace of independent packages rather than one
monolith. The philosophy: *smart, effective, and disciplined spending*.

- Product spec: [`docs/BUSINESS_REQUIREMENT.md`](docs/BUSINESS_REQUIREMENT.md)
- Architecture rulebook (read first): [`AGENTS.md`](AGENTS.md)

## What the app does

| Area | Features |
|---|---|
| Transactions | Expense, income, wallet transfer and investment entry; custom keypad, quick-amount chips, smart suggestions |
| Smart Entry (AI) | Text, voice, camera and gallery receipt parsing (Gemini) into a preview the user confirms; batch save |
| Wallets | Liquid wallets (cash, bank, e-wallet), investment wallets with ROI, emergency fund |
| Reconciliation | Weekly audit: compare book vs. actual balance, auto-create adjustment slips, history and undo |
| Budgets | Per-category monthly limits, threshold notifications, anomaly detection, budget insights |
| Debts | Separate Lend and Liability flows, payments linked to wallets, repayment reminders |
| Reports | Weekly / monthly / yearly trends, category spending, financial runway, AI financial advice |
| Levels | LV1 → LV3 progression that unlocks Investment and Debt/Loan based on reconciliation streak, budgets and cash flow |
| Account & data | Phone / Google / Apple sign-in, guest mode, Hive local storage with automatic Firestore sync |

### Data & sync model

- Every save goes to local Hive storage first, so entry is instant and works offline.
- After each local write the repository calls `FinancialDataSyncService.syncAll()` (fire-and-forget, coalesced).
  Sync also runs when connectivity returns and on sign-in.
- The Profile tab shows the sync status and lets the user trigger `syncAll()` manually.
- Guests are local-only: nothing is uploaded until they sign in.

## Architecture

Four rigid layers, plus a bridge:

1. **App Shell** (`lib/`) — pure orchestrator: boot sequence, DI wiring, routing. No business logic or feature UI.
2. **Domain Features** (`modules/domain_features/`) — app-specific business verticals (transaction, wallet, budget,
   reconciliation, report, ...). This is where most of the code lives.
3. **Micro-Features** (`shared/cc_micro_features/`) — project-blind, reusable verticals (auth, biometric, crash log,
   messaging, splash, web) that can be dropped into another app unchanged.
4. **Shared Core** (`shared/cc_core_sdk/`, git submodule) — network, failures, logging, design system, mixins.
5. **Bridge** — cross-module contracts so features never depend on each other's concrete classes:
   - `cc_bridge/` holds the contracts (`*Coordinator`, `*Contract`, `*Provider`), e.g. `SessionContract`.
   - `modules/bridge/` holds the app-level `NavigationBridgeService` used by the shell to run post-boot tasks
     (user level init, data services, authenticated sync, reminders, tab refresh). The two are different
     packages with different jobs, not duplicates.

Presentation layers may use Bloc or GetX per feature; the core SDK and bridge stay state-management agnostic.

### Dependency rules (summary)

- `cc_micro_features` and `domain_features` must not import `lib/` or `modules/data_config`.
- `cc_micro_features` must not import `domain_features`.
- `domain/` and `data/` never import `presentation/`.
- Each feature defines its own `Repository` interface; the implementation is injected through DI.

The full, authoritative list is in [`AGENTS.md`](AGENTS.md).

## Project structure

```
flutter-get-starter-template/
├── lib/                          # App Shell: main*.dart, DI assembly, router, navigation bar
├── modules/
│   ├── domain_features/          # Business verticals: wallet, transaction, budget_limit, budget_allocation,
│   │                             #   reconciliation, liability, report, category, profile (+ user_level),
│   │                             #   comment, notification, firestore (sync), guideline, crashlog
│   ├── data_config/              # App-specific data implementations (network config, sync helpers, exchange rates)
│   ├── app_config/               # Env management, storage, DI discovery
│   ├── bridge/                   # NavigationBridgeService (app-level post-boot orchestration)
│   ├── theme/                    # Colors and typography (PrjColors, CcTextStyle, CcThemes)
│   └── message/                  # i18n strings (en.json, vi.json, CcLocaleKeys)
├── shared/
│   ├── cc_micro_features/        # auth, biometric, crash_log, messaging, splash, web
│   └── cc_core_sdk/              # GIT SUBMODULE: cc_sdk, cc_sdk_ui, cc_mixin, cc_sdk_data
├── cc_bridge/                    # Cross-module contracts (Coordinators, SessionContract)
├── docs/                         # Business requirements, onboarding, contributing, AI context
└── scripts/                      # Firebase setup, run scripts
```

## Naming convention (suffix-first)

`*_entity.dart`, `*_usecase.dart`, `*_repository.dart` / `*_repository_impl.dart`, `*_model.dart`, `*_page.dart`,
`*_bloc.dart` / `*_cubit.dart`, `*_state.dart` / `*_event.dart`; files are `lower_snake_case`.

## Quick start

```bash
git submodule update --init --recursive   # fetch shared/cc_core_sdk
melos bootstrap                            # bootstrap the workspace
melos run setup:firebase                   # generate local Firebase config from templates
melos run gen                              # build_runner: DI and serialization code
melos run analyze
melos run test
```

Run the app (flavor `prod`, entry `lib/main_prod.dart`):

```bash
flutter run -d <device> --flavor prod -t lib/main_prod.dart
```

Copy `env/.env.example` to `env/.env.prod` (git-ignored) and fill in your own values before the first run; the app
loads it at boot via `initEnv()`.

## Documentation map

- [`AGENTS.md`](AGENTS.md) — canonical architecture and workflow rules (also used by AI agents)
- [`docs/BUSINESS_REQUIREMENT.md`](docs/BUSINESS_REQUIREMENT.md) — product requirements and roadmap
- [`docs/onboarding.md`](docs/onboarding.md) — new-developer fast path
- [`docs/AI_CONTEXT.md`](docs/AI_CONTEXT.md) — rationale behind the architecture
- [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) — PR checklist and doc-sync obligations
- [`docs/CICD_SETUP.md`](docs/CICD_SETUP.md) — build and distribution setup
