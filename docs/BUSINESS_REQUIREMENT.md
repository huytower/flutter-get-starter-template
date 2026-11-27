# Business Requirement - Personal Finance Management (Sổ Sách Xịn)

> **How to read this document.** It describes what the app does today, verified against the code, plus what is
> still planned. Each roadmap item carries a status:
> **[Done]** implemented · **[Partial]** implemented with gaps described inline · **[Undone]** required but not
> implemented yet (a known gap to close) · **[Planned]** a future feature, no code yet.
> When behaviour in the app and this document disagree, treat it as a bug in one of them and fix it.

## 1. Overview
The Sổ Sách Xịn (Quản Lý Tài Chính) application is a modular personal finance management system designed with the philosophy: **"Smart, Effective, and Disciplined Spending"**. It helps users track income/expenses, manage multiple wallets, maintain a financial "survival" runway, and use AI for fast data entry and advice.

**Reference:** https://app-qltc.vercel.app/dashboard

**App shape:** three bottom tabs — **Budget Allocation** (wallets, investments, debts, budgets, insights) · **＋ Transaction** (centre, default tab) · **Profile**. Reports open from the Transaction tab header.

## 2. Roadmap

> **Phases are delivery order, not access levels.** A phase says *when* a feature was (or will be) built. Who
> can use it is decided only by the access rules in §3 (level **or** VIP, plus AI consent where relevant), noted
> in brackets after each item. Many features built in a later phase are open to everyone (LV1).
>
> **[Undone]** marks work that is required but has not been implemented yet; **release blocker** marks what must
> be done before the next store release.

### Release blockers (must be done before the next store release)
- [Undone] **Emergency Fund ebook** — the "read the guide" link (`emergencyFundEbookUrl`) is still a placeholder
  (`https://example.com/terms-of-service`). The real guide must be written, hosted and linked; until then
  opening it is a fake step in the Emergency Fund unlock (§6).
- [Partial] **Store privacy declarations** — every answer is written in `docs/STORE_PRIVACY_LABELS.md`. Still to
  do by hand: enter them in App Store Connect (App Privacy) and Play Console (Data safety), with the
  account-deletion web link https://app-qltc.vercel.app/delete-account (§5 Privacy). The iOS privacy manifest
  (`PrivacyInfo.xcprivacy`) and the Android permission clean-up are [Done].
- [Done] **iOS location purpose strings** — `Info.plist` and the `en` / `vi` `InfoPlist.strings` now say the place of
  each expense is saved and backed up; the unused "Always" key is removed (§5 Privacy).

### Phase 1 — MVP
- [Done] Core transaction management: Income, Expense, Transfer *(everyone)*
- [Done] Wallet management: Cash, Bank, e-Wallet *(everyone)*
- [Done] Basic reporting: weekly / 3-month charts *(everyone)*
- [Done] Category management with personalization *(everyone)*
- [Partial] "Frequently Used" quick access — delivered as quick-amount chips and smart suggestions (see §6 AI
  Integration); there is no separate "frequently used" section *(everyone)*
- [Done] Weekly audit/reconciliation system *(everyone)*
- [Done] Level progression system (§8)

### Phase 2
- [Done] Smart Budgeting with warning system *(everyone)*
- [Done] Smart Suggestions: time-based, merchant match, recurring monthly bill *(everyone)*; location-based
  *(LV3 or VIP)*
- [Done] Enhanced reporting with yearly views *(everyone)*
- [Done] Financial Runway *(everyone)*
- [Partial] Spending optimization recommendations — local budget insights *(everyone)*; AI advice narrative
  *(VIP + AI consent)*
- [Partial] AI-powered Smart Entry (NLP, Autofill) *(LV3 or VIP, + AI consent)* — today **VND book only**
  (Vietnamese/English); other currencies [Planned]; reusable templates are [Undone]
- [Partial] Emergency Fund wallet *((LV3 and ebook viewed) or VIP)* — the ebook is a release blocker (above)
- [Done] Investment tracking *(LV2 or VIP)*
- [Undone] Financial Freedom Index — no code; "passive income" is not defined yet (§6)

### Phase 3
- [Done] Debt & Loan Management: separate Lend and Liability tabs *(LV3 or VIP)*
- [Done] Advanced AI: receipt image from camera/gallery, voice input *(LV3 or VIP, + AI consent)*
- [Done] Budget estimation: suggested limit from the last 3 months' average spend *(everyone)*
- [Partial] AI-powered warnings and actions — warnings computed locally *(everyone)*; AI advice
  *(VIP + AI consent)*
- [Done] Multi-currency: VND, USD, JPY, EUR, KRW, CNY, one book currency with exchange-rate conversion
  *(everyone)* — except AI Smart Entry, which is VND-only for now
- [Planned] AI Smart Entry for every app currency (USD, JPY, EUR, KRW, CNY): amount parsing, quick-amount
  datasets and prompts per currency; then drop the VND-only gate (§6 AI Integration)
- [Planned] Enhanced animations as a dedicated theme style

### Phase 4
- [Partial] App Store deployment — CI ships to Google Play alpha and TestFlight (see `docs/CICD_SETUP.md`);
  blocked by the release blockers above
- [Planned] Paid VIP (in-app purchase) to shorten the level path — the Profile "Unlock Invest, Liability, AI
  (experiment)" switch will then be hidden (see §3)
- [Planned] Google Ads banner integration
- [Planned] Gaming theme layout option
- [Planned] Online ebook with AI language translation

### Phase 5
- [Planned] Community chat tab (when monthly active users reach 1000)

### Known limitations (accepted for now, improvement planned)
- [Planned] **Runway early in the month** — the average-spend fallback counts the current month as a full month,
  so on the first days of a month the runway looks longer than it is (§6 Financial Runway).
- [Planned] **Weekly chart vs. audit cycle** — the "Weekly" chart uses rolling 7-day buckets over the last 28 days,
  not the user's 7-day audit cycles (§4.C, §4.D), so a chart "week" and a reconciled cycle can cover different
  days.
- [Planned] **Simple ROI** — ROI is total returns ÷ total contributed capital (§6 Investment Tracking): no market
  value, no time weighting, and capital taken back is recorded as a return, which inflates ROI.

## 3. Access Model: Levels, VIP and Guests

| Capability | Requirement |
|---|---|
| Expense, Income, Transfer, wallets, budgets, reconciliation, reports | Everyone (LV1) |
| Investment tab and investment section | LV2 **or** VIP (two independent paths, see below) |
| Creating a new investment position | LV2 or VIP, from the Investment tab; without VIP the position takes the category's default name. A custom name, and creating from the add sheet on the Budget Allocation page, require VIP |
| Debt/Loan (Liability and Lend tabs) | LV3 or VIP — still locked at LV2 |
| AI Smart Entry (text, voice, camera, gallery) | (LV3 or VIP) **and** AI data-sharing consent **and** onboarding guideline complete **and** book currency **VND** with app language Vietnamese or English. Other currencies: [Planned] (see §6 AI Integration) |
| Emergency Fund wallet type | (LV3 **and** ebook viewed) or VIP |
| AI financial advice in Reports | VIP **and** AI data-sharing consent |

