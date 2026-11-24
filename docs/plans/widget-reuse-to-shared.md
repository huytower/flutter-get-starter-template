# Plan: move reusable widgets from `modules/` to `shared/`

Status: **approved** with the recommended choices (date picker on `MaterialLocalizations`, one bottom-sheet
implementation, micro-features included, one phase at a time). **All four phases done.**

Phase 4 differs from the table in three places:
- B1: the feedback tags (praise / criticism) name this app's features, so they stay in the app
  (`ProfileReviewOptions`) and reach the sheet through `AppReviewOptions`; the sheet also takes the store ids and
  the "N customer ratings" number from there. `AppRatingSheetContent` merged into `AppRatingSheet`.
- B2: the language sheet uses `CcSheetHeader` and Material's Cancel / OK, so its header is slightly smaller than
  before and the buttons read "Cancel" / "Hủy" (Flutter's wording).
- Guideline reset: `CcDialogHelper.showMessageBottomSheet` has no gradient header or icon, so that confirmation
  now looks like the app's other message sheets.

Phase 3 differs from the table in two places:
- A15 is named `CcProgressPie`, not `CcProgressRing`: it draws a filled wedge inside an outline, not a ring.
- A18: `RatingBarRow` was not moved. Nothing used it (and it showed a bare `%` instead of the percentage), so it
  was deleted with its `profile.star_count` string. `RatingPill` moved as `CcRatingPill`.

Phase 2 differs from the table in three places:
- A3/A4: `MoneyKeypadPanel` stays in the app as a ~50-line adapter over `CcKeypadPanel` (it adds the
  translations and the currency-formatted quick amounts its 6 callers share); `QuickAmountValues` builds the
  labels for it and for `PrjAmountInputSection`.
- A7: a new `CcSubmitButton`, not an extension of `CcBaseButton`. `CcBaseButton` is a gradient-list button with
  its own loading mode; adding badge, width factor, leading icon and gradient foreground to it would change its
  existing users.
- A8 also split out `CcCalendarMonthGrid` and `CcYearGrid` so each file stays under ~250 lines.

Phase 1 differs from the table in two names:
- A16 is a separate widget, `CcTwoColumnPair`, not a `CcTwoColumn.pair` constructor: the two layouts share only
  the `shouldUse` rule, and a const constructor could not pick the first / second card.
- A19 became `CcGradientBackground.page(child:)`, since the plain `CcGradientBackground` is a `Stack` child and
  every caller needed the same wrapper.

## Goal

`shared/` (the SDK `cc_sdk_ui` and `cc_micro_features`) should hold every widget another app could use as is,
so new projects start with them. `modules/` keeps only widgets that know this app's domain (money, wallets,
categories, budgets, debts, VIP).

Test for each widget (from the `flutter-core-sdk` skill): *would an e-commerce, health or education app use it
as is?* Yes → `cc_sdk_ui`. Yes, but it is a whole feature with data and strings → `cc_micro_features`. No → stays.

## Method

Every `presentation/` widget and helper in `modules/domain_features` (188 files, pages and controllers excluded) was scored by its imports and
names: domain entities, controllers / GetX / `getIt`, `PrjLocaleKeys`, `PrjColors`, and domain words. 60 files
have no entity or controller dependency; the ones below are the candidates after reading each one. `theme`,
`message`, `app_config`, `bridge` and `data_config` contain no widgets.

## A. Move to `cc_sdk_ui` (generic components)

