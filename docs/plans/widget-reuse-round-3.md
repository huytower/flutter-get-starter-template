# Plan: widget reuse, round 3

Status: **done** (S1–S4 approved with the recommended choices: Material Cancel label, rename now).

What changed against this plan:
- `ReconciliationUndoSheet` is never opened anywhere in the app (only its own `show` refers to it). It was kept
  and rebuilt on `CcConfirmSheet` so the undo flow still works if a button is added; deleting it, and
  `ReconciliationController.undoLast`, is a product decision.
- `DeleteTransactionSheet` is opened from `ReportTransactionTile`, a widget, not a page, so its two `getIt`
  lookups could not move to a page; the baseline count stays at 2. It became `confirmAndDelete(...)`, and the
  tile's result handling was removed because the old sheet always returned `null` (it closed with `pop()`).
- `CcConfirmSheet` gained `messageMaxLines` for the AI consent text (10 lines).
- `CcGradientAppBar` is a static `create(context, ...)` rather than a widget class: the bar's height scales with
  the window, and a `PreferredSizeWidget` cannot read a `BuildContext` for its size.
- Result: about 1,000 lines fewer across the app and `cc_micro_features`.

Rounds 1 and 2 (`widget-reuse-to-shared.md`, `widget-reuse-round-2.md`) moved the generic widgets and the
picker-sheet frame into `shared/`. This round looks for what is still repeated, using the same test: *would an
e-commerce, health or education app use it as is?*

## What the re-scan found

What is left in `modules/domain_features` is domain UI (money, wallets, categories, budgets, debts, VIP) except
for **one shape repeated nine times** and two small leftovers:

1. **The centred confirm sheet**: a round tinted icon, a bold title, a grey message, then Cancel and a coloured
   action button, each copied by hand (99–167 lines each, about 1,050 lines in total):

   | Sheet | Lines | Action |
   |---|---|---|
   | `WalletDeleteConfirmationSheet` (budget_allocation) | 116 | delete |
   | `BudgetLimitDeleteConfirmSheet` | 109 | delete |
   | `LiabilityDeleteConfirmSheet` | 99 | delete |
   | `DeleteTransactionSheet` (report) | 138 | delete (and runs the delete itself) |
   | `InvestmentDeleteConfirmSheet` (wallet) | 104 | delete |
   | `WalletDeleteConfirmSheet` (wallet) | 104 | delete |
   | `ReconciliationUndoSheet` | ~85 | undo |
   | `AiConsentSheet` (profile) | 128 | allow / decline, plus a Privacy Policy link |
   | `DeleteAccountConfirmSheet` (`cc_micro_features/auth`) | 167 | delete account, plus the account label |

2. **`SmsRegionPickerSheet`** (`cc_micro_features/auth`, 211 lines) still opens with Flutter's raw
   `showModalBottomSheet` and draws its own gradient header. It is the only sheet left that skips
   `CcAdaptiveBottomSheet`, so on a tablet it stretches to Material's full 640 dp instead of the 480 dp every
   other sheet uses.

3. **`buildDomainGradientAppBar`** lives in the SDK (`cc_sdk_ui`, file `gradient_app_bar.dart`) but carries the
   word "Domain" and is a top-level function, against the SDK naming rules (`Cc` prefix, file = type).
   15 files call it.

## Proposed moves

### A. `cc_sdk_ui`

| # | New | Notes |
|---|---|---|
| A1 | `CcConfirmSheet` | `icon`, `title`, `message`, optional `highlight` (a line shown in the tone colour, e.g. the account), optional `extra` widget (e.g. a link), `confirmLabel`, `cancelLabel` (default `MaterialLocalizations` Cancel), `tone`: destructive (error colours) or primary. `CcConfirmSheet.show(...)` returns `true` when confirmed, `false` / `null` otherwise; the caller then runs its action. Opened with `CcAdaptiveBottomSheet`, scrolls in landscape. |
| A2 | `CcConfirmTone` | `destructive` / `primary` (own file, file = type). |
| A3 | `CcGradientAppBar` | Replaces `buildDomainGradientAppBar` (same look and parameters), as a `PreferredSizeWidget` class in `cc_gradient_app_bar.dart`. Breaking rename, listed under `### Breaking` with the one-line migration; all 15 callers switched in the same change (no deprecation, as the SDK rules say). |

### B. Adopt in the app and `cc_micro_features`

- The nine sheets above become `CcConfirmSheet.show(...)` calls. Each keeps its own texts (all already
  translated), so no strings move. Expected: about 1,050 lines down to about 250.
  - The six delete sheets and `ReconciliationUndoSheet` become a few lines each where they are opened; the
    files go away unless a sheet carries real logic.
  - `DeleteTransactionSheet` keeps a thin wrapper, because it also runs the delete and the refresh. Its two
    `getIt` lookups (frozen debt in `scripts/check_imports_baseline.txt`) move to the page that opens it, so the
    baseline count for the widget goes down.
  - `AiConsentSheet` keeps its `ensure(...)` logic (it remembers the answer) and passes the Privacy Policy link
    as `extra`, with tone `primary`.
  - `DeleteAccountConfirmSheet` stays the public name in `auth` (apps call it), built on `CcConfirmSheet` with
    the account as `highlight`.
- `SmsRegionPickerSheet` opens with `CcAdaptiveBottomSheet` and uses `CcPickerSheetFrame` with
  `hasScrollableBody` (its region list scrolls), so it gets the tablet width cap and the shared header.

## Stays where it is

Everything else in `modules/` is domain UI or a deliberate app adapter (`MoneyKeypadPanel`,
`QuickAmountValues`, `ProfileReviewOptions`, `LegalDocumentScripts`). `ProfileSignInReminder`,
`GuestLoginPromptSheet`, `FinanceLineArtBackground`, `CategoryCustomizeEmptyState` (built on a category tile) and
`ReconciliationSuccessSheet` (a timed banner) stay. After this round the re-scan finds nothing further worth
moving.

## Phases (one SDK commit + one app commit each; nothing pushed without your go-ahead)

| Phase | Items | Why this order |
|---|---|---|
| S1 | A1, A2 + the six delete sheets and the undo sheet | One new widget proves itself on the plainest cases |
| S2 | `AiConsentSheet`, `DeleteAccountConfirmSheet`, `DeleteTransactionSheet` | The three with extras (link, label, own logic) |
| S3 | `SmsRegionPickerSheet` on the frame | Independent, small |
| S4 | A3 `CcGradientAppBar` rename across 15 files | Mechanical; last so it does not mix with behaviour changes |

Checks per phase: `check:imports`, `flutter analyze` and tests in every touched package, widget tests for
`CcConfirmSheet` (both tones, highlight, extra, confirm / cancel results), CHANGELOG entries, manual test list.

## Decisions for you

1. **Cancel label** on the confirm sheets: Flutter's `MaterialLocalizations` ("Cancel" / "Hủy", like the picker
   sheets now), or keep the app's `common.cancel` by passing it in?
2. **S4 rename**: do it now (recommended; the SDK's next release is already a breaking `3.0.0`), or leave
   `buildDomainGradientAppBar` as is?
3. **Scope**: all four phases, or S1–S3 only?

(The nine sheets already share one look: 28 dp icon, `titleLarge` title. `CcConfirmSheet` keeps it, so they
should look the same as today apart from the Cancel text if decision 1 goes to Material.)