- **Two independent unlock paths.** Every gated feature opens either by **level** (earned through §8) or by
  **VIP** (an account entitlement). The paths do not depend on each other and do not conflict: reaching LV2
  opens the Investment tab for a non-VIP user, and a VIP user has it from LV1. LV2 opens **only** the
  Investment tab; the Liability and Lend tabs stay locked until LV3 or VIP. In code the level/VIP part of each
  gate is one getter on `UserLevelStatusEntity` (`canUseInvestment`, `canUseLiability`, `canUseAiSmartEntry`)
  of the form `level >= N || hasVip`. Some features add conditions on top of that getter (see the table):
  - **AI Smart Entry**: `canUseAiSmartEntry` **and** AI data-sharing consent **and** onboarding guideline
    complete **and** book currency VND with app language Vietnamese or English.
  - **AI advice**: VIP **and** AI data-sharing consent.
  - **Emergency Fund wallet**: (LV3 **and** ebook viewed) or VIP (`EmergencyFundAccess`).
- **VIP ("Unlock Invest, Liability, AI (experiment)")**: today a manual switch in the Profile tab. Turning it on shows level 3 on the
  Profile badge and enables all investment and debt categories; the earned level is unchanged. Its default comes
  from the `ENABLE_VIP_MODE` environment flag. The VIP flag belongs to the account and is synced with it (see §5).
  - **The free switch is temporary** (development / QA and early users). Until paid VIP ships, the fact that
    anyone can use it to skip the level path is a known, accepted state, not a bug.
  - [Planned] **Paid VIP**: the switch will be hidden from users, and VIP will be bought (in-app purchase) to
    shorten the path to higher levels. There is no in-app purchase or billing yet.
  - **Storage, ready for paid VIP**: the free switch and paid VIP are stored apart — `hasVip` (Hive field 14,
    synced with the account settings) holds the switch, `hasPaidVip` (Hive field 32, set only by the future
    purchase check, never synced from the device) holds paid VIP. VIP access = paid **or** switch. Hiding the
    switch later only stops reading `hasVip`; no data migration, and installs without either field load as
    "not VIP".
  - **Paid VIP belongs to the account that bought it**: both flags are cleared on the device whenever another
    account or a guest takes it over (§5 Account switch), so a purchase never carries over to someone else.
- **Guests**: the app is fully usable without an account; data stays on the device. A guest is prompted to sign in after 8 stored financial records and again (final warning) at 15, and receives one local notification 14 days after first launch if still not registered.
  - **Signing in discards the guest's local data.** Guest records and guest profile progress (level, guideline, audit day, birth year) are never uploaded; the signed-in account starts from its own cloud data, or empty. Both prompts say so explicitly. This is deliberate: the prompts push users to create an account early, so that serious money management starts on an account that is backed up from day one.
- Level rules are in §8.

## 4. Core Business Processes

### A. Initialization & Setup
- **Guided onboarding ("Guideline")**: a checklist with badges pointing at the next step. LV1 tasks (6): set birth year, review categories, set wallet balance, create a budget limit, mark a minimum-living (fixed-price) budget, record the first transaction. Two more tasks appear once unlocked: first investment, first liability. Completing the 6 LV1 tasks is a condition for LV2; only those 6 count, so the investment task (open early to VIP) cannot stand in for a missing LV1 task. The tutorial can be restarted from Profile.
- **Wallet Declaration**: Users define wallets (Cash, Bank, e-Wallet).
- **Initial Balance**: Set the starting amount for each wallet.
- **Budgeting**: Define monthly spending limits for specific categories (e.g., Food, Shopping).
- **Year of Birth Selection**: Drives age-based defaults for categories and suggestions.
- **Category Personalization**: Enable/disable categories. Defaults follow the age group derived from birth year (under 23, 23–30, 31–45, over 45). Family/children categories (milk, diapers, baby toys) default on from age 30 by age alone. Once the user customizes categories manually, age-based defaults no longer override their choices.

### B. Daily Transaction Management
- **Immediate Entry**: Encourage users to record transactions within 5 seconds of occurrence.
- **Transaction Types** (as stored):
    - **Income (Thu)** and **Expense (Chi)**: expense is linked to a Category and, when one exists, a Budget.
    - **Transfer (Điều chuyển)**: two linked legs (out/in) between wallets. Started from the wallet area (transfer sheet), not from a Transaction tab. Excluded from income/expense reports.
    - **Investment (Đầu tư)**: *Chi ra* (capital contribution, two linked legs from a liquid wallet to the investment position) and *Thu vào* (return/profit).
    - **Debt/Loan (Vay/Nợ)**: Borrow, Lend, Repay, Collect — each tagged with its liability record.
    - **Emergency Fund**: not a transaction type. The Emergency Fund is a wallet; using it is an ordinary expense or transfer from that wallet.
- **Correcting entries**: income, expense, debt/loan and investment entries can be edited only within **30 days** of their date. Transfers cannot be edited. Deletes are soft deletes.
  - **Soft delete, synced.** A deleted transaction keeps a `deletedAt` stamp and is marked pending, so the delete
    reaches the cloud like any edit — also when made offline — and a later pull cannot bring it back.
  - **A Chi ra is one entry with two legs** (`investmentOut` on the liquid wallet, `investmentIn` on the position,
    same `transferId`). Deleting or editing it in the Report always applies to **both legs** (`TransactionLegs`):
    a delete refunds the liquid wallet **and** removes the contribution from the position and ROI; an edit
    rewrites the mirror leg's amount (converted to its currency), date, category and note. The lock below is
    checked on both legs. Edits keep the entry's link to its position (`investmentWalletId`).
  - Debug trace: `[DeleteTransaction]` / `[UpdateTransaction]` log every leg with its `RECONCILED` / `open` state.
  - **Reconciled entries are closed.** A transaction dated at or before the latest reconciliation is part of the balances that reconciliation confirmed, so it can no longer be edited or deleted (in edit mode the Report shows an **info** button instead of the edit/delete buttons; tapping it opens a bottom sheet "Already reconciled" with bullets (`ReconciledTransactionSheet`, styled like the reconciliation guide): why it is locked, which balances a change would break, and to add an offsetting transaction — `transaction.reconciled_title` / `transaction.reconciled_info_*`; the save/delete is refused in the use cases too). Only unreconciled transactions — dated after the latest reconciliation — can be edited or deleted, still within the 30-day window.
  - **To correct a reconciled entry, add a new transaction** that offsets it, with a matching reason in its note (e.g. an income "Hoàn lại — nhập nhầm chi 50k ngày 20/11"). This does not conflict with the lock: the closed period stays as it was confirmed, and the correction is recorded, and later reconciled, in the open period.
  - **The lock follows the transaction's date, not when it was entered.** A new entry back-dated into a reconciled period is locked as soon as it is saved, so check it before saving; a later mistake in it is again corrected with another offsetting entry. Entries dated today (the default) stay editable: an entry for today is stamped with the moment it is saved (`EntryDate.recordedAt`), not the time its form was opened, so it is never dated before a reconciliation made earlier that day. A form left open overnight moves its untouched date on to today when the keypad opens.
  - Undoing the latest reconciliation (§4.C) re-opens its transactions for editing, back to the previous reconciliation. This is an **allowed** way to fix an entry in the last closed period: undo, edit, then reconcile again. It reaches only that one period, and it has a cost: if the cycle is already over, the new reconciliation falls in the current cycle, so the old cycle loses its reconciliation and the streak (§8) can break.