| # | Today (`domain_features/lib/...`) | New SDK name | Callers | Change needed to be domain-free |
|---|---|---|---|---|
| A1 | `core/presentation/helper/adaptive_bottom_sheet.dart` (`showAdaptiveBottomSheet`) | `CcAdaptiveBottomSheet.show` | 30 | None. Then `CcDialogHelper.showModalBottomSheet` / `showMessageBottomSheet` use it, so the SDK has one sheet implementation |
| A2 | `core/presentation/widgets/quick_numeric_keypad.dart` | `CcNumericKeypad` | 3 | None |
| A3 | `core/presentation/widgets/money_keypad_panel.dart` | `CcKeypadPanel` | 7 | `clear` / `copy` / `done` labels become parameters; suggestions become `List<CcQuickValue>` (value + already-formatted label) instead of money `int`s |
| A4 | `core/presentation/widgets/prj_quick_amount_chips.dart` | `CcQuickValueChips` | 3 | Takes formatted labels; money formatting stays in the app (one small helper builds the labels) |
| A5 | `core/presentation/widgets/entry_form_container.dart` | `CcFormCard` | 8 | None |
| A6 | `core/presentation/widgets/entry_form_two_column.dart` | `CcFormTwoColumn` | 6 | Doc comment loses the transaction wording |
| A7 | `core/presentation/widgets/entry_submit_button.dart` | `CcSubmitButton` | 11 | Check first whether `CcBaseButton` (`allowShowLoading`, `hasEnable`) can take the missing parts (badge, width factor); extend it if so instead of adding a second button |
| A8 | `core/presentation/widgets/entry_date_picker_sheet.dart` + `entry_date_picker_content_sheet.dart` (443 lines) | `CcDatePickerSheet` | 2 | Month / weekday names and OK / Cancel come from Flutter's `MaterialLocalizations` instead of `intl` + `PrjLocaleKeys`, so the SDK needs no new dependency and no strings. Split into 2–3 files (rule 16) |
| A9 | `core/presentation/widgets/quick_date_row.dart` | `CcQuickDateRow` | 2 | `today` / `yesterday` / `time` labels become parameters |
| A10 | `core/presentation/widgets/base_asset_list_item.dart` | `CcEditableListItem` | 2 | None (header, stats, edit / delete / drag handle are already slots) |
| A11 | `core/presentation/helper/horizontal_row_reveal.dart` (`revealRowCard`) | `CcScrollReveal` | 4 | Drop `Get.context` (the SDK may not use `get`); take a `BuildContext` |
| A12 | `features/budget_allocation/.../compact_stat_row.dart` | `CcStatRow` | 2 | None |
| A13 | `features/profile/.../profile_settings_tile.dart` + `profile_menu_group.dart` | `CcSettingsTile` + `CcSettingsGroup` | 2 + 2 | None |
| A14 | `features/transaction/.../smart_entry_sheet_header.dart` | `CcSheetHeader` | 2 | None (title, subtitle, trailing). Not merged into `CcSectionHeader`, which is an icon + actions row |
| A15 | `features/budget_limit/.../budget_limit_pie_chart.dart` | `CcProgressRing` | 3 | None |
| A16 | `features/report/.../report_card_pair.dart` | `CcTwoColumn.pair` (named constructor) | 5 | Same rule as `CcTwoColumn.shouldUse`, so it belongs next to it |
| A17 | `core/presentation/widgets/category/prj_category_shimmer_list.dart` | `CcShimmerList` | 5 | Name only; it is a horizontal shimmer row, nothing category-specific |
| A18 | `features/profile/.../reviews/rating_bar_row.dart`, `rating_pill.dart` | `CcRatingBarRow`, `CcRatingPill` | 1, 2 | `star count` / `out of 5` labels become parameters |
| A19 | `core/presentation/widgets/prj_page_background.dart` | none: replace with `CcGradientBackground` | 4 | It is `CcGradientBackground` with fixed colours; add a `CcGradientBackground.page()` constructor if the call gets long |

## B. Move to `cc_micro_features` (whole features)

| # | Today | Target | Why a micro-feature, not the SDK |
|---|---|---|---|
| B1 | `features/profile/.../reviews_summary_card.dart`, `app_rating_sheet.dart`, `app_rating_sheet_content.dart`, `review_feedback_section.dart` | new feature `app_review` | Opens the store page (`url_launcher`), sends feedback through `CcFeedbackReporter`, has its own strings (`mf.review.*` in `CcMfLocaleKeys`). Store ids come in as parameters. Also fixes the `dart:io Platform` use (`defaultTargetPlatform`, safe on web) |
| B2 | `features/profile/.../language_selection_sheet.dart` + `language_selection_content_sheet.dart` | new feature `language` | Every app built on the template has the same language switch (`easy_localization`, already a `cc_micro_features` dependency); the language list comes in as a parameter |
| B3 | `features/profile/.../profile_delete_confirm_sheet.dart` | `auth` feature (`DeleteAccountConfirmSheet`) | Account deletion belongs to sign-in, which is already in `auth` (it even knows about Apple sign-in) |

`guideline_reset_bottom_sheet.dart` is a confirm sheet; it moves onto `CcDialogHelper.showMessageBottomSheet`
(after A1) instead of moving as its own widget.

