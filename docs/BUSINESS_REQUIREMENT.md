# Business Requirement - Personal Finance Management (Sổ Sách Xịn)

## 1. Overview
The Sổ Sách Xịn (Quản Lý Tài Chính) application is a modular personal finance management system designed with the philosophy: **"Smart, Effective, and Disciplined Spending"**. It aims to help users track their income/expenses, manage multiple wallets, maintain a financial "survival" runway, and eventually leverage AI for optimized budgeting and fast data entry.

**Reference:** https://app-qltc.vercel.app/dashboard

## 2. Roadmap

**MVP (Phase 1 - LV1)**
- Core transaction management (Income, Expense, Transfer)
- Wallet management (Cash, Bank, e-Wallet)
- Basic reporting (Weekly/Monthly charts)
- Category management with personalization
- "Frequently Used" quick access section
- Weekly audit/reconciliation system
- Level progression system (LV1)

**Phase 2 (LV2)**
- Smart Budgeting with warning system
- AI-powered Smart Entry (NLP, Autofill, Templates)
- Smart Suggestions (Time-based, Location-based)
- Spending optimization recommendations
- Enhanced reporting with yearly views
- Emergency Fund & Financial Runway tracking
- Investment tracking (unlocked at LV2)
- Financial Freedom Index

**Phase 3 (LV3)**
- Debt & Loan Management (4th tab)
- Advanced AI features (image processing, voice input)
- Budget estimation and smart suggestions
- AI-powered warnings and actions
- Multi-currency support by location
- Enhanced animations

**Phase 4**
- App Store deployment (Android/iOS)
- Google Ads banner integration
- Gaming theme layout option
- Online ebook with AI language translation

**Phase 5**
- Community chat tab (when monthly active users reach 1000)

## 4. Core Business Processes

### A. Initialization & Setup
- **Wallet Declaration**: Users define various income sources and wallets (Cash, Bank, e-Wallet).
- **Initial Balance**: Set the starting amount for each wallet.
- **Budgeting**: Define monthly spending limits for specific categories (e.g., Food, Shopping).
- **Year of Birth Selection**: Affects preset amounts for income, investment, and expense suggestions.
- **Category Personalization**: Enable/disable categories based on family status (single, with children, etc.).

### B. Daily Transaction Management
- **Immediate Entry**: Encourage users to record transactions within 5 seconds of occurrence.
- **Transaction Types**:
    - **Income (Thu)**: Record money received.
    - **Expense (Chi)**: Record money spent, linked to a specific Category and Budget.
    - **Transfer (Điều chuyển)**: Move money between wallets (e.g., ATM withdrawal).
    - **Investment (Đầu tư)**: Specific tracking for money allocated to investment funds.
    - **Debt/Loan (Vay/Nợ)**: Track borrowing and lending activities.
    - **Emergency Fund Withdrawal (Rút quỹ dự phòng)**: Track use of reserved survival funds.

**Transaction Entry Flow (Normal):**
1. User opens App → enters amount in "Chi tiền" within < 500ms
2. Number keypad doesn't auto-open; user snap-scrolls to center for expected amount (e.g., 50,000đ) or types manually
3. System auto-suggests additional zeros and currency unit "đ"
4. Press "Lưu" (Local save) button - top-right
5. App remains open

### C. Reconciliation & Audit (Weekly/Monthly)
- **Financial Audit (Kiểm toán)**: Compare system balances with actual physical cash/bank balances.
- **Adjustment Slips**: Automatically generate income/expense slips to fix discrepancies found during audits.
- **Weekly Snapshot**: Freeze data weekly to track trends in income, survivor expenses, and debt pressure.
- **Weekly Reporting**: User selects a fixed day each week for reporting/reconciliation/audit.
  - Push notification when approaching and on the reporting day (max 2 reminders if user forgets)
  - No reminders if already completed
  - No reminders after first notification if user has completed the task

