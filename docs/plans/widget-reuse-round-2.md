# Plan: widget reuse, round 2

Status: **done** (R1–R4 approved with the recommended choices: one header size, Material Cancel / OK, weekday
names passed in).

What changed against this plan:
- `PrjCategoryChip` is **not** dead: `PrjCategoryGroupSection` uses it (the first scan only looked under
  `features/`). It stays.
- `ReconciliationSuccessSheet` / `ReconciliationUndoSheet` do not use the gradient frame (they are a banner and a
  centred confirm with an icon), so they were left as they are. That centred-confirm shape repeats in
  `DeleteAccountConfirmSheet`; a shared `CcConfirmSheet` could be a later step.
- The birth-year, weekly-day and display-name sheets were replaced outright in R3 (`CcYearPickerSheet`,
  `CcWeekdayPickerSheet`, `CcTextInputSheet`) instead of first moving them onto the frame in R2.
- `CcPickerSheetFrame` gained `hasScrollableBody` for sheets whose body scrolls by itself (reconciliation guide,
  report filter).
- R2 moved four app sheets (currency, reconciliation guide, report filter, receipt source) onto the frame,
  about 200 lines fewer; with R3's 590 deleted lines the app is about 800 lines lighter.

Round 1 (`widget-reuse-to-shared.md`) moved 33 widgets into `cc_sdk_ui` and three micro-features. This round
re-scans what is left in `modules/` with the same test: *would an e-commerce, health or education app use it as
is?*

## What the re-scan found

Every remaining `presentation/` file in `modules/domain_features` (pages and controllers excluded) was scored
again by its imports and names. Almost everything left knows the app's domain. The reuse that remains is mostly
**one repeated pattern**, plus three small pickers and the legal-document viewer:

- **8 bottom sheets repeat the same frame**: a primary-gradient header, a tinted body and (in 5 of them) a
  Cancel / OK row, each written out by hand with slightly different sizes (header radius 16 or 24, title
  `titleMedium` or `titleLarge`). Two shared sheets from round 1 (`CcDatePickerSheet`, `LanguagePickerSheet`)
  repeat it too.

  | Sheet | Lines | Cancel / OK |
  |---|---|---|
  | `BirthYearContentSheet` (profile) | 220 | yes |
  | `CurrencySelectionContentSheet` (profile) | 527 | yes |
  | `WeeklyAuditDayContentSheet` (profile) | 182 | yes |
  | `ReconciliationGuideContentSheet` | 222 | one button |
  | `ReconciliationSuccessSheet` | 176 | one button |
  | `ReportFilterPickerSheet` | 362 | no (tap to pick) |
  | `ReceiptSourceSheet` (transaction) | 124 | no (tap to pick) |
  | `DisplayNameSheet` (profile) | 105 | Save button |

- **Generic pickers hidden in profile**: birth year (a year grid), weekly audit day (a weekday list) and display
  name (one text field) know nothing about money.
- **`LegalDocumentView`**: shows a bundled bilingual HTML document in a web view. Any app has Terms and a Privacy
  Policy; `cc_micro_features` already has a `web` feature and the `webview_flutter` dependency.
- **Dead code**: `PrjCategoryChip` has no callers.

## Proposed moves

### A. `cc_sdk_ui`

| # | New | Built from | Notes |
|---|---|---|---|
| A1 | `CcPickerSheetFrame` | the frame above | `title`, optional `icon`, `body`, optional actions: Cancel / OK (labels from `MaterialLocalizations` unless given), a single button, or none. Scrolls in landscape, keeps clear of the system bars. One header size for all. |
| A2 | `CcYearPickerSheet` | `BirthYearContentSheet` | `CcPickerSheetFrame` + `CcYearGrid` (gains a `columns` parameter and scrolls to the selected year); optional hint text. |
| A3 | `CcWeekdayPickerSheet` | `WeeklyAuditDayContentSheet` | Weekday names come in as a parameter (Flutter only ships one-letter names, and `cc_sdk_ui` has no `intl`); first day of week like the date picker. |
| A4 | `CcTextInputSheet` | `DisplayNameSheet` | `title`, `hint`, `confirmLabel`, `initialValue`, `maxLength`; returns the trimmed text. |

Then `CcDatePickerSheet` and `LanguagePickerSheet` are rebuilt on A1, and the eight app sheets above keep their
content but use A1 for the frame. Expected: roughly 600 fewer lines in the app.

### B. `cc_micro_features`

| # | New | Built from | Notes |
|---|---|---|---|
| B1 | `LegalDocumentPage` in the `web` feature | `LegalDocumentView` | Takes the asset path, the title and a map from language code to the page's JavaScript switch (`{'vi': 'showVietnamese()'}`, default `showEnglish()`), so it is not tied to two languages. `TermsOfServicePage` / `PrivacyPolicyPage` stay in the app as 15-line routes; `domain_features` can then drop its `webview_flutter` dependency. |

### C. Clean-up

- Delete `PrjCategoryChip` (no callers).

## Stays in `modules/` (on purpose)

`FinanceLineArtBackground` (finance-themed art), `GuestLoginPromptSheet` (guest data and budget insight),
`AiConsentSheet` (Gemini wording and this app's privacy route), `ProfileSignInReminder` ("keep your financial data
safe"), `LiabilityDateRow` (too small to be worth an SDK type), `PrjCategory*`, `PrjWalletItem`, `AssetStatItem`,
`PrjAmountInputSection`, `PrjVipLockBanner`, the budget / reconciliation / report widgets, and the deliberate
adapters `MoneyKeypadPanel` and `QuickAmountValues`. `ReceiptImagePickerHelper` stays out of the SDK as decided in
round 1; a generic image picker in `cc_sdk_device` would be a separate proposal.

## Phases (one SDK commit + one app commit each, nothing pushed without your go-ahead)

| Phase | Items | Why this order |
|---|---|---|
| R1 | A1, then `CcDatePickerSheet` and `LanguagePickerSheet` on it | Proves the frame on the two shared sheets first |
| R2 | The eight app sheets on A1; delete `PrjCategoryChip` | Biggest line saving; no new API beyond A1 |
| R3 | A2, A3, A4 and switch profile to them | Small, independent pickers |
| R4 | B1 and drop `webview_flutter` from `domain_features` | Independent; touches pubspecs |

Checks per phase: `check:imports`, `flutter analyze` and tests in every touched package, new widget tests for each
new type, unused strings removed in all five languages, CHANGELOG entries. Manual test list given after each
phase.

## Decisions for you

1. **One look for every picker sheet (A1)**: the header becomes one size (16 dp radius, `titleMedium`), so the
   currency, reconciliation and display-name sheets get a slightly smaller header than today. OK, or keep a
   "large" header option?
2. **Cancel / OK text**: from Flutter's `MaterialLocalizations` (as the date and language sheets already do), or
   keep the app's own `common.cancel` / `common.ok` strings by passing them in?
3. **Weekday names (A3)**: passed in by the app (recommended), or add `intl` to `cc_sdk_ui` so the SDK can name
   weekdays itself?
4. **Scope**: all four phases, or only R1–R2 (the frame) for now?
