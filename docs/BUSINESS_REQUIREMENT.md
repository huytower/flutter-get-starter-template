# Business Requirement - Personal Finance Management (QLTC)

## 1. Overview
The QLTC (Quản Lý Tài Chính) application is a modular personal finance management system designed with the philosophy: **"Smart, Effective, and Disciplined Spending"**. It aims to help users track their income/expenses, manage multiple wallets, maintain a financial "survival" runway, and eventually leverage AI for optimized budgeting and fast data entry.

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

## 3. Key Modules & Features

### Financial Runway (Survival Indicator)
- **Formula**: `Total Available Balance / Average Monthly Expenses`.
- **Display**: "With current money, you can sustain your life for X months and Y days."
- **Goal**: Provide a clear "Safety Index" to reduce stress and improve decision-making.

### Smart Budgeting
- **Category Limits**: Set max spend per category.
- **Warning System**: Real-time warnings when spending approaches or exceeds the threshold.

### Debt & Loan Management
- Track money owed to others (Debts) and money others owe to the user (Loans).
- Link payments to specific wallets and expense slips.

### AI Integration (Roadmap LV2/LV3)
- **NLP Simple**: Parse text entries like "50k cafe" into `amount: 50,000` and `category: Cafe`.
- **Smart Suggestions**: Suggest categories based on **Time** (e.g., 7 AM -> Breakfast) and **Location** (GPS proximity to frequent vendors).
- **Autofill**: Predict fields based on user habits and historical data.
- **Spending Optimization**: AI suggestions to cut unnecessary expenses and encourage saving habits.

## 4. Technical Requirements (System SSOT)

### Architecture
- **Framework**: Flutter (Multi-screen support).
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers).
- **State Management**: Agnostic design (Supports GetX and Bloc via mixins).
- **Dependency Injection**: `get_it` with `injectable` (Micro-package pattern).

### UI/UX Standards
- **Color Palette**: Professional blue and white tone.
- **Multi-Screen Support**: (Validated) Must use `CcResponsiveExtension` (`respPadding`, `respFontSize`, `respIconSize`, `respDim`) from `cc_sdk_ui`.
- **Typography**: Single font family inherited from theme (**EB Garamond**).
- **Efficiency**: Minimize clicks for common actions (Frequently Used section).

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
When implementing features, always refer to:
1.  **AI_CONTEXT.md**: For technical guardrails, responsiveness, and architecture rules.
2.  **BUSINESS_REQUIREMENT.md**: For business logic, data structures, and feature priorities.