**Reconciliation Flow:**
1. User enters "Actual Balance" for each wallet
2. System calculates difference between "Book Balance" and "Actual Balance"
3. If mismatch detected:
   - "Create Adjustment" button auto-fills amount = difference
   - Auto-selects transaction type based on difference sign:
     - Book > Actual (negative difference) → Creates Expense transaction
     - Actual > Book (positive difference) → Creates Income transaction
   - Auto-assigns to the wallet being reconciled
   - Assigns special category "Điều chỉnh sổ sách" or "Quên ghi chép"
4. After adjustment: "Actual" matches "Book" → status changes from "Lệch -Xđ" to "Khớp sổ ✓"
5. "Confirm Reconciliation" button becomes enabled
6. Navigation: For each wallet, icon button to review income/expense transactions filtered by wallet, scrolled to reconciliation period

### D. Chart & Reporting Specifications

**Income vs Expense Comparison Chart**

| View Type | Data Points | Chart Style | Time Labels | Navigation |
|-----------|-------------|--------------|--------------|-------------|
| **Weekly** | 4 points (last 4 weeks) | Smooth bezier curve | Single subtitle "4 weeks near most" | None (always current) |
| **Monthly** | 3 points (last 3 months) | Smooth curve + dots at points | Format Mon/YY (May/26, Jun/26, Jul/26) | Chevron icons: `< First - Last >` |
| **Yearly** | 12 points (last 12 months) | Polyline (broken at month boundaries) | Quarterly labels (Aug/25, Nov/25, Feb/26, May/26) | 12-month window navigation |

**Navigation Logic:**
- **Weekly**: Always open (most recent period), no navigation
- **Monthly**: Navigate by 3-month increments, max 12 months back (arrow disables at limit)
- **Yearly**: Navigate by 12-month window, max 1 year back (e.g., in 2026, can view back to 1/25)

## 5. Technical Specifications