- **Sticky wallet choice.** The liquid wallet used for an entry stays selected after saving, is preselected in
  every entry form (Expense, Income, Investment, Liability, Lend) and is remembered across app launches. If that
  wallet no longer exists, the first one is selected. Editing an old entry keeps that entry's wallet and does not
  change the remembered one. Stored on the device, cleared when another account or a guest takes it over.

**Transaction Entry Flow (Normal):**
1. User opens App → lands on the Transaction tab → enters amount in "Chi tiền"
2. Number keypad doesn't auto-open; user picks a quick-amount chip or types on the in-app money keypad
3. Quick amounts are per currency (VND: 10k … 2tr; USD/EUR: 1 … 100; JPY, KRW, CNY have their own sets)
4. Press "Lưu" (Local save)
5. App remains open

### C. Reconciliation & Audit (Weekly)
- **Financial Audit (Kiểm toán)**: Compare book balances with actual cash/bank balances.
- **Scope**: all wallets except investment positions (an investment's book balance is contributed capital, nothing to count). The Emergency Fund is reconciled like any other wallet.
- **Adjustment Slips**: generated automatically for every mismatch when the reconciliation is confirmed.
- **Reconciliation record**: each reconciliation stores its date (which audit cycle it belongs to is worked out from that date and the audit day), an ISO year/week label, per-wallet book and actual balances, totals, the difference and the ids of the adjustment slips. This record is the weekly snapshot; there is no separate snapshot entity.
- **Weekly audit day**: the user picks a fixed weekday in Profile (default Sunday). Changing it resets level-streak counting (see §8).
- **Audit cycle**: the 7 days that **end on the audit day**, that day included. Audit day Sunday → Monday–Sunday; audit day Wednesday → Thursday–Wednesday. When the 7 days are over, a new cycle starts, whether or not the user reconciled.
- **One reconciliation per cycle**, on any day of the cycle. Reconciling early is allowed and keeps the books correct, because the next reconciliation still compares the real balances with the book.
  - Once the cycle is reconciled, the next one opens only the day after the audit day. Example with audit day Sunday: reconciled Saturday 28/11 → blocked on Sunday 29/11 → open again from Monday 30/11 for the cycle 30/11–6/12 → after reconciling in that cycle, open again only after Sunday 6/12.
  - When blocked, tapping "Kiểm toán" shows a bottom sheet instead of the page: the day the user reconciled, the next window ("from Monday 30/11 to Sunday 6/12") and the reason (one closing per cycle keeps each week's figures separate and the streak correct). The sheet offers "View history" and "Got it". "View history" opens the page showing **only the reconciliation history**: no wallet counting, totals or confirm button, so no second reconciliation can be started until the cycle ends. The page switches to the same history-only view as soon as a reconciliation is confirmed.
  - The history-only view has an **Undo** button on the latest record only. After a confirmation it deletes that reconciliation and its adjustment slips, re-opens the cycle (the full page comes back) and reloads balances, entries and the report. It is offered only while the cycle is closed, so a reconciliation from an earlier cycle cannot be undone.
  - **Changing the audit day re-opens reconciliation at once.** If the user picks a new audit day in Profile while the cycle is closed, they can reconcile immediately, and the waiting period starts over from the new day. A reconciliation made before the change no longer closes a cycle. We deliberately don't block someone who chose a new audit day (good UX); there is no streak to gain, because the change also restarts the streak.
  - Undoing the latest reconciliation re-opens its cycle.
- **Reminders** (local notifications, only if the "Reminder" switch in Profile is on):
  - At most 2 per cycle: 09:00 the day before the audit day and 09:00 on the audit day.
  - Both are cancelled as soon as the current cycle is reconciled (no repeat reminders). They are re-checked on app launch and right after each reconciliation or undo.

**Reconciliation Flow:**
1. User enters "Actual Balance" for each wallet (wallets left untouched are assumed to match)
2. System calculates the difference between "Book Balance" and "Actual Balance"
3. On confirm, for each mismatch an adjustment transaction is created on that wallet:
   - Book > Actual → **Expense** (note "Khớp sổ - Điều chỉnh hao hụt")
   - Actual > Book → **Income** (note "Khớp sổ - Điều chỉnh dôi dư")
   - Category label: "Điều chỉnh khớp sổ"
4. The reconciliation record is saved. If any step fails, the adjustments already created are rolled back.
5. **Undo**: the most recent reconciliation can be undone, which deletes its adjustment transactions and the record, and re-opens the transactions it had closed (§4.B Correcting entries).
6. Navigation: For each wallet, icon button to review income/expense transactions filtered by wallet

### D. Chart & Reporting Specifications

**Income vs Expense Comparison Chart** (tabs: Weekly · 3 Months · Year)

| View Type | Data Points | Time Labels | Navigation |
|-----------|-------------|-------------|------------|
| **Weekly** | 4 points (last 28 days, 7-day buckets) | "Week 1" … "Week 4" | None (always current) |
| **3 Months** | 3 points (calendar months) | `M/yy` (e.g. 5/26, 6/26, 7/26) | Steps of 3 months, up to 4 steps back (12 months) |
| **Year** | 12 points (calendar months) | `M/yy` | Steps of 12 months, 1 step back |

**Known limitation** (§2): a "Week" in the chart is a rolling 7-day bucket counted back from today, not the user's
audit cycle (§4.C). [Planned] align the weekly buckets with the audit cycles, so a chart week matches a reconciled
cycle.

**Other report content**: category spending breakdown, daily transaction list with filters and quick edit/delete (unreconciled transactions only, see §4.B), Financial Runway card, investment trend, loan and liability trends, AI financial advice (VIP **and** AI data-sharing consent; locked under `CcLockOverlay` without consent, §6).

## 5. Technical Specifications

### Libraries & Packages
- **Charts**: `fl_chart`
- **Icons**: Material icons stored per category as icon code + family (font-based, no PNG)
- **Notifications**: `flutter_local_notifications` (local scheduling; no server push is used for reminders)
- **Fuzzy matching**: `string_similarity` (merchant matching)
- **Storage**: `hive_ce`; **Cloud**: Firebase Auth + Cloud Firestore
- Not used (earlier plan): `font_awesome_flutter`, `animations`, `hotspot`, `scroll_snap_list`

### Mobile App Architecture
- **Offline First**: Local database is Hive (`hive_ce`); Firestore is the cloud backup
- **Local Save First**: All saves execute locally first (instant success), then sync in the background
- **Automatic Sync (Push)**: Every local write (transaction, wallet, budget, category, reconciliation, liability,
  account settings)
  triggers `FinancialDataSyncService.syncAll()` fire-and-forget after the local save succeeds. Rapid bursts of
  writes are coalesced into at most one extra pass. Sync only runs for signed-in users with internet access;
  guests stay local-only and nothing is uploaded.
- **Automatic Sync (Triggers)**: `syncAll()` also runs when connectivity returns while records are pending, and
  on sign-in / account switch (push the account's own pending records first, then pull and merge from Firestore).
- **Manual Sync**: The sync indicator in the Profile tab lets the user force `syncAll()` by hand. It is tappable
  only when there are pending records and the device is online; it is a safety net, not the primary sync path.
- **Account settings sync**: the settings that belong to the account — highest level reached, VIP flag, guideline progress, weekly audit day (and when it changed), birth year, book currency (and whether it was detected or chosen by the user), level start date, emergency-fund ebook viewed, customized categories — are stored in Firestore at `users/{uid}/profile/settings` and follow the account to every device. They sync like financial records (pushed after each change, counted as pending, pulled on sign-in before the financial data so the book currency is right when the records arrive). When both the device and the cloud changed, each field keeps the side that changed it; the highest level is the larger of the two, so a level never drops.
- **Device settings stay local**: theme, reminder switch, tutorial seen, first-launch and backup-reminder stamps, AI data-sharing consent and the detected region are per device and are not synced.
- **Account switch / logout**: when another account (or a guest) takes over the device, the previous owner's financial data **and** account settings (VIP switch and paid VIP included) are cleared before the new account's are loaded, so nothing carries over between accounts.
- **Deletes reach the cloud.** Deleting a wallet, budget, category or liability, or undoing a reconciliation,
  removes the record on the device at once and queues its Firestore document (`PendingCloudDeletes`, stored on
  the device). Online, the next `syncAll()` deletes it in Firestore right away (a wallet is deleted at once when
  online); offline, the delete waits and is applied as soon as the device is back online. Until then the pull
  skips the queued documents, so a deleted record never comes back after a restart or sign-in, and queued
  deletes count as pending (sync badge, logout guard). Transactions use soft delete (a `deletedAt` stamp that
  syncs like any edit). Signing out after a verified sync, or another account taking the device over, clears
  the queue together with the local data.
- **Logout safety**: logout is blocked while the device is offline or records (including account settings and queued deletes) are still pending upload, so local data cannot be lost by signing out.
- **Data Caching**: Category and wallet lists are read from local storage - no API fetch on every screen open
- **Performance Target**: Transaction entry must be fast and easy

### Home Screen Widgets
- [Planned] **Android/iOS Widgets**: Display balance and 2 quick buttons: [+ Chi] and [+ Thu]

### UI/UX Guidelines
- **Minimal Text**: Use icons extensively, very little text
- **Number-Only Input**: Accounting operations only allow numbers
- **Keyboard**: In-app money keypad for amount entry
- **Image Optimization**: Font icons for categories instead of PNG
- **Loading**: shimmer placeholders for wallet and transaction cards. [Partial] a few screens still use `CircularProgressIndicator`.

### Authentication System
- **Sign-in methods**: Phone number (OTP), Google, Apple. Guest (no account) is the default starting state.
- **Account Linkage**: phone, Google and Apple can be linked to the same user
- **Profile Editing**: Edit display name
- **Sync Status Indicator** (Profile tab, driven by `isOnline`, `isSyncing`, `pendingCount`):
  - Offline: cloud-off icon with a warning badge (not tappable) — data is safe locally but not backed up yet
  - Syncing: spinner (not tappable)
  - Pending records while online: cloud-sync icon with a badge and the pending count in the tooltip; tap to
    sync manually
  - Fully synced: cloud-done icon (not tappable)

### Theme Options
- **Light/Dark Mode**: follows the system until the user sets it in Profile
- [Planned] **Style Variants**: Minimal Style / Game Style

### Localization
- **Languages**: Vietnamese (default), English, Japanese, Korean, Chinese
- **Currencies**: VND (default), USD, JPY, EUR, KRW, CNY
  - **One book currency.** The whole book (wallets, transactions, budgets, liabilities, reconciliations) is kept in the primary currency chosen in Profile; the initial choice is detected from the device region/locale (or GPS country, see Privacy below). Amounts are added and subtracted as typed, with no conversion.
  - **Whole units only — no cents, no decimals.** Every amount is an integer number of units of the book currency, in every currency: USD 4.99, EUR 0.50 or CNY 12.80 cannot be recorded (enter 5, 1, 13). This is a deliberate product limit, kept on purpose: a book without fractions adds up exactly, but any conversion between currencies has to round, which is where figures drift (see next point).
  - **Changing the primary currency converts the whole book once** at the current rate. The user is asked to confirm first; the confirmation sheet (`CurrencyConvertSheet`) lists the conversion and rounding rules below as bullets, styled like the reconciliation guide.
    - Each converted amount is rounded to the nearest whole unit.
    - **A non-zero amount never becomes 0**: anything under 1 unit after conversion is rounded **up to 1 unit** (−1 for a negative balance), in every currency — e.g. 10,000 đ ≈ USD 0.39 is recorded as **1 USD**; 5 JPY ≈ USD 0.03 → 1 USD. Without this rule small entries would silently vanish from the book.
    - Because of rounding (and the 1-unit floor), converting back does **not** restore the original values: VND → USD → VND turns 10,000 đ into 1 USD and back into ~26,000 đ. Totals can therefore differ slightly from the original after a conversion; this is accepted. Users who switch currency often should expect it.
    - The same rule applies wherever an amount is converted (book conversion, entries made in another currency, display totals): one shared function, `WholeUnitRounding`.
  - **Exchange rates** come only from the Frankfurter API v2 (`api.frankfurter.dev/v2/rates`), which covers all six currencies, VND included. Rates are cached locally. Offline, the last cached rates are used and marked as stale; with no cached rate the conversion is not done. No rate is ever hard-coded or estimated.

### Privacy: Location Data
**What is collected (today's behaviour):**

| Use | When | What is kept | Where it goes |
|---|---|---|---|
| Currency suggestion | First launch, only while the currency is still "detected" (not chosen by the user) | The **country code** only (device setting) | Stays on the device; coordinates are not kept |
| Location-based suggestion (§6) | Opening the Expense form, **only for users with AI Smart Entry access (LV3 or VIP)** | The **precise** coordinates (latitude/longitude, high accuracy) saved on each new **expense** made while a fix is available | Stored with the transaction in Hive, and for signed-in users **uploaded to Firestore** (`users/{uid}/transactions`) like the rest of the transaction; deleted with the transaction / account. Guests: device only |

- **Permission**: the OS "while using the app" location prompt appears the first time a position is needed (first currency detection or the first Expense form for an LV3/VIP user). Denying it is fully supported: no coordinates are saved, the currency falls back to the device region, and location suggestions are off. There is no separate in-app switch today; the user manages it in the device Settings.
- **Purpose**: location is used only for the two features above. It is not used for ads, analytics or sharing with third parties, and is never sent to Gemini.

**Required disclosures (must be true before each store release):**
- [Done] **In-app Privacy Policy** (`assets/legal/privacy_policy.html`, updated 26/11/2026, Vietnamese and English): two location rows — country detection (only the country code kept, on the device) and precise location attached to expenses (LV3/VIP, stored with the expense, backed up to the user's cloud account, deleted with the transaction or account, not used for ads/tracking, not shared, never sent to AI); the rights section says new expenses carry no coordinates once the location permission is off. Keep it in sync with the table above whenever location use changes.
- [Partial] **Release blocker.** **App Store privacy label** and **Google Play Data safety** form: the full answers
  (every data type, linked or not, purpose, optional/required, no tracking, nothing shared) are in
  `docs/STORE_PRIVACY_LABELS.md`. Left to do by hand in the store consoles: enter them, and give Play the
  account-deletion web link **https://app-qltc.vercel.app/delete-account**. Keep that file, the privacy policy,
  `ios/Runner/PrivacyInfo.xcprivacy` and this section in step.
- [Done] **iOS privacy manifest** `ios/Runner/PrivacyInfo.xcprivacy` (registered in the Runner target): no
  tracking, the collected data types of the App Store label.
- [Done] **Android permissions**: shared-storage permissions (`MANAGE_EXTERNAL_STORAGE`, `READ/WRITE_EXTERNAL_STORAGE`,
  `WRITE_INTERNAL_STORAGE`, `requestLegacyExternalStorage`) removed; nothing used them.
- [Done] **No personal data in diagnostics**: the temporary Slack report of each account deletion (masked email)
  is removed; deletion steps are logged on the device only.
- [Done] **iOS purpose strings**: `NSLocationWhenInUseUsageDescription` (base `Info.plist`, `en.lproj` and
  `vi.lproj/InfoPlist.strings`) now says the location suggests the currency (only the country is kept) and, once
  smart suggestions are unlocked, is saved with each expense and backed up to the account; it is optional. The
  unused `NSLocationAlwaysAndWhenInUseUsageDescription` key is removed (the app only asks "while in use").
- [Planned] **In-app control**: a Profile switch "Save location with expenses" (default on for LV3/VIP, off turns off capture without revoking the OS permission), and a way to strip saved coordinates from past transactions.

### Legal & Account Management
- **Terms of Use**: Available from the Profile menu
- **Delete Account**: Separate red text line next to the "Logout" button - not grouped with other menu items (Apple Guideline 5.1.1(v) compliance)
  - Also available on the web, without the app: https://app-qltc.vercel.app/delete-account (required by Google Play).
  - **Order of the flow**: confirm the account → re-authenticate if needed → delete the cloud data (all
    collections, `profile` included) → delete the sign-in account → clear the device. Re-authentication always
    happens **before** any data is deleted, so cancelling a confirmation sheet never leaves an account without
    its data. The steps are logged on the device only (`[DeleteAccount]`), never sent off it.
  - **The confirmation sheet always shows the same account that is being deleted.** The app never shows an Apple
    or Google sheet that could belong to someone else: the Apple sheet always shows the *device's* Apple ID, so it
    is shown only when Apple confirms that this Apple ID is the one linked to the account; the Google sheet lets
    the user pick any Google account, so the picked one is checked against the account's own Google email and a
    mismatch stops the deletion ("this is not the account you are deleting").
  - **Sign in with Apple token** (Apple guideline 5.1.1(v) asks apps to revoke it on account deletion).

  | Situation | What the user sees | Apple token | Status |
  |---|---|---|---|
  | Apple linked and the device's Apple ID is the linked one (`authorized`) — signed in **with Apple or with Google** | Apple sheet with the same Apple ID used at sign-in | **Revoked** (`revokeTokenWithAuthorizationCode`); the app disappears from the user's "Sign in with Apple" list | [Done] — verified on a release build, iOS 26.7.3, 27/11/2026: authorized → same Apple ID → re-auth ok → token revoked → data deleted → account deleted |
  | Signed in with Apple, but the Apple token was already revoked by the user (`revoked`) | No Apple sheet | Nothing left to revoke | [Done] |
  | Signed in with Apple, but the device's Apple ID is a different one (`notFound`), or Apple cannot answer | No Apple sheet (it would show someone else's Apple ID); re-authenticated another way, or asked to log in again | **Not revoked** | [Partial] |
  | Account has **Apple and Google** linked, signed in **with Google**, device Apple ID = linked one | Apple sheet with that Apple ID (same as Apple sign-in), then deletion. Cancelling the Apple sheet cancels the deletion (nothing deleted). If the Apple step fails for another reason (e.g. the 24/11/2026 error "credentials do not correspond"), the deletion is **not** blocked: it continues through the Google / recent-login path, without revoke | **Revoked** (not revoked on the fallback) | [Partial] — implemented 27/11/2026 (before: never the Apple sheet for a Google sign-in, log of 26/11/2026); becomes [Done] once verified on a release build |
  | Account has Apple and Google linked, signed in with Google, device Apple ID is another one or none | Google sheet only if the sign-in is older than ~4 minutes; never the Apple sheet | **Not revoked** | [Partial] |
  | Google only | Google sheet if the sign-in is older than ~4 minutes, checked against the account's email | — | [Done] |
  | Phone only | Nothing if signed in recently; otherwise "log in again", then delete | — | [Done] |
  | Android, account with Apple linked | No Apple sheet (no Apple credential check on Android) | **Not revoked** | [Partial] |

  - In the **[Partial]** cases the account and all its data are still deleted; only the Apple authorization
    remains listed in the user's Apple ID. The privacy policy (§4) tells the user to remove the app in Settings →
    [name] → Sign in with Apple. The remaining gap (device without the linked Apple ID, Android) can only be closed by a server
    that keeps the Apple refresh token and revokes it. [Planned]
  - A failed revoke (e.g. wrong Apple key setup in Firebase) does **not** block the deletion: the user asked to
    leave. It is logged locally and must be checked in Firebase Console → Authentication → Apple.
- **Re-access Tutorial**: Manual restart from Profile
- **Rate the app**: rating and feedback sheet in Profile

## 6. Key Modules & Features

### Financial Runway (Survival Indicator)
- **Formula**: `Total Available Balance / Monthly Burn`
  - **Total Available Balance**: book balance of every wallet except investment positions (the Emergency Fund counts).
  - **Monthly Burn**: the sum of all active **fixed-price** budget limits (the user's mandatory monthly costs). If none are marked fixed-price, the average monthly expense is used: total expenses from the 1st of the month 3 months ago up to today, divided by the number of calendar months from the month of the earliest transaction in that window to the current month, inclusive (1 to 4). The current month counts as a full month even when it has just started.
  - **Reconciliation adjustments count** in the average-spend fallback like any other expense (a shortfall found
    when reconciling is money that was really spent). [Done]
  - **Known limitation** (§2): because the current month counts as a full month, on the first days of a month the
    average spend is low and the runway looks longer than it really is. [Planned] count only completed months, or
    pro-rate the current one.
- **Display**: "With current money, you can sustain your life for X months and Y days." (days = fractional month × 30)
- **Status**: ≥ 12 months excellent · ≥ 6 good · ≥ 3 safe · below 3 caution · no expense data → "insufficient data"
- **Goal**: Provide a clear "Safety Index" to reduce stress and improve decision-making.

### Smart Budgeting
**Budget Warning System ("Cảnh báo vượt rào")**

**Concept:**
Users set a monthly spending limit per category (e.g., "Only 1M for shopping this month"). A budget is perpetual: it has no start/end date and its spend is computed per calendar month.

**Logic:**
- **Budget Setup**: maximum spend per category per month. When creating a budget the app suggests a limit from that category's average spend over the last 3 months.
- **Fixed-price flag (bolt icon)**: marks a budget as a mandatory recurring cost (rent, electricity…). Fixed-price budgets feed the Financial Runway and the LV3 requirement.
- **Real-time Tracking**: "you have X remaining for this category"
- **Card status**: safe (< 80%) · near limit (≥ 80%, not over) · over (spend > limit; spending exactly the limit is still safe)

**Budget Change Rules:**
- The **limit** (the amount set) cannot be edited in two cases:
  - **after day 7 of the month.** It can only be changed during days 1–7, so that users set their budgets at
    the start of the month. [Done]
  - **once the budget has recorded spending.** Budget spend is counted per calendar month, so the limit is
    locked as soon as an expense in the budget's category is recorded this month (any date in the month,
    deleted entries excluded). [Done]

  The budget form replaces the limit input with a notice giving the reason. The rule is also enforced when
  saving (`BudgetLimitEditPolicy`, used by `UpdateBudgetLimitUseCase`).
- **The lock is a commitment reminder, not a hard barrier.** It limits casual editing so that a budget means
  something: the user sets limits at the start of the month and sticks to them, which is the habit of serious
  money management the app teaches. It is deliberately not airtight:
  - **Delete and recreate is allowed.** The user may delete a budget and create a new one for the same category
    with a different limit, at any time of the month. That takes a conscious extra step (and the new budget
    starts its own over-limit history), which is the point of the reminder.
  - Deleting a budget removes **every budget with the same category or the same name** (case-insensitive), and
    the delete reaches the cloud (§5 Deletes), so a recreated budget never sits next to the old one.
    **This is intended**, including the case of two budgets in *different* categories that share a name: a
    budget name stands for one spending goal, so same-name budgets are treated as one. Users should give
    budgets for different categories different names. [Planned] the delete confirmation should name every budget
    it will remove, so the user is not surprised.
- **What the user may do instead: move money (luân chuyển) between wallets.** Budget limits stay fixed, but
  money can be moved from one wallet to another at any time with the existing wallet **Transfer** (Điều chuyển,
  §4.B), started from the liquid wallet list. [Done]
- The **name** and the fixed-price flag can be changed at any time
- Budgets can be archived (hidden, kept in storage) and reordered

**Notifications (local):** fired once, on the exact expense that crosses a threshold:
- **80%**: "near limit"
- **100%**: "over limit"

**Insights on the Budget Allocation page** (shown only when something needs attention):
- **Pacing**: at 80% and above, days remaining in the month and a suggested daily spend from what is left (0 once exhausted)
- **Over-budget tiers**: 120%, 150%, 200% — shown on the budget card and in insights. By design they do **not** deduct level points: a level never decreases (see §8); the tiers are a warning only.
- **Over-limit counter color**: 1–5 times green · 6–10 amber · 11+ red
- **Deficit Warning**: expenses > income this month. Every income and expense of the month counts, reconciliation
  adjustments included (a shortfall adjustment is an expense, a surplus an income), because they bring the book
  in line with the real money. [Done]
- **Anomalies**: budgets whose spend this month spikes against the previous 3 months' average for that category
- **Debt-driven cash flow**: flags when borrowing makes up a large share of inflow, or repayments a large share of outflow

**AI Actions for Budget Issues (VIP + AI data-sharing consent):** the Reports page can generate an AI advice narrative from cash flow, budget insights, anomalies and runway, in the user's language and currency. Results are cached and reused until the underlying transactions change.

### Debt & Loan Management (LV3 or VIP)
- **Separation Policy**: Debt (Liability) and Loan (Lend) are separate tabs to prevent data mixing.
- **Linkage**: All payments are linked to specific wallets and generate corresponding transactions for the audit trail.
- **UI Position**: the **Secondary Card** of the Transaction Entry page (Investment · Liability · Lend), reached via the Card Stack Reveal.
- **Lend Sub-segment**: **Lend (Cho vay)** — outgoing principal; **Collect (Thu nợ)** — incoming repayments.
- **Liability Sub-segment**: **Borrow (Đi vay)** — incoming principal; **Repay (Trả nợ)** — outgoing payments.
- **Outstanding balance**: always derived from linked transactions, never stored.
- **Repayment methods**: installment schedule (due date + amount per period) or lump sum (one final due date).
- **Reminders** (optional per record, 09:00 local): installment — 1 day before each due date; lump sum — 30 days, 7 days and 1 day before the final due date.

### Emergency Fund ((LV3 and ebook viewed) or VIP)
**Emergency Fund ("Quỹ dự phòng khẩn cấp")**

**Concept:**
Knowing how long you can "survive" without income is the most critical step toward financial freedom. This is the "Safety Index" that helps users handle crises (unemployment, illness) without falling into debt.

**Example:**
After listing essential expenses, user determines minimum survival cost is 10M/month.
If user has saved 60M (Emergency Fund), they have 6 months of complete freedom.

**Implementation:**
- A wallet type of its own, shown in its own banner on the Budget Allocation page
- Unlock: (LV3 and the user has opened the emergency fund ebook) or VIP
- Balance is entered by the user; it counts as available money for the runway and is reconciled normally
- [Undone] **Ebook — release blocker.** The guide does not exist yet: the link (`emergencyFundEbookUrl`) points to
  a placeholder (`https://example.com/terms-of-service`), so "viewing the ebook" unlocks the wallet without the
  user reading anything. To do: write and host the real guide, link it, and only then ship (§2 Release
  blockers).

### Financial Freedom Index
- [Undone] **Not implemented, and not specified yet.** Intended idea: compare passive income with the minimum
  living expense (50%: on the path · 100%: financial freedom · 200%: encourage quality of life). No code exists.
- Open before it can be built: **"passive income" is not defined.** It must say which income counts (e.g. the
  "investment income" category group, investment returns, rent…), over which period (one month, a 3-month
  average…), and whether "minimum living expense" is the runway's Monthly Burn (fixed-price budgets).

### Investment Tracking (LV2 or VIP)
- An investment position is a wallet of type investment, classified by an investment category (stocks, personal business, …)
- **Name suggestions follow the user's region** (add-investment sheet), shown left to right as listed in
  `InvestmentNameCatalog`: regions **VN**, **US / Global**, **KR**, **JP**, **CN**, one list per category, written
  in that market's own language whatever the app language is.
  - The region (`SuggestionRegion.resolve`) is, in order: the currency the user **chose** in Profile; otherwise the
    **detected country** (GPS or device locale); otherwise the book currency. USD, EUR and any other country use
    the US / Global list.
  - The lists are a fixed editorial set for filling in a name quickly. They are **not** ranked by performance, not
    updated with the market and **not investment advice**. Changing them requires an app release.
- **Chi ra** records contributed capital; **Thu vào** records returns
- **ROI** = total returns ÷ total contributed capital, across all positions
  - **Known limitation** (§2): there is no market value and no time weighting, and capital taken back out of a
    position can only be recorded as *Thu vào*, so it counts as a return and inflates ROI. Treat ROI as a rough
    indicator. [Planned] a proper return (current value, capital withdrawals kept apart from profit).
- Kept out of the runway and out of reconciliation (the position itself is not counted; its *Chi ra* out-leg and
  *Thu vào* sit on liquid wallets, which are)
- **Deleting a position** refunds the *Chi ra* to the liquid wallet and removes the position from ROI; it is
  refused once any of its transactions is reconciled — see §9 Functions
- **Unlocks at LV2 or with VIP** (independent paths, §3): the Investment tab appears in the Transaction secondary
  card and the investment section on the Budget Allocation page. A non-VIP user creates positions from the
  Investment tab with the category's default name; a custom name and the Budget Allocation add sheet require VIP.

### AI Integration

**Availability:** AI Smart Entry requires LV3 or VIP; AI advice in Reports requires VIP. Both also require the
user's consent to share data with Gemini, because every AI input is sent to Gemini (see below).
- **Consent** is opt-in (default off). The user agrees in the AI consent sheet, shown when enabling "Unlock Invest,
  Liability, AI (experiment)", from the Profile "Share data with AI" switch, or by tapping a locked AI feature;
  the user can withdraw it in Profile at any time.
- **Without consent the AI features are locked**, shown the same way as a level lock: the feature stays visible,
  dimmed, under a lock icon (`CcLockOverlay` from `cc_sdk_ui`, the one lock overlay for every locked feature).
  Tapping the lock opens the consent sheet; agreeing unlocks the feature at once. There is no local-only AI
  entry without consent.
- **Daily limit:** **5 Gemini calls per day** in release builds (unlimited in debug), counted on the device only.
  Reinstalling the app resets the count. Accepted by design: a reinstall also loses the user's local financial
  data, so it is not a practical way around the limit.
- **Currency and language (today):** Smart Entry is shown once the onboarding guideline is complete, and only
  when the book currency is **VND** and the app language is Vietnamese or English (`QuickEntrySection`,
  `TransactionHeaderBanner`). A user with another book currency does not see it, even at LV3 / VIP with
  consent. The local parser and its datasets are built for Vietnamese amounts ("50k", "2tr").
- [Planned] **All app currencies**: open Smart Entry for USD, JPY, EUR, KRW and CNY books once the parser,
  quick-amount datasets and Gemini prompts handle each currency; the VND-only gate is then removed.

**Smart Entry (Tăng tốc bằng AI & Logic):**
- **Text**: e.g. "50k cafe" → amount 50,000, category Cafe. Parsed locally first (regex and alias datasets per
  language), then **always sent to Gemini** on submit. The local result is used only once the daily limit is
  reached.
- **Voice**: dictation feeds the same text pipeline.
- **Receipt image**: from camera or gallery, sent directly to Gemini. Up to 5 images per batch; up to 20 transactions per parse.
- **Preview before save**: parsed rows open in a preview sheet where amount, category, wallet and date can be corrected, then saved as a batch.
- **Safety**: amounts above 500,000,000 are rejected as likely phone or serial numbers; phone numbers and invoice numbers are stripped before parsing.
- [Planned] Auto-save countdown (code exists but is switched off).

**Smart Suggestions (no AI call):**
- **Time-based**: 06–10 → coffee/breakfast · 11–14 → eating out · 18–21 → food & drink
- **Location-based**: if the user is within 150 m of a previous expense that has a GPS fix, suggest that expense (LV3 or VIP; what is stored and synced: §5 Privacy: Location Data)
- **Merchant match (autofill)**: fuzzy match of the typed text (diacritics and punctuation ignored) against past transactions to prefill amount and category
- **Recurring monthly bill**: suggests last month's entry when today is within 3 days of the day it was paid and nothing in that category has been recorded yet this month

**Age-Based Customization:** see §4.A Category Personalization.

**Smart Budget Setup:**
- [Done] **Expense Estimation**: suggested budget limit = average of the last 3 months' spend in that category
- [Planned] **Income Estimation** by location

**Quick Templates:**
- [Planned] User-defined "fixed cost" templates ("Đổ xăng 50k", "Ăn cơm trưa 35k")

## 7. Category System

Four category types: **expense**, **income**, **investment**, **debt/loan**. Users can enable/disable, create, edit and delete categories.

### Expense groups (13)
Food & Drink · Transport · Utilities · Shopping · Housing · Health · Personal Care · Entertainment · Gifts/Charity · Education · Insurance · Service/Bank Fees · Family/Children

Notes carried from the original requirement:
- **Health/Medical**: often a top-3 unexpected expense; tracked separately for emergency fund planning
- **Entertainment** is separate from dining out so spending habits are not misread
- **Service/Bank Fees**: small but accumulates; many apps miss it
- **Family/Children** (milk, diapers, baby toys): default on from age 30

### Other types
- **Income**: 3 groups — active income, investment income, other
- **Investment**: one default group (stocks, personal business, … , other)
- **Debt/Loan**: 2 groups — borrow (e.g. bank loan, mortgage) and lend (e.g. personal loan)

### Category Personalization
- **Location**: Profile → Category settings
- **Logic**: enable/disable by life stage; defaults come from the age group (see §4.A)

### Transaction Entry UI
- **Tab Navigation (Stacked Card Reveal)**:
    - **Primary Card (Daily)**: Expense (Chi tiêu), Income (Thu nhập).
    - **Secondary Card (Advanced/Locked)**: Investment (Đầu tư), Liability (Vay nợ), Lend (Cho vay).
    - **UX Pattern**: **Progressive Disclosure**. Advanced tabs are stacked behind the primary ones; tapping the card edge or toggle chip swaps depth with a slide animation. Locked tabs show a level-lock placeholder.
- **Dynamic Header Behavior**: The page header (Wallet balance, Report shortcut, Submit action) collapses when the keypad is open.
- **Amount Frame**: quick-amount chips plus the money keypad
- **Date Frame**: quick date row, tap to open the calendar

## 8. Level Progression System

Levels are computed from data recorded after the account's level start date (stamped when the account first uses the level feature, synced with the account). **A level never decreases**: the highest level reached is stored with the account and re-applied on every device even if the conditions later lapse.

**Levels are not sequential.** Each level is checked on its own conditions: a user who meets the LV3 conditions reaches LV3 directly, even without having met the LV2 conditions (e.g. the 6 guideline tasks). This is intended: the level path is a guide, not a gate, and paid VIP (planned, see §3) will be another way to shorten it.

**Reconciliation streak**: the longest run of consecutive audit cycles (§4.C) that each contain a reconciliation, done on **any day of the cycle**. A cycle with no reconciliation breaks the run. Changing the audit day restarts the count from that moment.

### Level 1 (Entry Level)
- **Locked Features**: Investment, Debt/Loan tabs, AI Smart Entry, Emergency Fund
- **Purpose**: Build the habit of disciplined usage and weekly audits
- **Unlock Level 2** (both required):
  1. Reconciliation streak ≥ 2 weeks
  2. All 6 LV1 guideline tasks completed (see §4.A)

### Level 2 (Intermediate)
- **Unlocked Features**: Investment tab only. The Liability and Lend tabs, AI Smart Entry and the Emergency Fund
  stay locked until LV3 (or VIP).
- **Unlock Level 3** (all required):
  1. At least 3 active **fixed-price** budgets (mandatory monthly costs)
  2. Reconciliation streak ≥ 4 weeks
  3. Positive cash flow in the current month (income > expense)
     - Every income and expense of the month counts, reconciliation adjustments included: a surplus found
       when reconciling ("dôi dư") is an income, so recording a higher actual balance can turn the month
       positive. This is **allowed**: it is what a smart, daily user does when their real money is larger
       than the book. It cannot shortcut the level on its own, because condition 2 still requires a streak of
       real reconciliations, one per audit cycle (§4.C).
     - All amounts are in the one book currency (§5), so they are summed as recorded, with no conversion.

### Level 3 (Advanced)
- **Reached when** the three conditions above hold, whatever the current level
- **Unlocked Features**: Debt/Loan management, AI Smart Entry, Emergency Fund wallet (after viewing the ebook)
- **Rationale**: advanced features, for users who already keep a disciplined book. The LV3 conditions
  themselves prove it (fixed costs declared, 4 cycles of reconciliation, a positive month), so LV2 is a
  suggested stop on the way, not a required one (see "Levels are not sequential" above).

VIP is a second, independent path to the same features (see §3): it grants LV3 access and shows level 3 on the
Profile badge, but does not change the level earned here. Turning VIP off returns the user to their earned level.

## 9. Wallet Management (Budget Allocation)

### Wallet Types
- **Cash**: a single wallet with a fixed name and icon
- **Bank** and **e-Wallet**: user-managed, custom names. The default Bank wallet created on first launch cannot
  be deleted but can be renamed; until it is renamed it shows the localized "Bank" label
- **Emergency Fund**: see §6
- **Investment**: investment positions, see §6
- Bank, e-Wallet and Emergency Fund count as liquid money in Expense/Income pickers; only Investment is excluded.

### Functions
- **Add / edit / delete wallet** with custom name and icon
- **Deleting a wallet follows the closed-period rule (§4.B):** a reconciled period is immutable, so no delete
  may change a balance a reconciliation has confirmed.
  - **Liquid wallet** (cash, bank, e-wallet, emergency fund): can be deleted only while it has **no
    transactions** ("not empty" otherwise); Cash and the default Bank are protected. With no transactions,
    nothing else changes.
  - **Investment position**: deleting it soft-deletes every linked transaction — its own *Chi ra* in-leg, and
    the legs that live on a **liquid** wallet: the *Chi ra* out-leg and every *Thu vào* (matched by
    `investmentWalletId`). That is consistent everywhere, because every balance and stat is derived from the
    remaining transactions: the liquid wallet gets the *Chi ra* money **back** and loses the *Thu vào*
    amounts, and the position leaves ROI and the investment totals.
  - **The delete confirmation lists these effects as bullets** (`InvestmentDeleteSheet`: linked entries deleted,
    contributed money returned, collected returns taken back, ROI, and the reconciled block), styled like the
    reconciliation guide (`HighlightedGuideRow`).
  - **Refused when any of those transactions is reconciled** (dated at or before the latest reconciliation):
    nothing is deleted and the user sees "Some of its transactions are already reconciled… Add a new
    transaction to offset it instead" (`wallet.delete_error_reconciled`, `WalletLedger.removeTransactionsOf`).
    Deleting is still allowed when every linked transaction is after the latest reconciliation (e.g. a
    position created by mistake this cycle).
  - **To correct instead of deleting, the user adds a new offsetting transaction** in the open period, e.g. a
    *Thu vào* for the money taken out of the position, or an income/expense with a note giving the reason.
    The closed period stays as confirmed and the correction is reconciled next cycle.
  - Debug trace: every step logs with the `[DeleteWallet]` prefix (request, linked transactions with their
    `RECONCILED` / `open` state, refusal, soft delete, cloud delete, outcome).
  - [Planned] archive a closed position (hide it, keep its history) instead of deleting it.
- **Transfer** between wallets
- **Ordering**: liquid wallets are grouped by type, then sorted by name
- **Budget Allocation page sections**: liquid assets (hero banner + wallet strip) · investments (LV2 or VIP) · liabilities and lending (LV3 or VIP) · budget limits preview · insights

## 10. Data Schema Overview

| Entity | Description | Status |
| :--- | :--- | :--- |
| **Account settings** | Birth year, audit day (and when it changed), book currency (and whether it was detected or chosen), VIP switch, highest level, level start date, guideline progress, ebook viewed, customized categories. Synced per account (`profile/settings`). Paid VIP is stored apart and not synced from the device (§3). | [Done] |
| **Device settings** | Theme, reminders, tutorial seen, first-launch stamp, AI consent, detected region. Local only. | [Done] |
| **Wallet (Nguồn Tiền)** | Cash, bank, e-wallet, emergency fund, investment position. | [Done] |
| **Category / Category group** | Classification for expense, income, investment, debt/loan. | [Done] |
| **Transaction (Phiếu Thu/Chi)** | Income, expense, transfer legs, investment legs, debt legs; optional precise GPS fix on expenses (synced, see §5 Privacy); soft delete. | [Done] |
| **Budget limit (Ngân Sách)** | Perpetual monthly limit per category, with fixed-price flag. | [Done] |
| **Liability** | Borrow/lend record with installment schedule or final due date. | [Done] |
| **Reconciliation (Kiểm Toán)** | Book vs. actual record, one per audit cycle, with per-wallet allocations and adjustment ids. It is also the cycle snapshot: there is no separate "weekly snapshot" entity, by design. | [Done] |
| **TimeBlock** | Not part of this app: habit and time tracking was an idea from an earlier plan, with no spec and no code. Out of scope; kept here only so it is not mistaken for a missing feature. | Out of scope |

Amounts are stored as integers in whole units of the book currency (no cents; conversions round, and never to 0 — §5 Localization), together with its currency code. Wallets, transactions, budget limits, categories, liabilities, reconciliations and account settings are synced to Firestore per user, and all of them are deleted with the account.
