# Business Requirement - Personal Finance Management (QLTC)

## 1. Overview
The QLTC (Quản Lý Tài Chính) application is a modular personal finance management system designed with the philosophy: **"Smart, Effective, and Disciplined Spending"**. It aims to help users track their income/expenses, manage multiple wallets, maintain a financial "survival" runway, and eventually leverage AI for optimized budgeting and fast data entry.

**Development Phases:**
- **MVP (LV1)**: Core transaction management, basic reporting, wallet management
- **LV2**: Smart budgeting, AI-powered suggestions, NLP entry
- **LV3**: Advanced features (Emergency Fund, Debt/Loan management, Investment tracking)

## 2. Core Business Processes

### A. Initialization & Setup
- **Wallet Declaration**: Users define various income sources and wallets (Cash, Bank, e-Wallet).
- **Initial Balance**: Set the starting amount for each wallet.
- **Budgeting**: Define monthly spending limits for specific categories (e.g., Food, Shopping).

### B. Daily Transaction Management
- **Immediate Entry**: Encourage users to record transactions within 5 seconds of occurrence.
- **Transaction Types**:
    - **Income (Thu)**: Record money received.
    - **Expense (Chi)**: Record money spent, linked to a specific Category and Budget.
    - **Transfer (Điều chuyển)**: Move money between wallets (e.g., ATM withdrawal).
    - **Investment (Đầu tư)**: Specific tracking for money allocated to investment funds.
    - **Emergency Fund Withdrawal (Rút quỹ dự phòng)**: Track use of reserved survival funds.

### C. Reconciliation & Audit (Weekly/Monthly)
- **Financial Audit (Kiểm toán)**: Compare system balances with actual physical cash/bank balances.
- **Adjustment Slips**: Automatically generate income/expense slips to fix discrepancies found during audits.
- **Weekly Snapshot**: Freeze data weekly to track trends in income, survivor expenses, and debt pressure.
- **Weekly Reporting**: User selects a fixed day each week for reporting/reconciliation/audit.
  - Push notification when approaching and on the reporting day (max 2 reminders if user forgets)
  - No reminders if already completed
  - No reminders after first notification if user has completed the task

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

## 3. Key Modules & Features

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

### Investment Tracking (LV3)
- Track money allocated to investment funds
- Monitor investment performance over time
- Separate from daily spending to ensure clear financial visibility

### AI Integration (LV2/LV3)

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
- Single-line text input: "50k cafe"
- App automatically parses: Amount = 50,000, Category = Cafe
- Reduces entry time to seconds

**Quick Templates:**
- Users can create "Fixed cost" templates for recurring expenses
- Examples: "Đổ xăng 50k", "Ăn cơm trưa 35k"
- One-tap completion for frequent transactions

**Spending Optimization (LV2):**
- AI analyzes spending patterns and habits
- Provides warnings about unhealthy spending habits
- Encourages positive financial behaviors
- Suggests cutting unnecessary expenses
- Promotes saving habits based on actual data

## 5. Data Schema Overview
Based on the SQL Schema, the following entities are required:

| Entity | Description |
| :--- | :--- |
| **User/Profile** | Authentication and preferences. |
| **Wallet (Nguồn Tiền)** | Physical or digital locations of money. |
| **Category** | Classification of income/expenses. |
| **Transaction (Phiếu Thu/Chi)** | Individual financial records. |
| **Budget (Ngân Sách)** | Spending limits per category/cycle. |
| **TimeBlock** | Habit and time management tracking linked to roles. |
| **Audit (Kiểm Toán)** | System vs. Actual balance reconciliation. |
| **Weekly Snapshot** | Historical performance tracking. |

## 6. Development Strategy

### Phased Development Approach
**Phase 1 - MVP (LV1):**
- Core transaction management (Income, Expense, Transfer)
- Wallet management (Cash, Bank, e-Wallet)
- Basic reporting (Weekly/Monthly charts)
- Category management with personalization
- "Frequently Used" quick access section

**Phase 2 - Smart Features (LV2):**
- Smart Budgeting with warning system
- AI-powered Smart Entry (NLP, Autofill, Templates)
- Smart Suggestions (Time-based, Location-based)
- Spending optimization recommendations
- Enhanced reporting with yearly views

**Phase 3 - Advanced Features (LV3):**
- Emergency Fund & Financial Runway tracking
- Debt & Loan Management (4th tab)
- Investment tracking
- AI Chatbot integration
- Bank SMS parsing
- Voice input capabilities