### Libraries & Packages
- **Icons**: `font_awesome_flutter` (https://pub.dev/packages/font_awesome_flutter)
- **Animations**: `animations` (https://pub.dev/packages/animations)
- **Tutorial**: `hotspot` (https://pub.dev/packages/hotspot) - one-time onboarding
- **Scroll Snap**: `scroll_snap_list` (https://pub.dev/packages/scroll_snap_list) for horizontal lists

### Mobile App Architecture
- **Offline First**: Local database (Isar recommended over SQLite for Flutter performance)
- **Local Save First**: All transaction saves must execute locally first (instant success)
- **Sync on Demand**: Sync to Server (Firebase/REST API) when user clicks Sync icon in Profile tab
- **Data Caching**: Category and wallet lists must be hard-cached - no API fetch on every screen open
- **Performance Target**: Transaction entry must be fast and easy

### Home Screen Widgets
- **Android/iOS Widgets**: Display balance and 2 quick buttons: [+ Chi] and [+ Thu]

### UI/UX Guidelines
- **Minimal Text**: Use icons extensively, very little text
- **Number-Only Input**: Accounting operations only allow numbers, no text input
- **Keyboard**: Number-only keyboard for amount entry
- **Image Optimization**: Use font or SVG for Category icons (FontAwesome) instead of PNG to reduce RAM and increase display speed
- **Skeleton Loading**: Use skeleton screens instead of CircularProgressIndicator for immediate app responsiveness

### Authentication System
- **Multi-method Login**: Phone number OR Google account (linked to same user)
- **Account Linkage**: Phone number linked with Google account to allow same user to login via either method
- **Profile Editing**: Edit full name
- **Sync Status Indicator**:
  - Online: Sync icon button
  - Offline: Warning badge icon button beside sync button (alerts user to sync to avoid data loss from local storage)

### Theme Options
- **Light/Dark Mode**: 2 theme options
- **Style Variants**:
  - Minimal Style: Clean, basic, minimal animations, simple icons
  - Game Style: Simple game aesthetic, many animations, elaborate icons

### Localization
- **Languages**: Vietnamese (default), English
- **Currencies**: Đồng (default), USD, Euro, SGD, etc. (list of popular currencies)

### Legal & Account Management
- **Terms of Use**: Placed next to "About App" in legal information section
- **Delete Account**: Separate red text line below "Logout" button - not grouped with other icon-list items (Apple Guideline 5.1.1(v) compliance)
- **Re-access Tutorial**: Manual access from Profile since tutorial only shows once

## 6. Key Modules & Features

### Financial Runway (Survival Indicator)
- **Formula**: `Total Available Balance / Average Monthly Expenses`.
- **Display**: "With current money, you can sustain your life for X months and Y days."
- **Goal**: Provide a clear "Safety Index" to reduce stress and improve decision-making.

### Smart Budgeting (LV2)
**Budget Warning System ("Cảnh báo vượt rào")**

**Concept:**
Users set monthly spending limits per category (e.g., "Only 1M for shopping this month"). The app provides real-time warnings when approaching or exceeding limits.

**Logic:**
- **Budget Setup**: Set maximum spend per category per month
- **Real-time Tracking**: "With current budget, you have X remaining for this category"
- **Over-budget Warning**: Alert when spending exceeds the set limit

**Warning Color System:**
- **Green**: User is within 5 times of the limit (healthy spending)
- **Yellow**: User has exceeded the limit up to 5 times (caution)
- **Red**: No limit - user has significantly overspent (critical)

**Budget Change Rules:**
- Changes only allowed at the beginning of each month (from day 1)
- Restrict changes to the first week of each month
- For recurring monthly expenses (electricity, water, internet), the budget aligns with actual billing cycles
- One-time expenses (insurance) are handled separately under the "Expense" category

**Smart Budgeting Behavior:**
- If user stays within budget → Green alert (praise smart spending)
- If user anticipates seasonal changes (e.g., higher electricity in summer) and proactively adjusts budget → Maintains "smart" status
- If user fails to anticipate changes → Budget evaluation reflects need for better planning in future months
- Goal: Train users to set realistic, data-driven budgets based on actual spending patterns

**Budget Warning Thresholds:**
- **80%**: Calculate remaining days, suggest daily spending limit from remaining 20%
- **100%**: (budget exhausted), AI suggests remaining days in month, recommends: limit daily spending
- **Over-budget Penalties**: Level point deductions displayed on chart at 3 thresholds: 120%, 150%, 200%
- **Deficit Warning**: Alert when expenses > income (deficit spending)

**AI Actions for Budget Issues:**
- Review expense items
- Compare with historical anomalies (unusual expenses, sudden increases)
- Suggest income increase strategies based on 3-month history
- Encourage tasks that compensate for exceeded budget
- Goal: Eliminate deficit, achieve positive cash flow, financial safety index

### Debt & Loan Management (LV3)
- Track money owed to others (Debts) and money others owe to the user (Loans).
- Link payments to specific wallets and expense slips.
- **Tab Position**: 4th tab in the application (after Dashboard, Transactions, Reports)
- **Debt Tracking**: Monitor outstanding debts with payment schedules
- **Loan Tracking**: Track money lent to others with repayment tracking

### Emergency Fund & Financial Runway (LV3)
**Emergency Fund ("Quỹ dự phòng khẩn cấp" or "Chỉ số an toàn tài chính")**

**Concept:**
Knowing how long you can "survive" without income is the most critical step toward financial freedom. This is the "Safety Index" that helps users proactively handle crises (unemployment, illness) without falling into debt.

**Financial Runway Calculation:**
- **Formula**: `Total Available Balance / Average Monthly Expenses`
- **Display**: "With current money, you can sustain your current lifestyle for X months Y days."
- **Purpose**: Provides a clear timeline for financial decision-making during emergencies

**Example:**
After listing and optimizing essential expenses (food, transportation), user determines minimum survival cost is 10M/month.
If user has saved 60M (Emergency Fund), they have 6 months of complete freedom.
In those 6 months, user has time to find new work or start a business without financial pressure.

**Technical Implementation:**
- Unlocks at Budget Allocation page when user reaches LV2
- User must view emergency fund ebook via web browser on Profile page first
- User self-enters amount based on knowledge from ebook
- Minimum living expense (lightning icon) represents serious lifestyle

**Financial Freedom Index (Unlocks at LV2):**
- Shows when passive income exceeds minimum living expense
- **50%**: On the path to financial freedom
- **100%**: Financial freedom (investment)
- **200%**: Encourage increased spending, improve quality of life

### Investment Tracking (LV2)
- Track money allocated to investment funds
- Monitor investment performance over time
- Separate from daily spending to ensure clear financial visibility
- **Unlocks at LV2**: Investment tab appears in Transaction page

### AI Integration (Phase 3)

**Smart Entry Features (Tăng tốc bằng AI & Logic)**

**AI Autofill:**
- Learns from user habits and historical data
- Example: User frequently orders "Trà sữa Phúc Long, size L, 50.000" at Phúc Long
- From the 2nd entry onward, autofill suggests: amount, category, and other fields
- Reduces manual input significantly

**Smart Suggestions:**
- **Time-based**: If user enters expense at 7-8 AM, prioritize suggesting "Breakfast/Coffee" categories
- **Location-based**: If user is near a frequent vendor (GPS), auto-suggest the relevant category
- **Pattern-based**: Suggest based on spending patterns and historical behavior

**NLP Simple (Natural Language Processing):**
- Single audio input: "50k cafe"
- App automatically parses: Amount = 50,000, Category = Cafe
- Reduces entry time to seconds

**Quick Templates:**
- Users can create "Fixed cost" templates for recurring expenses
- Examples: "Đổ xăng 50k", "Ăn cơm trưa 35k"
- One-tap completion for frequent transactions
- Template Image/Screenshot/Momo weekly/monthly receipts

**Image/Voice Processing:**
- Camera, screenshot, voice, audio input to fill transaction information
- Auto-extract: category, amount from images
- Store in local storage
- Allow editing if extraction is incorrect due to poor image quality

**Age-Based Customization:**
- AI sets age, matches with "Category Customization"
- Example: Over 30 years old → default check Dad/Mom/Diaper categories

**Smart Budget Setup:**
- **Income Estimation**: Suggest average income based on location (average of last 3 months, suggest for month 4)
- **Expense Estimation**: Suggest based on previous month values (e.g., last month "trà sữa phúc long size lớn 50k")

**Spending Optimization:**
- AI analyzes spending patterns and habits
- Provides warnings about unhealthy spending habits
- Encourages positive financial behaviors
- Suggests cutting unnecessary expenses
- Promotes saving habits based on actual data

## 7. Category System

### Essential Categories (Always Enabled)
- **Housing (Nhà ở)**: Rent, mortgage, condo management fees
- **Food (Ăn uống)**: Dining out, groceries
- **Transport (Di chuyển)**: Gas, vehicle maintenance, parking fees
- **Utilities (Hóa đơn)**: Electricity, water, internet

### Lifestyle Categories (Customizable)
- **Health/Medical (Y tế/Sức khỏe)**: Doctor visits, medicine, health insurance, gym
  - Often top-3 unexpected expenses, needs separate tracking for emergency fund calculation
- **Education (Giáo dục)**: Tuition, books, courses
  - Large recurring expense for families with children or self-learners
- **Entertainment (Giải trí)**: Movies, travel, games, events
  - Different nature from "Dining out" - grouping causes spending habit analysis errors
- **Shopping (Mua sắm)**: Household appliances, electronics, cosmetics (excluding clothing)
  - "Clothing" is only a small branch of shopping, missing parent category
- **Debt Repayment (Trả nợ/vay)**: Installments, loan interest
  - Directly related to "Debt/Loan" feature planned for LV3, but monthly debt repayment is a spending category needed from LV1
- **Insurance (Bảo hiểm)**: Life insurance, vehicle insurance, home insurance
  - Recurring expense easily forgotten without separate category
- **Gifts/Charity (Quà tặng/Từ thiện)**: Different nature from "received gifts" (income) - this is spending
- **Personal Care (Chăm sóc cá nhân)**: Hair, spa, cosmetics
  - Separate from "Clothing" and "Medical"
- **Service Fees/Bank Fees (Phí dịch vụ/Ngân hàng)**: Transfer fees, annual card fees
  - Small but accumulates significantly, many apps miss this
- **Family/Children (Gia đình/Con cái)**: Milk, diapers, toys
  - For families with young children, this is a large expense group, completely missing

### Category Personalization
- **Location**: Profile page user settings
- **Logic**: User can enable/disable categories based on life stage
- **Examples**:
  - Single person: uncheck "Milk/Diapers"
  - Family expecting baby: check "Milk/Diapers"
  - Family with children: check "Milk" only

### Transaction Entry UI
- **4 Tabs**: "Chi tiêu" (Expense), "Thu nhập" (Income), "Đầu Tư" (Investment), "Vay Nợ" (Debt/Loan)
- **Tab Position**: Top of screen (TabHost)
- **Category Frame**: Horizontal listview with snap scroll to center
- **Amount Frame**: Select from suggestion list with dedicated currency keypad
- **Wallet Frame**: Horizontal listview with snap scroll to center
- **Date Frame**: Horizontal listview with snap scroll to center, click to show calendar

**Amount Entry Logic:**
- Design similar to Momo app
- Allow snap scroll to center (horizontal with dynamic item size)
- When entering numbers gradually, suggest amounts that jump like Momo app
- Support regional format shortcuts (e.g., Vietnam: 50.000đ → 50k, 1.000.000đ → 1tr; USA: 1.000.000usd → 1M)

## 8. Level Progression System

### Level 1 (Entry Level)
- **Locked Features**: Investment, Debt/Loan tabs (hidden)
- **Purpose**: Build habit of disciplined app usage, weekly audit cycles, ensure data accuracy
- **Unlock Level 2 Conditions**:
  - Complete 2 audits/reconciliations on fixed day within 2 consecutive weeks
  - If audit day changes, reset calculation mechanism
  - **Result**: Unlock Investment tab (show Investment tab on Transaction page)

### Level 2 (Intermediate)
- **Unlocked Features**: Investment tracking, Emergency Fund setup, Financial Freedom Index
- **Unlock Level 3 Conditions** (must meet all 3):
  1. Setup minimum: 3 budgets/minimum living expenses (mandatory monthly spending budgets)
  2. Complete 4 audits/reconciliations (minimum 4 consecutive weeks)
     - If audit day changes, reset calculation mechanism
  3. Achieve financial safety index (positive cash flow, calculated from recent month)
- **Result**: Unlock Debt/Loan feature

### Level 3 (Advanced)
- **Unlocked Features**: Debt/Loan management
- **Rationale**: This is an advanced, complex, difficult-to-manage feature
- Users must understand LV1 and LV2 business logic before accessing

## 9. Wallet Management (Budget Allocation)

### Wallet Types
- **Liquid Cash (Tiền thanh khoản)**: Editable name
- User can set custom names: cash, bank account

### Bank Account Format
- User enters bank account number, bank code
- Format example: vcb 777, vcb 888, hsbc 999
- Sorted by bank name A-Z, 0-9

### Functions
- **Add Wallet**: With custom name
- **Add Budget**: With custom budget name
- **Remove**: Bank wallet feature removed, change "cash" terminology to "Liquid Cash"

## 10. Data Schema Overview
Based on the SQL Schema, the following entities are required:

 Entity | Description |
 :--- | :--- |
 **User/Profile** | Authentication and preferences. |
 **Wallet (Nguồn Tiền)** | Physical or digital locations of money. |
 **Category** | Classification of income/expenses. |
 **Transaction (Phiếu Thu/Chi)** | Individual financial records. |
 **Budget (Ngân Sách)** | Spending limits per category/cycle. |
 **TimeBlock** | Habit and time management tracking linked to roles. |
 **Audit (Kiểm Toán)** | System vs. Actual balance reconciliation. |
 **Weekly Snapshot** | Historical performance tracking. |