## C. Stays in `modules/` (domain-shaped, on purpose)

`PrjCategory*`, `PrjWalletItem`, `AssetStatItem`, `PrjAmountInputSection`, `PrjVipLockBanner`,
`FinanceLineArtBackground`, `BudgetInsightCard`, `InvestPeriodIndicator`, `LiabilityDateRow`,
`OutstandingExceededHint`, the category-customize widgets, and all forms / pages. They know money, currencies,
categories, wallets, budgets, debts or VIP. They will be rebuilt on top of the new SDK pieces where that removes
code (for example `PrjAmountInputSection` on `CcKeypadPanel`).

Also out of scope: `ReceiptImagePickerHelper`. Receipt scanning was moved **out** of the SDK on purpose
(skill, "Known domain leaks"); a generic image picker in `cc_sdk_device` can be a separate proposal.
`ShimmerCommentCard` belongs to the `comment` demo feature and is not moved.

## Rules every move follows

- `Cc` prefix, file = type, `lib/src/widgets/<group>/`, exported from `export_cc_sdk_ui.dart`; `///` doc with a
  one-line example.
- No strings, no `message`, no `PrjColors`, no `get`, no `dart:io`: text comes in as parameters (or from
  `MaterialLocalizations`), colours from `context.ccColorScheme`.
- `cc_sdk_ui` keeps depending on Flutter only (no new package).
- No deprecation: each app copy is deleted and every caller switched in the same change (skill, "Stability and
  versioning"). No `Prj*` wrapper is kept unless it adds real app logic (A4's label helper is the one case).
- SDK `CHANGELOG.md` gets the additions under `## Unreleased` (they go out with the `3.0.0` already pending);
  app `CHANGELOG.md` gets one line per phase.
- Strings that become unused in `en.json` / `vi.json` / `PrjLocaleKeys` are removed in all three.

## Phases (one commit each, in this order)

Each phase is: SDK commit inside `shared/cc_core_sdk` (on `main`) → app commit that switches callers, deletes the
old files and bumps the submodule pointer. Nothing is pushed without your go-ahead.

| Phase | Items | Size | Why this order |
|---|---|---|---|
| 1. Foundations | A1, A16, A17, A19, A11 | small API, 30+ callers | Other moves (A8, B1–B3, sheets) depend on A1 |
| 2. Forms | A2, A3, A4, A5, A6, A7, A9, A8 | largest; touches every transaction form | Biggest reuse win; A8 last because it is the most work |
| 3. Lists and stats | A10, A12, A13, A14, A15, A18 | small, few callers | Independent, low risk |
| 4. Micro-features | B1, B2, B3, guideline sheet | new `cc_micro_features` folders + `mf.*` strings | Needs A1 and A18 |

## Checks per phase

- `melos run check:imports` (barrels, project-blind, no `get` in the SDK, naming) and `melos run analyze`.
- Widget tests for every new SDK widget in `cc_sdk_ui/test/widgets/` (pattern: `test/widgets/adaptive/`),
  including phone, tablet portrait and landscape sizes; existing `domain_features` tests stay green
  (`melos run test`).
- `rg "Colors\.|print\(" shared/cc_core_sdk/cc_sdk_ui/lib/src` stays empty.
- Manual test list for you (I do not run the app): transaction forms (keypad, quick amounts, date sheet, submit),
  wallet list edit mode, profile settings / rating / language / delete account, report cards on a landscape
  tablet.

## Expected result

About 33 files leave `domain_features` (about 3,300 lines today); `cc_sdk_ui` gains ~18 components and
`cc_micro_features` gains 2 features. `domain_features/core/presentation/` keeps only domain widgets.

## Decisions for you

1. **Date picker text (A8):** use Flutter's built-in `MaterialLocalizations` (recommended: no strings, no new
   dependency; Vietnamese month names follow Flutter's wording) or take every label as a parameter?
2. **Bottom sheets (A1):** one adaptive implementation in the SDK that `CcDialogHelper` also uses (recommended),
   or keep `CcDialogHelper`'s sheets as they are and only add the new one?
3. **B1–B3:** create the `app_review` and `language` micro-features now, or limit this plan to phases 1–3?
4. **Order:** phases one by one with a check-in after each (recommended), or all four in one go?
