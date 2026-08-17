// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader {
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String, dynamic> _en = {
    "app": {
      "name": "Starter App",
      "version": "Version {version}",
      "description": "Lean and efficient personal finance management",
      "slogan":
          "Manage income, expenses, investment, debt according to single-entry accounting principle, towards financial freedom",
      "copyright": "© 2026 So Sach Xin · Made by",
      "copied_email": "Copied email: {email}",
      "author": "by Huy Tower",
      "role_tech": "Tech",
      "role_hr": "HR",
      "author_hr_name": "Kien Nguyen",
      "author_hr_email": "kien.1000doanhnhan@gmail.com",
      "author_tech_name": "Huy Tran",
      "author_tech_email": "huytd46.fpt@gmail.com",
      "address": "Vinhome Grand Park, District 9",
      "loading": "Loading...",
      "error": {
        "general": "An error occurred",
        "retry": "Tap here to reload",
        "network": "Network error. Please check your connection.",
        "server": "Server error. Please try again later.",
      },
      "app_check": {
        "initialization_failed":
            "App Check initialization failed. Please restart the app.",
        "token_refresh_failed":
            "Failed to refresh security token. Please check your connection.",
        "device_not_verified":
            "Device verification failed. This device may not be supported.",
      },
    },
    "common": {
      "ok": "OK",
      "cancel": "Cancel",
      "save": "Save",
      "delete": "Delete",
      "edit": "Edit",
      "back": "Back",
      "continue": "Continue",
      "next": "Next",
      "skip": "Skip",
      "done": "Done",
      "search": "Search",
      "no_results": "No results found",
      "no_data": "No data found",
      "or": "OR",
      "not_set": "Not set",
      "sunday_short": "Sun",
      "select_date": "Select Date",
      "income": "Income",
      "expense": "Expense",
      "common_weekday_names": "Mon|Tue|Wed|Thu|Fri|Sat|Sun",
      "press_back_again_to_exit": "Press back again to exit",
      "add_source": "Add Source",
      "add": "Add",
      "copy": "Copy",
      "clear": "Clear",
      "unit_billion": "B",
      "unit_million": "M",
      "unit_thousand": "k",
    },
    "auth": {
      "login": "Login",
      "logout": "Logout",
      "email": "Email",
      "password": "Password",
      "forgot_password": "Forgot Password?",
      "signup": "Sign Up",
      "no_account": "Don't have an account?",
      "have_account": "Already have an account?",
      "login_success": "Login successful",
      "login_failed": "Login failed. Please check your credentials.",
      "login_google": "Login with Google",
      "login_apple": "Login with Apple",
      "login_phone": "Login with Phone Number",
      "enter_phone_number": "Log in with \n Phone Number",
      "phone_number": "Phone Number",
      "phone_number_hint": "Enter phone number",
      "phone_hint": "+1234567890",
      "verify": "Verify",
      "send_code": "Send Code",
      "enter_code": "Enter SMS Code",
      "we_just_sent_sms": "We just sent an SMS",
      "enter_security_code": "Enter the security code we sent to",
      "didnt_receive_code": "Didn't receive code?",
      "resend": "Resend after",
      "terms_and_privacy":
          "By continuing, you agree to our Terms of Service and Privacy Policy",
      "biometric": {
        "reason": "Authentication required",
        "fallback": "Please enable biometrics for this app in Settings.",
        "not_available_log": "Biometric authentication not available",
        "init_error": "Biometric initialization error: {error}",
        "error": {
          "not_available":
              "Biometric authentication is not available on this device.",
          "not_enrolled": "No biometrics enrolled on this device.",
          "locked_out": "Too many failed attempts. Try again later.",
          "permanently_locked_out":
              "Biometric authentication is permanently locked out.",
          "passcode_not_set": "No passcode is set on the device.",
          "user_canceled": "Authentication was canceled by user.",
          "app_canceled": "Authentication was canceled by the app.",
          "system_canceled": "Authentication was canceled by the system.",
          "generic": "Authentication error: {error}",
        },
      },
      "otp": {
        "invalid": "Invalid OTP code",
        "expired": "OTP code has expired",
        "too_many_attempts": "Too many attempts. Please try again later",
      },
    },
    "validation": {
      "required": "This field is required",
      "email": "Please enter a valid email",
      "password_length": "Password must be at least {length} characters",
      "password_match": "Passwords do not match",
      "phone": "Invalid phone number format",
    },
    "home": {
      "title": "Home",
      "welcome": "Welcome, {name}!",
      "recent_activity": "Recent Activity",
      "view_all": "View All",
      "my_wallets": "My Wallets",
    },
    "settings": {
      "title": "Settings",
      "language": "Language",
      "language_vietnamese": "Vietnamese",
      "language_english": "English",
      "theme": "Theme",
      "theme_static": "Static",
      "notifications": "Notifications",
      "privacy": "Privacy",
      "help": "Help & Support",
      "about": "About",
    },
    "nav": {
      "home": "Home",
      "transaction": "Transaction",
      "budget_allocation": "Budget Allocation",
      "dashboard": "Dashboard",
      "quick_test": "Quick Test",
      "quick_test_page": "Quick Testing Page",
      "notification": "Notification",
      "profile": "Profile",
      "profile_info": "Personal Information",
    },
    "dashboard": {
      "item_count": "Item Count",
      "last_updated": "Last Updated",
      "refresh_data": "Refresh Data",
      "time": {
        "just_now": "Just now",
        "day": "{count} day ago",
        "days": "{count} days ago",
        "hour": "{count} hour ago",
        "hours": "{count} hours ago",
        "minute": "{count} minute ago",
        "minutes": "{count} minutes ago",
      },
    },
    "wallet": {
      "my_account": "My Account",
      "spending_account": "Spending Account",
      "total_assets": "Total Assets",
      "your_wallets": "Liquid wallets",
      "see_all": "See all",
      "empty": "No wallets yet.\nTap + to add one.",
      "investment_empty": "No investment wallets yet\nTap + to add ",
      "investment_name": "Investment Name",
      "investment_name_hint": "e.g. BTC, Apple Stock...",
      "add_title": "Add New Wallet",
      "edit_title": "Edit Wallet",
      "name": "Wallet Name",
      "name_hint": "e.g. Cash, Techcombank...",
      "initial_balance": "Opening Balance",
      "initial_balance_hint": "e.g. 1000000",
      "balance_locked_hint":
          "Cannot change opening balance once the wallet has transactions",
      "save_info": "Save",
      "bank": "Bank",
      "ewallet": "E-wallet",
      "emergency_fund": "Emergency Fund",
      "emergency_fund_desc":
          "For emergencies · aim to keep 3-6 months of expenses",
      "emergency_fund_locked_hint":
          "Opens at LV2, after you've read the Emergency Fund guide",
      "emergency_fund_view_ebook": "Read the guide",
      "added_success": "New wallet added",
      "updated_success": "Wallet updated",
      "delete_title": "Delete Wallet",
      "delete_confirm_msg":
          "A wallet can only be deleted when its balance is 0. All transactions of the wallet will be soft-deleted. Continue?",
      "investment_delete_title": "Delete Investment",
      "investment_delete_confirm":
          "Deleting an investment item is only possible when its total performance value is 0. All related transactions will be soft-deleted. Continue?",
      "delete_error_not_empty": "Cannot delete: wallet balance must be 0",
      "delete_error_protected": "This wallet is required and cannot be deleted",
      "liquid_assets": "Liquid Assets",
      "liquid_assets_desc": "Cash + Bank + E-wallet · ready to spend",
      "investments": "Investments / Accumulation",
      "investments_desc": "Stocks, funds, real estate... · Avg ROI {roi}%",
      "liabilities": "Liabilities",
      "liabilities_desc":
          "Loans + Credit cards · balance tracking, stress monitor",
      "liabilities_net": "Net Liability",
    },
    "comment": {
      "detail": {
        "title": "Comment Detail",
        "content": "Comment Content",
        "post_id": "Post ID",
        "id": "Comment ID",
      },
    },
    "transaction": {
      "title": "Transaction",
      "wallet": "Total Wallet",
      "emergency": "Emergency",
      "investment": "Investment",
      "debt": "Debt & Loan",
      "category": "Category",
      "amount": "Amount",
      "source_expense": "Source of Expense",
      "reason_expense": "Reason for Expense",
      "enter_content": "Enter content",
      "payer": "Payer",
      "staff_name": "Staff Name",
      "time": "Time",
      "history": "History",
      "record_expense": "Record Expense",
      "expense_saved": "Expense of {amount} đ saved successfully!",
      "income_saved": "Income of {amount} đ saved successfully!",
      "expense_updated": "Expense of {amount} đ updated!",
      "income_updated": "Income of {amount} đ updated!",
      "edit_title": "Edit transaction",
      "source_income": "Source of Income",
      "reason_income": "Reason for Income",
      "recipient": "Recipient",
      "record_income": "Record Income",
      "source_investment": "Source of Investment",
      "destination_investment": "Receiving wallet",
      "record_investment": "Record Investment",
      "investment_saved": "Investment of {amount} đ saved successfully!",
      "source_debt": "Source of Debt",
      "record_debt": "Record Debt",
      "debt_saved": "Debt of {amount} đ saved successfully!",
      "loan_direction_borrow": "Borrow",
      "loan_direction_lend": "Lend",
      "loan_category_borrow_label": "Loan type",
      "loan_amount_borrow_label": "Loan amount",
      "loan_wallet_borrow_label": "Receiving wallet",
      "loan_category_lend_label": "Lending type",
      "loan_amount_lend_label": "Lending amount",
      "loan_wallet_lend_label": "Lending wallet",
      "loan_borrower_label": "Loan name",
      "loan_borrower_hint": "e.g. House purchase loan, Loan to a friend...",
      "loan_collection_method_label": "Collection method",
      "loan_method_installment_lend": "Installments",
      "loan_method_lump_sum_lend": "Due date / Collect once",
      "loan_schedule_lend_label": "Collection schedule",
      "loan_reminder_once_label": "Remind 1 day before",
      "loan_reminder_recurring_label": "Remind 1 day before each due date",
      "loan_name_label": "Loan name",
      "loan_name_hint": "e.g. Laptop purchase, Bank loan...",
      "loan_counterparty_vip_locked":
          "Free plan uses the category's default name '{name}'. Upgrade to VIP to set a custom name.",
      "loan_repayment_method_label": "Repayment method",
      "loan_method_installment": "Installment",
      "loan_method_lump_sum": "Lump sum at maturity",
      "loan_final_due_date_label": "Due date",
      "loan_schedule_label": "Installment schedule",
      "loan_add_period": "Add period",
      "loan_saved": "Loan of {amount} đ recorded!",
      "loan_payment_saved": "Payment of {amount} đ recorded!",
      "record_loan": "Record Loan",
      "record_repay": "Repay",
      "record_collect": "Collect",
      "investment_contribution": "Contribute",
      "investment_return": "Return",
      "dest_investment": "Receive into wallet",
      "record_investment_return": "Record Return",
      "investment_item": "Investment Item",
      "add_new_investment_item": "New item",
      "new_investment_item_hint": "Item name (e.g. Coffee shop)",
      "no_investment_items_hint":
          "No investment items in this category yet — contribute first.",
      "investment_item_vip_locked":
          "Free plan uses the category's default name '{name}'. Upgrade to VIP to set a custom item name.",
      "expense_slip": "Expense",
      "income_slip": "Income",
      "category_sub": "Sub-category",
      "today": "Today",
      "yesterday": "Yesterday",
      "note": "Note",
      "note_hint": "Note (optional)",
      "more_details": "More details",
      "merchant_match_hint": "Like last time: {label}",
      "location_match_hint": "You're nearby: {label}",
      "quick_entry_label": "Quick entry (AI)",
      "quick_entry_hint": "spend phone fifty thousand dong cash",
      "quick_entry_parsed_result": "Got it: {label}",
      "quick_entry_could_not_parse":
          "Couldn't understand that — please fill in manually",
      "quick_entry_cloud_consent_message":
          "To understand this, we'd send it to an AI service (Gemini). Continue?",
      "quick_entry_cloud_consent_accept": "Allow",
      "quick_entry_cloud_consent_decline": "Not now",
      "quick_entry_daily_limit_reached":
          "Daily AI quick-entry limit reached — please fill in manually",
      "quick_entry_mic_permission_denied":
          "Microphone access is needed for voice entry",
      "quick_entry_photo_permission_denied":
          "Camera/photo access is needed to scan a receipt",
      "quick_entry_scan_receipt": "Scan a receipt",
      "quick_entry_take_photo": "Take photo",
      "quick_entry_choose_gallery": "Choose from gallery",
      "claims_in_progress": "You have {count} claims in progress",
      "validation": {
        "amount_required": "Amount must be greater than 0",
        "wallet_required": "Please select a wallet",
        "category_required": "Please select a category",
        "future_date": "Cannot record a future transaction",
        "insufficient_balance": "Insufficient wallet balance",
        "counterparty_required": "Please enter who the loan is with",
        "schedule_required": "Please enter the repayment schedule",
        "amount_exceeds_outstanding": "Amount exceeds remaining balance",
        "loan_settled": "This loan is already settled",
        "not_editable": "This transaction can't be edited",
        "edit_window": "You can only edit transactions from the last 30 days",
      },
    },
    "loan": {
      "list_title": "Loans",
      "status_outstanding": "Outstanding",
      "status_settled": "Settled",
      "remaining_balance": "Remaining",
      "principal_amount": "Principal",
      "empty_state": "No loans yet",
      "history_title": "Transaction history",
      "no_history": "No repayment/collection yet",
      "borrow": "Borrow",
      "lend": "Lend",
    },
    "notification": {
      "channel_name": "Reminders",
      "channel_description":
          "Notifications for audit reminders, Cloud registration, and loan due dates",
      "audit_approaching_title": "Audit day is approaching",
      "audit_approaching_body":
          "Tomorrow is your weekly audit day. Don't forget to reconcile your balances!",
      "audit_due_title": "Audit day is here",
      "audit_due_body":
          "Today is your weekly audit day. Reconcile your balances now!",
      "cloud_backup_title": "Protect your data",
      "cloud_backup_body":
          "Register an account to back up your data to the Cloud and avoid losing it.",
      "loan_due_title": "Loan due date approaching",
      "loan_due_body": "Loan '{name}' is due on {date}.",
      "budget_near_limit_body": "Budget \"{name}\" reached 80%.",
      "budget_over_body": "Budget \"{name}\" exceeded its limit.",
    },
    "tutorial": {
      "nav_title": "Your navigation bar",
      "nav_desc":
          "Phân bổ shows your wallets and budgets, Giao dịch logs a transaction, Hồ sơ is your profile and settings.",
      "transaction_title": "Log a transaction",
      "transaction_desc":
          "Pick Chi tiêu/Thu nhập/Đầu tư/Vay-Nợ here, then fill in the amount and save.",
    },
    "budget": {
      "title": "Budget",
      "description":
          "Limit is the maximum amount you allow for a category per month — exceeding it means spending beyond your plan.",
      "empty": "No budgets yet.\nTap + to add a spending limit.",
      "edit_limit": "Edit Limit",
      "edit_title": "Edit Budget",
      "limit_locked":
          "The limit can only be changed in the first 7 days of the month.",
      "delete_title": "Delete Budget",
      "delete_confirm": "Delete \"{name}\"?",
      "reset_period": "Reset Period",
      "reset_title": "Reset Budget",
      "add_title": "Add Budget",
      "name": "Budget Name",
      "name_hint": "e.g. Electricity for Building A",
      "name_duplicate_error": "Budget name already exists",
      "category": "Category",
      "limit": "Limit",
      "limit_hint": "e.g. 1000000",
      "start_date": "Start",
      "end_date": "End",
      "added": "Budget \"{name}\" added",
      "updated": "Budget \"{name}\" updated",
      "period_started": "New period started for \"{name}\"",
      "over_limit": "You exceeded the limit!",
      "near_limit": "Approaching the limit!",
      "over_limit_count":
          "You've exceeded the \"{name}\" limit {count} times this month!",
      "over_by": "Over by {amount}",
      "remaining": "Remaining {amount}",
      "this_month": "This month's budgets",
      "see_all": "See all",
      "drag_reorder_hint": "Hold and drag to reorder",
      "customize_category": "Customize category",
      "percent_used": "{percent}% used",
      "fixed_price": "Fixed Price",
      "fixed_price_description":
          "Fixed monthly costs (minimum survival cost), affecting your safety index in the report section.",
      "pacing_hint": "{name}: {days} days left · Suggested ≤{amount}/day",
      "penalty_warning": "{name} exceeded {percent}%!",
      "deficit_warning":
          "Spending more than income this month (deficit {amount})",
      "anomaly_hint":
          "{count} unusual expense(s) vs. the last 3 months' average",
      "insights_title": "Insights & warnings",
      "insights_action_review": "View report",
      "estimate_hint": "Suggested: {amount} (last 3-month avg)",
    },
    "reconciliation": {
      "title": "Reconciliation",
      "empty": "No wallets to reconcile.",
      "instruction": "Enter the actual counted balance for each wallet:",
      "book_total": "Book Total",
      "actual_total": "Actual Total",
      "difference": "Difference",
      "balanced": "Balanced ✓",
      "surplus": "Surplus {amount}",
      "deficit": "Deficit {amount}",
      "confirm": "Confirm Reconciliation",
      "success": "Reconciliation confirmed",
      "success_message":
          "Congratulations! You have completed reconciliation #{count} successfully.",
      "history": "Reconciliation History",
      "undo": "Undo",
      "undo_title": "Undo Reconciliation",
      "undo_confirm":
          "Undo the latest reconciliation and remove the adjustment entries?",
      "week": "Week {week}/{year}",
      "book": "Book",
      "actual": "Actual",
      "book_balance": "Book: {amount}",
      "cycle_subtitle": "This week · due Sunday",
      "description_line_1":
          "Reconciliation helps you match actual balances with the app to ensure all financial records are always accurate and transparent.",
      "description_line_2":
          "Automatically generate adjustment entries to match app balances with reality without needing to review missed transactions.",
      "mismatch_warning":
          "{count} wallet(s) unmatched, handle before confirming",
      "create_adjustment": "Create adjustment",
      "matched": "Balanced",
      "lech": "Off by {amount}",
      "review_transactions": "Review transactions",
    },
    "report": {
      "title": "Report",
      "spending_proportion": "Spending Distribution",
      "monthly_chart": "Income & Expense",
      "this_week": "This Week",
      "four_weeks_near": "Last 4 weeks",
      "this_month": "This Month",
      "no_expense": "No expenses in this period.",
      "weekly": "Weekly",
      "monthly": "Monthly",
      "yearly": "Yearly",
      "three_months": "3 Months",
      "income_expense": "Income & Expense",
      "safety_index": "Safety Index (Runway)",
      "runway_desc_2":
          "Runway shows how long you could survive without income, and helps you see your accumulation through the monthly income & expense chart so you can adjust toward a more sustainable financial plan.",
      "runway_message": "You can sustain for {months} months {days} days",
      "runway_fixed_price_desc": "Serious financial management lifestyle",
      "runway_no_fixed_price_desc":
          "Runway uses your actual spending. Set fixed costs for a more accurate estimate.",
      "runway_perfect": "Your spending is excellent!",
      "runway_very_good": "Excellent! You have over a year of buffer",
      "runway_good": "Very good! Your safety index is quite high",
      "runway_safe": "Safe! You have at least 3 months of buffer",
      "runway_caution": "Caution! You should build more buffer",
      "runway_insufficient":
          "Start recording expenses so the system can calculate your safety index",
      "runway_not_available": "Insufficient data",
      "investment_title": "Investments",
      "investment_contributed": "Contributed",
      "investment_returned": "Returns",
      "loan_title": "Loans",
      "loan_in": "Borrowed / Collected",
      "loan_out": "Lent / Repaid",
      "daily_detail": "Daily Detail",
      "income_short": "Inc",
      "expense_short": "Exp",
      "uncategorized": "Uncategorized",
      "filtering_wallet": "Filtering: {wallet}",
      "filter_by_wallet": "Filter by wallet",
      "filter_all_wallets": "All wallets",
      "trend_week_label": "Week {number}",
      "ai_advice_title": "AI Financial Advice",
      "ai_advice_empty_body":
          "Get a personalized review of this month's spending and suggestions to improve your finances.",
      "ai_advice_generate_cta": "Generate advice",
      "ai_advice_loading": "Generating advice...",
      "ai_advice_generate_failed":
          "Couldn't generate advice right now, please try again.",
      "ai_advice_daily_limit_reached":
          "You've reached today's AI advice limit. Please try again tomorrow.",
      "ai_advice_generated_just_now": "Generated just now",
      "ai_advice_generated_minutes_ago": "Generated {count} minutes ago",
      "ai_advice_generated_hours_ago": "Generated {count} hours ago",
      "ai_advice_generated_days_ago": "Generated {count} days ago",
    },
    "category": {
      "group_daily": "Daily",
      "group_personal": "Personal",
      "group_food_drink": "Dining & Coffee",
      "group_transport": "Transportation",
      "group_utilities": "Utilities",
      "group_housing": "Housing",
      "group_health": "Medical & Health",
      "group_education": "Education",
      "group_entertainment": "Entertainment",
      "group_shopping": "Shopping",
      "group_insurance": "Insurance",
      "group_gifts": "Gifts & Charity",
      "group_personal_care": "Personal Care",
      "group_service_fees": "Service Fees",
      "group_family": "Family & Children",
      "food": "Food",
      "transport": "Transport",
      "shopping": "Shopping",
      "health": "Health",
      "food_drink": "Food & Drink",
      "coffee": "Coffee",
      "water": "Water",
      "eat_out": "Eat Out",
      "taxi": "Taxi",
      "gas": "Gas",
      "parking": "Parking",
      "maintenance": "Maintenance",
      "electricity": "Electricity",
      "internet": "Internet",
      "phone": "Phone",
      "rent": "Rent",
      "furniture": "Furniture",
      "laundry": "Laundry",
      "mortgage": "Mortgage",
      "condo_fee": "Condo Fee",
      "doctor": "Doctor",
      "medicine": "Medicine",
      "health_insurance": "Health Insurance",
      "gym": "Gym",
      "tuition": "Tuition",
      "books": "Books",
      "courses": "Courses",
      "cinema": "Cinema",
      "travel": "Travel",
      "gaming": "Gaming",
      "events": "Events",
      "appliances": "Appliances",
      "electronics": "Electronics",
      "clothing": "Clothing",
      "cosmetics": "Cosmetics",
      "installment": "Installment",
      "life_insurance": "Life Insurance",
      "vehicle_insurance": "Vehicle Insurance",
      "home_insurance": "Home Insurance",
      "gifts": "Gifts",
      "charity": "Charity",
      "haircut": "Haircut",
      "spa": "Spa",
      "personal_care_product": "Personal Care",
      "bank_fee": "Bank Fee",
      "card_fee": "Card Annual Fee",
      "milk_formula": "Milk Formula",
      "diapers": "Diapers",
      "baby_toys": "Baby Toys",
      "settings_title": "Customise Categories",
      "settings_subtitle": "Select the categories that suit your lifestyle",
      "settings_save": "Save & Continue",
      "settings_saved": "Categories updated successfully",
      "income_settings_title": "Income Categories",
      "income_group_active": "Active Income",
      "income_group_invest": "Investment Income",
      "income_group_other": "Other Income",
      "income_salary": "Main Salary",
      "income_freelance": "Freelance",
      "income_allowance": "Allowance",
      "income_savings_interest": "Savings Interest",
      "income_dividends": "Dividends",
      "income_rental": "Asset Rental",
      "income_bonus": "Bonus",
      "income_gift": "Gifts/Presents",
      "income_cashback": "Cashback",
      "debt_loan_settings_title": "Debt & Loan Categories",
      "debt_group_borrow": "Borrowing",
      "debt_group_lend": "Lending",
      "debt_personal_borrow": "Personal Loan",
      "debt_bank_borrow": "Bank/Financial Institution Loan",
      "debt_mortgage": "Mortgage",
      "debt_credit_card": "Credit Card Debt",
      "debt_installment": "Installment",
      "debt_personal_lend": "Personal Lending",
      "debt_other": "Other",
      "debt_other_lend": "Other",
      "investment_settings_title": "Investment Categories",
      "investment_group_default": "Investments",
      "investment_stock": "Stock",
      "investment_fund": "Fund",
      "investment_bond": "Bond",
      "investment_term_deposit": "Term Deposit",
      "investment_gold": "Gold",
      "investment_real_estate": "Real Estate",
      "investment_crypto": "Crypto",
      "investment_business": "Business",
      "investment_linked_insurance": "Investment-linked Insurance",
      "investment_other": "Other",
      "expense_settings_title": "Expense Categories",
    },
    "sync": {
      "offline_tooltip":
          "Offline — your data is only saved on this device until you reconnect",
      "pending_tooltip":
          "{count} item(s) not yet backed up to Cloud — tap to sync",
      "synced_tooltip": "All data backed up to Cloud",
    },
    "profile": {
      "guest": "Guest",
      "not_logged_in": "Not logged in",
      "register_login": "Register / Login",
      "display_name_title": "Edit name",
      "display_name_hint": "Enter your display name",
      "display_name_save": "Save",
      "display_name_updated": "Name updated",
      "link_account_title": "Link account",
      "link_account_subtitle": "Sign in with either phone or Google",
      "link_account_google": "Google",
      "link_account_phone": "Phone number",
      "link_account_linked": "Linked",
      "link_account_action": "Link",
      "link_account_success": "Linked successfully",
      "link_account_phone_hint": "Enter phone number",
      "link_account_send_code": "Send code",
      "link_account_verify_code": "Verify",
      "birth_year": "Birth year",
      "birth_year_subtitle": "Used to suggest appropriate categories",
      "birth_year_task_desc": "Task: set up your birth year",
      "birth_year_hint":
          "Choose your actual birth year, it affects your daily income and expense calculations",
      "weekly_audit": "Weekly audit",
      "weekly_audit_day_hint":
          "Select your weekly audit day, usually at the end of your spending cycle",
      "days_left": "{count} days left",
      "debt_loan": "Debt / Loan",
      "unlock_at_lv": "Opens at LV{level}",
      "unlocked": "Unlocked",
      "vip": "VIP",
      "vip_subtitle":
          "Lifts the free-tier limit on Investment items / Loan records (local toggle, no real payment yet)",
      "force_full_access": "Unlock all features",
      "force_full_access_subtitle":
          "Debug/QA override — instantly unlocks Investment + Debt/Loan (LV3), regardless of your actual progress",
      "weekly_audit_day": "Weekly audit day",
      "weekly_audit_day_subtitle": "The day you review your weekly balance",
      "reminder": "Reminders",
      "reminder_subtitle": "Get notified to record your reconcile",
      "theme_subtitle": "Switch between light and dark mode",
      "language_subtitle": "Select your preferred language",
      "currency": "Currency unit",
      "currency_subtitle": "Change your primary currency unit",
      "currency_dong": "Dong",
      "view_tutorial": "View tutorial again",
      "view_tutorial_subtitle": "Learn how to use the app effectively",
      "terms": "Terms of use",
      "terms_subtitle": "Read our service terms and privacy policy",
      "about": "About app",
      "about_subtitle": "App information and developer logs",
      "delete_account": "Delete account",
      "delete_confirm": "Delete Account?",
      "delete_confirm_desc":
          "This will permanently delete your account and all associated data. This action cannot be undone.",
      "young_children_message":
          "Do you have young children? If yes, we'll automatically enable kid-related categories (milk, diapers, toys).",
      "experience_level_progress": "Experience Level Progress",
      "level_title": "Level {level} ({title})",
      "tap_to_return": "Tap to return to profile",
      "streak_weeks": "Streak: {count} weeks",
      "level_master": "Master",
      "level_intermediate": "Intermediate",
      "level_novice": "Novice",
      "progress_steps": "Progress: {completed}/{total}",
    },
    "guideline": {
      "banner_title_completed": "Congrats! All setup steps completed",
      "banner_title_in_progress": "Challenge: {remaining} remaining steps",
      "banner_desc_completed":
          "Now you can start managing your finances in a disciplined way.",
      "banner_desc_birth_year":
          "Set your birth year to receive suitable suggestions",
      "banner_desc_categories": "Select your expense and income categories",
      "banner_desc_wallet_balance": "Set the current balance for your wallet",
      "banner_desc_modify_cash": "Modify the amount value in your cash wallet",
      "banner_desc_budget_limit": "Set spending limits for each category",
      "banner_desc_min_living": "Define your minimum monthly living expenses",
      "banner_desc_first_transaction": "Record your first expense transaction",
      "banner_desc_default": "You are ready to manage your finances!",
      "success_dialog_message":
          "Congratulations!\nYou have completed the initial setup.",
      "reset_confirm_desc":
          "You have {count} completed tasks. Resetting will undo all progress.",
      "reset_confirm_agree": "View Tutorial",
      "reset_confirm_cancel": "Cancel",
    },
  };
  static const Map<String, dynamic> _vi = {
    "app": {
      "name": "Ứng dụng mẫu",
      "version": "Phiên bản {version}",
      "description": "Quản lý tài chính cá nhân tinh gọn và hiệu quả",
      "slogan":
          "Quản lý thu chi, đầu tư, vay nợ theo nguyên lý kế toán đơn, hướng đến tự do tài chính",
      "copyright": "© 2026 Sổ Sách Xịn · Made by",
      "copied_email": "Đã sao chép email: {email}",
      "author": "bởi Huy Tower",
      "role_tech": "Kỹ thuật",
      "role_hr": "HR",
      "author_hr_name": "Kien Nguyen",
      "author_hr_email": "kien.1000doanhnhan@gmail.com",
      "author_tech_name": "Huy Tran",
      "author_tech_email": "huytd46.fpt@gmail.com",
      "address": "Vinhome Grand Park, Quận 9",
      "loading": "Đang tải...",
      "error": {
        "general": "Đã xảy ra lỗi",
        "retry": "Nhấn vào đây để tải lại",
        "network": "Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn.",
        "server": "Lỗi máy chủ. Vui lòng thử lại sau.",
      },
      "app_check": {
        "initialization_failed":
            "Khởi tạo App Check thất bại. Vui lòng khởi động lại ứng dụng.",
        "token_refresh_failed":
            "Không thể làm mới mã bảo mật. Vui lòng kiểm tra kết nối của bạn.",
        "device_not_verified":
            "Xác minh thiết bị thất bại. Thiết bị này có thể không được hỗ trợ.",
      },
    },
    "common": {
      "ok": "Đồng ý",
      "cancel": "Hủy",
      "save": "Lưu",
      "delete": "Xóa",
      "edit": "Sửa",
      "back": "Quay lại",
      "continue": "Tiếp tục",
      "next": "Tiếp theo",
      "skip": "Bỏ qua",
      "done": "Xong",
      "search": "Tìm kiếm",
      "no_results": "Không tìm thấy kết quả",
      "no_data": "Không có dữ liệu",
      "income": "Thu nhập",
      "not_set": "Chưa đặt",
      "sunday_short": "CN",
      "select_date": "Chọn ngày",
      "expense": "Chi tiêu",
      "common_weekday_names":
          "Thứ Hai|Thứ Ba|Thứ Tư|Thứ Năm|Thứ Sáu|Thứ Bảy|Chủ Nhật",
      "or": "HOẶC",
      "press_back_again_to_exit": "Nhấn lại để thoát",
      "add_source": "Thêm nguồn",
      "add": "Thêm",
      "copy": "Sao chép",
      "clear": "Xóa",
      "unit_billion": "tỷ",
      "unit_million": "tr",
      "unit_thousand": "k",
    },
    "auth": {
      "login": "Đăng nhập",
      "logout": "Đăng xuất",
      "email": "Email",
      "password": "Mật khẩu",
      "forgot_password": "Quên mật khẩu?",
      "signup": "Đăng ký",
      "no_account": "Chưa có tài khoản?",
      "have_account": "Đã có tài khoản?",
      "login_success": "Đăng nhập thành công",
      "login_failed":
          "Đăng nhập thất bại. Vui lòng kiểm tra thông tin đăng nhập.",
      "login_google": "Đăng nhập với Google",
      "login_apple": "Đăng nhập với Apple",
      "login_phone": "Đăng nhập với số điện thoại",
      "enter_phone_number": "Nhập số điện thoại của bạn",
      "phone_number": "Số điện thoại",
      "phone_number_hint": "Nhập số điện thoại",
      "phone_hint": "+1234567890",
      "verify": "Xác minh",
      "send_code": "Gửi mã",
      "enter_code": "Nhập mã SMS",
      "we_just_sent_sms": "Chúng tôi vừa gửi một tin nhắn SMS",
      "enter_security_code": "Nhập mã bảo mật chúng tôi đã gửi tới",
      "didnt_receive_code": "Không nhận được mã?",
      "resend": "Gửi lại sau",
      "terms_and_privacy":
          "Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của chúng tôi",
      "biometric": {
        "reason": "Yêu cầu xác thực",
        "fallback":
            "Vui lòng bật sinh trắc học cho ứng dụng này trong Cài đặt.",
        "not_available_log": "Xác thực sinh trắc học không khả dụng",
        "init_error": "Lỗi khởi tạo sinh trắc học: {error}",
        "error": {
          "not_available":
              "Xác thực sinh trắc học không khả dụng trên thiết bị này.",
          "not_enrolled": "Chưa đăng ký sinh trắc học trên thiết bị này.",
          "locked_out": "Quá nhiều lần thử thất bại. Vui lòng thử lại sau.",
          "permanently_locked_out":
              "Xác thực sinh trắc học đã bị khóa vĩnh viễn.",
          "passcode_not_set": "Chưa thiết lập mật mã trên thiết bị.",
          "user_canceled": "Người dùng đã hủy xác thực.",
          "app_canceled": "Ứng dụng đã hủy xác thực.",
          "system_canceled": "Hệ thống đã hủy xác thực.",
          "generic": "Lỗi xác thực: {error}",
        },
      },
      "otp": {
        "invalid": "Mã OTP không hợp lệ",
        "expired": "Mã OTP đã hết hạn",
        "too_many_attempts": "Quá nhiều lần thử. Vui lòng thử lại sau",
      },
    },
    "validation": {
      "required": "Trường này là bắt buộc",
      "email": "Vui lòng nhập địa chỉ email hợp lệ",
      "password_length": "Mật khẩu phải có ít nhất {length} ký tự",
      "password_match": "Mật khẩu không khớp",
      "phone": "Số điện thoại không hợp lệ",
    },
    "home": {
      "title": "Trang chủ",
      "welcome": "Xin chào, {name}!",
      "recent_activity": "Hoạt động gần đây",
      "view_all": "Xem tất cả",
      "my_wallets": "Ví tiền",
    },
    "settings": {
      "title": "Cài đặt",
      "language": "Ngôn ngữ",
      "language_vietnamese": "Tiếng Việt",
      "language_english": "Tiếng Anh",
      "theme": "Giao diện",
      "theme_static": "Tĩnh",
      "notifications": "Thông báo",
      "privacy": "Bảo mật",
      "help": "Trợ giúp & Hỗ trợ",
      "about": "Giới thiệu",
    },
    "nav": {
      "home": "Trang chủ",
      "transaction": "Giao dịch",
      "budget_allocation": "Phân bổ",
      "dashboard": "Bảng điều khiển",
      "quick_test": "Kiểm tra nhanh",
      "quick_test_page": "Trang kiểm tra nhanh",
      "notification": "Thông báo",
      "profile": "Hồ sơ",
      "profile_info": "Thông tin cá nhân",
    },
    "dashboard": {
      "item_count": "Số lượng mục",
      "last_updated": "Cập nhật lần cuối",
      "refresh_data": "Làm mới dữ liệu",
      "time": {
        "just_now": "Vừa xong",
        "day": "{count} ngày trước",
        "days": "{count} ngày trước",
        "hour": "{count} giờ trước",
        "hours": "{count} giờ trước",
        "minute": "{count} phút trước",
        "minutes": "{count} phút trước",
      },
    },
    "wallet": {
      "my_account": "Tài khoản của tôi",
      "spending_account": "Tài khoản chi tiêu",
      "total_assets": "Tổng tài sản",
      "your_wallets": "Ví thanh khoản",
      "see_all": "Xem tất cả",
      "empty": "Chưa có ví nào.\nNhấn + để thêm ví.",
      "investment_empty": "Chưa có danh mục đầu tư nào\nNhấn + để thêm ",
      "investment_name": "Tên khoản đầu tư",
      "investment_name_hint": "Ví dụ: BTC, Cổ phiếu Apple...",
      "add_title": "Thêm ví mới",
      "edit_title": "Sửa ví",
      "name": "Tên ví",
      "name_hint": "Ví dụ: Tiền mặt, Techcombank...",
      "initial_balance": "Số dư đầu kỳ",
      "initial_balance_hint": "Ví dụ: 1000000",
      "balance_locked_hint":
          "Không thể sửa số dư đầu kỳ khi ví đã có giao dịch",
      "save_info": "Lưu",
      "bank": "Ngân hàng",
      "ewallet": "Ví điện tử",
      "emergency_fund": "Quỹ dự phòng",
      "emergency_fund_desc":
          "Dự phòng cho tình huống khẩn cấp · nên duy trì 3-6 tháng chi tiêu",
      "emergency_fund_locked_hint":
          "Mở khoá ở LV2, sau khi bạn đã đọc hướng dẫn về Quỹ dự phòng",
      "emergency_fund_view_ebook": "Đọc hướng dẫn",
      "added_success": "Đã thêm ví mới",
      "updated_success": "Đã cập nhật ví",
      "delete_title": "Xóa ví",
      "delete_confirm_msg":
          "Chỉ có thể xóa ví khi số dư bằng 0. Mọi giao dịch của ví sẽ được xóa (soft-delete). Tiếp tục?",
      "investment_delete_title": "Xoá khoản đầu tư",
      "investment_delete_confirm":
          "Chỉ có thể xoá khoản đầu tư khi tổng giá trị hiệu suất bằng 0. Mọi giao dịch liên quan sẽ bị xoá (soft-delete). Tiếp tục?",
      "delete_error_not_empty": "Không thể xóa: số dư của ví phải bằng 0",
      "delete_error_protected": "Ví này là bắt buộc và không thể xóa",
      "liquid_assets": "Tổng tiền thanh khoản",
      "liquid_assets_desc":
          "Tiền mặt + Ngân hàng + Ví điện tử · sẵn sàng chi tiêu ngay",
      "investments": "Đầu tư / Tích lũy",
      "investments_desc":
          "Cổ phiếu, quỹ, bất động sản... · ROI trung bình {roi}%",
      "liabilities": "Nợ phải trả",
      "liabilities_desc":
          "Vay + Thẻ tín dụng · dư nợ còn lại, theo dõi áp lực tài chính",
      "liabilities_net": "Nợ ròng",
    },
    "comment": {
      "detail": {
        "title": "Chi tiết bình luận",
        "content": "Nội dung bình luận",
        "post_id": "ID bài đăng",
        "id": "ID bình luận",
      },
    },
    "transaction": {
      "title": "Giao dịch",
      "wallet": "Tổng ví",
      "emergency": "Khẩn cấp",
      "investment": "Đầu tư",
      "debt": "Vay / Nợ",
      "category": "Danh mục",
      "amount": "Số tiền",
      "source_expense": "Nguồn chi tiêu",
      "reason_expense": "Lý do chi tiêu",
      "enter_content": "Nhập nội dung",
      "payer": "Người trả",
      "staff_name": "Tên nhân viên",
      "time": "Thời gian",
      "history": "Lịch sử",
      "record_expense": "Ghi chép chi tiêu",
      "expense_saved": "Đã lưu chi tiêu {amount} đ thành công!",
      "income_saved": "Đã lưu thu nhập {amount} đ thành công!",
      "expense_updated": "Đã cập nhật chi tiêu {amount} đ!",
      "income_updated": "Đã cập nhật thu nhập {amount} đ!",
      "edit_title": "Sửa giao dịch",
      "source_income": "Nguồn thu nhập",
      "reason_income": "Lý do thu nhập",
      "recipient": "Người nhận",
      "record_income": "Ghi chép thu nhập",
      "source_investment": "Nguồn đầu tư",
      "destination_investment": "Ví nhận tiền",
      "record_investment": "Ghi chép đầu tư",
      "investment_saved": "Đã lưu khoản đầu tư {amount} đ thành công!",
      "source_debt": "Nguồn vay nợ",
      "record_debt": "Ghi chép vay nợ",
      "debt_saved": "Đã lưu khoản vay nợ {amount} đ thành công!",
      "loan_direction_borrow": "Đi vay",
      "loan_direction_lend": "Cho vay",
      "loan_category_borrow_label": "Hình thức vay",
      "loan_amount_borrow_label": "Số tiền vay",
      "loan_wallet_borrow_label": "Ví nhận tiền",
      "loan_category_lend_label": "Hình thức cho vay",
      "loan_amount_lend_label": "Số tiền cho vay",
      "loan_wallet_lend_label": "Nguồn tiền cho vay",
      "loan_borrower_label": "Tên khoản cho vay",
      "loan_borrower_hint": "VD: Cho vay mua nhà, Cho bạn vay...",
      "loan_collection_method_label": "Hình thức thu nợ",
      "loan_method_installment_lend": "Thu góp",
      "loan_method_lump_sum_lend": "Đáo hạn / Thu 1 lần",
      "loan_schedule_lend_label": "Lịch thu góp",
      "loan_reminder_once_label": "Nhắc trước 1 ngày",
      "loan_reminder_recurring_label": "Nhắc trước 1 ngày mỗi kỳ",
      "loan_name_label": "Tên khoản vay",
      "loan_name_hint": "VD: Mua laptop, Vay ngân hàng...",
      "loan_counterparty_vip_locked":
          "Gói miễn phí dùng tên mặc định theo danh mục '{name}'. Nâng cấp VIP để đặt tên riêng.",
      "loan_repayment_method_label": "Hình thức trả nợ",
      "loan_method_installment": "Trả góp",
      "loan_method_lump_sum": "Đáo hạn / Trả 1 lần",
      "loan_final_due_date_label": "Ngày đáo hạn",
      "loan_schedule_label": "Lịch trả góp",
      "loan_add_period": "Thêm kỳ",
      "loan_saved": "Đã ghi nhận khoản vay {amount} đ!",
      "loan_payment_saved": "Đã ghi nhận thanh toán {amount} đ!",
      "record_loan": "Ghi nhận khoản vay",
      "record_repay": "Trả nợ",
      "record_collect": "Thu nợ",
      "investment_contribution": "Chi ra",
      "investment_return": "Thu vào",
      "dest_investment": "Nhận vào ví",
      "record_investment_return": "Ghi chép Thu vào",
      "investment_item": "Khoản đầu tư",
      "add_new_investment_item": "Khoản mới",
      "new_investment_item_hint": "Tên khoản đầu tư (vd: Tiệm lẩu bò)",
      "no_investment_items_hint":
          "Chưa có khoản đầu tư nào trong danh mục này — hãy Chi ra trước.",
      "investment_item_vip_locked":
          "Gói miễn phí dùng tên mặc định theo danh mục '{name}'. Nâng cấp VIP để đặt tên riêng cho khoản đầu tư.",
      "expense_slip": "Chi tiêu",
      "income_slip": "Thu nhập",
      "category_sub": "Danh mục con",
      "today": "Hôm nay",
      "yesterday": "Hôm qua",
      "note": "Ghi chú",
      "note_hint": "Ghi chú (không bắt buộc)",
      "more_details": "Thêm chi tiết",
      "merchant_match_hint": "Giống lần trước: {label}",
      "location_match_hint": "Bạn đang ở gần đây: {label}",
      "quick_entry_label": "Nhập nhanh (AI)",
      "quick_entry_hint": "chi điện thoại năm mươi nghìn đồng tiền mặt",
      "quick_entry_parsed_result": "Đã nhận diện: {label}",
      "quick_entry_could_not_parse":
          "Không hiểu được nội dung này — vui lòng nhập thủ công",
      "quick_entry_cloud_consent_message":
          "Để hiểu nội dung này, ứng dụng cần gửi tới dịch vụ AI (Gemini). Tiếp tục?",
      "quick_entry_cloud_consent_accept": "Đồng ý",
      "quick_entry_cloud_consent_decline": "Để sau",
      "quick_entry_daily_limit_reached":
          "Đã đạt giới hạn AI nhập nhanh hôm nay — vui lòng nhập thủ công",
      "quick_entry_mic_permission_denied":
          "Cần quyền truy cập micro để nhập bằng giọng nói",
      "quick_entry_photo_permission_denied":
          "Cần quyền truy cập máy ảnh/thư viện ảnh để quét hóa đơn",
      "quick_entry_scan_receipt": "Quét hóa đơn",
      "quick_entry_take_photo": "Chụp ảnh",
      "quick_entry_choose_gallery": "Chọn từ thư viện",
      "claims_in_progress": "Bạn có {count} yêu cầu đang xử lý",
      "validation": {
        "amount_required": "Số tiền phải lớn hơn 0!",
        "wallet_required": "Vui lòng chọn ví!",
        "category_required": "Vui lòng chọn hạng mục!",
        "future_date": "Không thể ghi giao dịch ở tương lai!",
        "insufficient_balance": "Số dư ví không đủ!",
        "counterparty_required": "Vui lòng nhập đối tượng vay/cho vay!",
        "schedule_required": "Vui lòng nhập lịch trả nợ!",
        "amount_exceeds_outstanding": "Số tiền vượt quá số dư còn lại!",
        "loan_settled": "Khoản vay này đã tất toán!",
        "not_editable": "Không thể sửa giao dịch này!",
        "edit_window": "Chỉ có thể sửa giao dịch trong 30 ngày gần nhất!",
      },
    },
    "loan": {
      "list_title": "Vay & Cho vay",
      "status_outstanding": "Còn nợ",
      "status_settled": "Đã tất toán",
      "remaining_balance": "Còn lại",
      "principal_amount": "Gốc vay",
      "empty_state": "Chưa có khoản vay nào",
      "history_title": "Lịch sử giao dịch",
      "no_history": "Chưa có giao dịch trả/thu nợ nào",
      "borrow": "Đi vay",
      "lend": "Cho vay",
    },
    "notification": {
      "channel_name": "Nhắc nhở",
      "channel_description":
          "Thông báo nhắc kiểm toán, đăng ký Cloud, hạn trả nợ",
      "audit_approaching_title": "Sắp đến ngày kiểm toán",
      "audit_approaching_body":
          "Ngày mai là ngày kiểm toán hàng tuần của bạn. Đừng quên đối soát số dư nhé!",
      "audit_due_title": "Đã đến ngày kiểm toán",
      "audit_due_body":
          "Hôm nay là ngày kiểm toán hàng tuần của bạn. Hãy đối soát số dư ngay!",
      "cloud_backup_title": "Bảo vệ dữ liệu của bạn",
      "cloud_backup_body":
          "Đăng ký tài khoản để sao lưu dữ liệu lên Cloud, tránh mất dữ liệu khi đổi máy.",
      "loan_due_title": "Sắp đến hạn trả nợ",
      "loan_due_body": "Khoản vay '{name}' sắp đến hạn thanh toán vào {date}.",
      "budget_near_limit_body": "Ngân sách \"{name}\" đã dùng 80%.",
      "budget_over_body": "Ngân sách \"{name}\" đã vượt hạn mức.",
    },
    "tutorial": {
      "nav_title": "Thanh điều hướng",
      "nav_desc":
          "Phân bổ xem ví và ngân sách, Giao dịch để ghi chép, Hồ sơ là trang cá nhân và cài đặt.",
      "transaction_title": "Ghi chép giao dịch",
      "transaction_desc":
          "Chọn Chi tiêu/Thu nhập/Đầu tư/Vay-Nợ ở đây, sau đó nhập số tiền và lưu lại.",
    },
    "budget": {
      "title": "Ngân sách",
      "description":
          "Hạn mức là số tiền tối đa bạn cho phép chi cho 1 danh mục trong tháng — vượt qua đó nghĩa là bạn đang tiêu quá kế hoạch đã đặt ra.",
      "empty": "Chưa có ngân sách nào.\nNhấn + để thêm hạn mức chi tiêu.",
      "edit_limit": "Sửa định mức",
      "edit_title": "Sửa ngân sách",
      "limit_locked": "Định mức chỉ có thể thay đổi trong 7 ngày đầu tháng.",
      "delete_title": "Xóa ngân sách",
      "delete_confirm": "Xóa \"{name}\"?",
      "reset_period": "Đặt lại kỳ mới",
      "reset_title": "Đặt lại ngân sách",
      "add_title": "Thêm ngân sách",
      "name": "Tên ngân sách",
      "name_hint": "Ví dụ: Điện tòa nhà quận A",
      "name_duplicate_error": "Tên ngân sách này đã tồn tại",
      "category": "Hạng mục",
      "limit": "Định mức",
      "limit_hint": "Ví dụ: 1000000",
      "start_date": "Bắt đầu",
      "end_date": "Kết thúc",
      "added": "Đã thêm ngân sách \"{name}\"",
      "updated": "Đã cập nhật ngân sách \"{name}\"",
      "period_started": "Đã mở kỳ mới cho ngân sách \"{name}\"",
      "over_limit": "Bạn đã tiêu quá hạn mức!",
      "near_limit": "Sắp chạm hạn mức!",
      "over_limit_count":
          "Bạn đã vượt hạn mức \"{name}\" {count} lần trong tháng này!",
      "over_by": "Vượt {amount}",
      "remaining": "Còn {amount}",
      "this_month": "Ngân sách tháng này",
      "see_all": "Xem tất cả",
      "drag_reorder_hint": "Giữ và kéo để đổi thứ tự",
      "customize_category": "Tuỳ chỉnh danh mục",
      "percent_used": "{percent}% đã dùng",
      "fixed_price": "Giá cố định",
      "fixed_price_description":
          "Chi phí cố định hàng tháng (mức sống tối thiểu cần có), ảnh hưởng đến chỉ số an toàn với lối sống của bạn ở phần báo cáo",
      "pacing_hint": "{name}: Còn {days} ngày · Nên chi ≤{amount}/ngày",
      "penalty_warning": "{name} đã vượt {percent}%!",
      "deficit_warning": "Thu ít hơn chi tháng này (thâm hụt {amount})",
      "anomaly_hint":
          "{count} khoản chi bất thường so với trung bình 3 tháng qua",
      "insights_title": "Gợi ý & cảnh báo",
      "insights_action_review": "Xem báo cáo",
      "estimate_hint": "Gợi ý: {amount} (TB 3 tháng gần nhất)",
    },
    "reconciliation": {
      "title": "Đối soát",
      "empty": "Chưa có ví nào để đối soát.",
      "instruction": "Nhập số dư thực tế đếm được trong từng ví:",
      "book_total": "Tổng sổ sách",
      "actual_total": "Tổng thực tế",
      "difference": "Chênh lệch",
      "balanced": "Khớp sổ ✓",
      "surplus": "Dư thừa {amount}",
      "deficit": "Hao hụt {amount}",
      "confirm": "Xác nhận đối soát",
      "success": "Đã xác nhận đối soát",
      "success_message":
          "Chúc mừng! Bạn đã hoàn thành lần đối soát thứ {count} thành công.",
      "history": "Lịch sử đối soát",
      "undo": "Hoàn tác",
      "undo_title": "Hoàn tác đối soát",
      "undo_confirm":
          "Hoàn tác đợt đối soát gần nhất và xóa các bút toán điều chỉnh?",
      "week": "Tuần {week}/{year}",
      "book": "Sổ sách",
      "actual": "Thực tế",
      "book_balance": "Sổ sách: {amount}",
      "cycle_subtitle": "Chu kỳ tuần này · đến hạn Chủ nhật",
      "description_line_1":
          "Đối soát giúp bạn khớp số dư thực tế với ứng dụng để đảm bảo mọi ghi chép tài chính luôn chính xác và minh bạch.",
      "description_line_2":
          "Tự động tạo lệnh điều chỉnh để khớp số dư ứng dụng với thực tế mà không cần rà soát lại các giao dịch đã bỏ lỡ.",
      "mismatch_warning": "{count} ví chưa khớp số, xử lý trước khi xác nhận",
      "create_adjustment": "Tạo khoản điều chỉnh",
      "matched": "Khớp sổ",
      "lech": "Lệch {amount}",
      "review_transactions": "Rà soát giao dịch",
    },
    "report": {
      "title": "Báo cáo",
      "spending_proportion": "Tỷ trọng chi tiêu",
      "monthly_chart": "Thu chi",
      "this_week": "Tuần này",
      "four_weeks_near": "4 tuần gần nhất",
      "this_month": "Tháng này",
      "no_expense": "Chưa có khoản chi nào trong kỳ này.",
      "weekly": "Tuần",
      "monthly": "Tháng",
      "yearly": "Năm",
      "three_months": "3 tháng",
      "income_expense": "Thu nhập & Chi tiêu",
      "safety_index": "Chỉ số an toàn (Runway)",
      "runway_desc_2":
          "Runway cho biết bạn có thể sống sót được bao lâu nếu mất thu nhập, đồng thời giúp bạn nhìn ra bức tranh tích lũy thông qua biểu đồ thu chi hàng tháng để điều chỉnh kế hoạch tài chính bền vững hơn.",
      "runway_message": "Bạn có thể duy trì {months} tháng {days} ngày",
      "runway_fixed_price_desc": "Lối sống quản lý tài chính nghiêm túc",
      "runway_no_fixed_price_desc":
          "Runway đang tính theo chi tiêu thực tế. Thiết lập chi phí cố định để ước tính chính xác hơn.",
      "runway_perfect": "Bạn đang chi tiêu rất tuyệt vời!",
      "runway_very_good": "Tuyệt vời! Bạn có đủ tiền dự phòng cho hơn 1 năm",
      "runway_good": "Rất tốt! Bạn có chỉ số an toàn tài chính khá cao",
      "runway_safe": "An toàn! Bạn có đủ tiền dự phòng cho ít nhất 3 tháng",
      "runway_caution": "Hãy cẩn trọng! Bạn nên tích lũy thêm quỹ dự phòng",
      "runway_insufficient":
          "Hãy bắt đầu ghi chép chi tiêu để hệ thống tính toán chỉ số an toàn cho bạn",
      "runway_not_available": "Chưa đủ dữ liệu",
      "investment_title": "Đầu tư",
      "investment_contributed": "Đã đầu tư",
      "investment_returned": "Lợi nhuận thu về",
      "loan_title": "Vay nợ",
      "loan_in": "Vay vào / Thu nợ",
      "loan_out": "Cho vay / Trả nợ",
      "daily_detail": "Chi tiết theo ngày",
      "income_short": "Thu",
      "expense_short": "Chi",
      "uncategorized": "Chưa phân loại",
      "filtering_wallet": "Đang lọc: {wallet}",
      "filter_by_wallet": "Lọc theo ví",
      "filter_all_wallets": "Tất cả các ví",
      "ai_advice_title": "Gợi ý tài chính từ AI",
      "ai_advice_empty_body":
          "Nhận đánh giá chi tiêu tháng này và gợi ý cải thiện tài chính, được cá nhân hóa cho bạn.",
      "ai_advice_generate_cta": "Tạo gợi ý",
      "ai_advice_loading": "Đang tạo gợi ý...",
      "ai_advice_generate_failed":
          "Không thể tạo gợi ý lúc này, vui lòng thử lại.",
      "ai_advice_daily_limit_reached":
          "Bạn đã dùng hết lượt gợi ý AI hôm nay. Vui lòng thử lại vào ngày mai.",
      "ai_advice_generated_just_now": "Vừa tạo xong",
      "ai_advice_generated_minutes_ago": "Tạo {count} phút trước",
      "ai_advice_generated_hours_ago": "Tạo {count} giờ trước",
      "ai_advice_generated_days_ago": "Tạo {count} ngày trước",
    },
    "category": {
      "group_daily": "Hàng ngày",
      "group_personal": "Cá nhân",
      "group_food_drink": "Ăn uống & Cà phê",
      "group_transport": "Di chuyển",
      "group_utilities": "Tiện ích",
      "group_housing": "Nhà ở",
      "group_health": "Y tế & Sức khỏe",
      "group_education": "Giáo dục",
      "group_entertainment": "Giải trí",
      "group_shopping": "Mua sắm",
      "group_insurance": "Bảo hiểm",
      "group_gifts": "Quà tặng & Từ thiện",
      "group_personal_care": "Chăm sóc cá nhân",
      "group_service_fees": "Phí dịch vụ",
      "group_family": "Gia đình & Con cái",
      "food": "Đồ ăn",
      "transport": "Di chuyển",
      "shopping": "Mua sắm",
      "health": "Sức khỏe",
      "food_drink": "Ăn uống",
      "coffee": "Cà phê",
      "water": "Nước",
      "eat_out": "Ăn ngoài",
      "taxi": "Taxi",
      "gas": "Xăng",
      "parking": "Đỗ xe",
      "maintenance": "Bảo trì",
      "electricity": "Điện",
      "internet": "Internet",
      "phone": "Điện thoại",
      "rent": "Thuê nhà",
      "furniture": "Nội thất",
      "laundry": "Giặt ủi",
      "mortgage": "Trả góp nhà",
      "condo_fee": "Phí quản lý chung cư",
      "doctor": "Khám bệnh",
      "medicine": "Thuốc",
      "health_insurance": "Bảo hiểm y tế",
      "gym": "Thể dục gym",
      "tuition": "Học phí",
      "books": "Sách vở",
      "courses": "Khóa học",
      "cinema": "Xem phim",
      "travel": "Du lịch",
      "gaming": "Game",
      "events": "Sự kiện",
      "appliances": "Đồ gia dụng",
      "electronics": "Điện tử",
      "clothing": "Quần áo",
      "cosmetics": "Mỹ phẩm",
      "installment": "Trả góp",
      "life_insurance": "Bảo hiểm nhân thọ",
      "vehicle_insurance": "Bảo hiểm xe",
      "home_insurance": "Bảo hiểm nhà",
      "gifts": "Tặng quà",
      "charity": "Từ thiện",
      "haircut": "Cắt tóc",
      "spa": "Spa",
      "personal_care_product": "Chăm sóc cá nhân",
      "bank_fee": "Phí ngân hàng",
      "card_fee": "Phí thường niên thẻ",
      "milk_formula": "Sữa",
      "diapers": "Bỉm",
      "baby_toys": "Đồ chơi trẻ em",
      "settings_title": "Tuỳ chỉnh danh mục",
      "settings_subtitle": "Lướt để chọn mục phù hợp với bạn",
      "settings_save": "Lưu và tiếp tục",
      "settings_saved": "Tùy chỉnh danh mục thành công",
      "income_settings_title": "Hạng mục thu nhập",
      "income_group_active": "Thu nhập chủ động",
      "income_group_invest": "Thu nhập đầu tư",
      "income_group_other": "Thu nhập khác",
      "income_salary": "Lương chính",
      "income_freelance": "Làm thêm (Freelance)",
      "income_allowance": "Phụ cấp",
      "income_savings_interest": "Tiền lãi tiết kiệm",
      "income_dividends": "Cổ tức",
      "income_rental": "Cho thuê tài sản",
      "income_bonus": "Thưởng",
      "income_gift": "Được tặng/Biếu",
      "income_cashback": "Hoàn tiền (Cashback)",
      "debt_loan_settings_title": "Hạng mục Vay & Nợ",
      "debt_group_borrow": "Đi vay",
      "debt_group_lend": "Cho vay",
      "debt_personal_borrow": "Vay cá nhân",
      "debt_bank_borrow": "Vay ngân hàng/tổ chức tài chính",
      "debt_mortgage": "Vay thế chấp",
      "debt_credit_card": "Nợ thẻ tín dụng",
      "debt_installment": "Vay trả góp",
      "debt_personal_lend": "Cho vay cá nhân",
      "debt_other": "Khác",
      "debt_other_lend": "Khác",
      "investment_settings_title": "Hạng mục Đầu tư",
      "investment_group_default": "Đầu tư",
      "investment_stock": "Cổ phiếu",
      "investment_fund": "Chứng chỉ quỹ",
      "investment_bond": "Trái phiếu",
      "investment_term_deposit": "Tiền gửi tiết kiệm có kỳ hạn",
      "investment_gold": "Vàng",
      "investment_real_estate": "Bất động sản",
      "investment_crypto": "Tiền điện tử",
      "investment_business": "Kinh doanh cá nhân",
      "investment_linked_insurance": "Bảo hiểm nhân thọ có tích luỹ",
      "investment_other": "Khác",
      "expense_settings_title": "Hạng mục chi tiêu",
    },
    "sync": {
      "offline_tooltip":
          "Ngoại tuyến — dữ liệu chỉ lưu trên máy này cho đến khi kết nối lại",
      "pending_tooltip": "{count} mục chưa sao lưu lên Cloud — chạm để đồng bộ",
      "synced_tooltip": "Đã sao lưu toàn bộ dữ liệu lên Cloud",
    },
    "profile": {
      "guest": "Khách",
      "not_logged_in": "Chưa đăng nhập",
      "register_login": "Đăng ký / Đăng nhập",
      "display_name_title": "Sửa tên hiển thị",
      "display_name_hint": "Nhập tên hiển thị của bạn",
      "display_name_save": "Lưu",
      "display_name_updated": "Đã cập nhật tên",
      "link_account_title": "Liên kết tài khoản",
      "link_account_subtitle": "Đăng nhập bằng SĐT hoặc Google đều được",
      "link_account_google": "Google",
      "link_account_phone": "Số điện thoại",
      "link_account_linked": "Đã liên kết",
      "link_account_action": "Liên kết",
      "link_account_success": "Liên kết thành công",
      "link_account_phone_hint": "Nhập số điện thoại",
      "link_account_send_code": "Gửi mã",
      "link_account_verify_code": "Xác nhận",
      "birth_year": "Năm sinh",
      "birth_year_subtitle": "Dùng để gợi ý các hạng mục phù hợp",
      "birth_year_task_desc":
          "Thiết lập: năm sinh, để có danh mục chi tiêu phù hợp",
      "birth_year_hint":
          "Chọn năm sinh đúng thực tế, có ảnh hưởng đến số tiền thu nhập, chi tiêu hằng ngày của bạn",
      "weekly_audit": "Kiểm toán tuần",
      "weekly_audit_day_hint":
          "Chọn ngày kiểm toán hàng tuần của bạn, thường là ngày cuối cùng trong chu kỳ chi tiêu",
      "days_left": "Còn {count} ngày",
      "debt_loan": "Nợ/Vay",
      "unlock_at_lv": "Mở ở LV{level}",
      "unlocked": "Đã mở khoá",
      "vip": "VIP",
      "vip_subtitle":
          "Bỏ giới hạn số lượng mục Đầu tư/khoản Nợ-Vay (bật thủ công, chưa có thanh toán thật)",
      "force_full_access": "Mở khoá toàn bộ tính năng",
      "force_full_access_subtitle":
          "Dành cho test/QA — mở ngay Đầu tư + Nợ/Vay (LV3), bất kể tiến trình thực tế",
      "weekly_audit_day": "Ngày kiểm toán hàng tuần",
      "weekly_audit_day_subtitle": "Ngày bạn đối soát số dư hàng tuần",
      "reminder": "Nhắc nhở",
      "reminder_subtitle": "Nhận thông báo đối soát hàng tuần",
      "theme_subtitle": "Chuyển đổi giữa chế độ sáng và tối",
      "language_subtitle": "Chọn ngôn ngữ bạn muốn sử dụng",
      "currency": "Đơn vị tiền tệ",
      "currency_subtitle": "Thay đổi đơn vị tiền tệ chính",
      "currency_dong": "Đồng",
      "view_tutorial": "Xem hướng dẫn lại",
      "view_tutorial_subtitle": "Học cách sử dụng ứng dụng hiệu quả",
      "terms": "Điều khoản sử dụng",
      "terms_subtitle": "Đọc điều khoản dịch vụ và chính sách bảo mật",
      "about": "Về ứng dụng",
      "about_subtitle": "Thông tin ứng dụng và nhật ký nhà phát triển",
      "delete_account": "Xoá tài khoản",
      "delete_confirm": "Xoá tài khoản?",
      "delete_confirm_desc":
          "Hành động này sẽ xóa vĩnh viễn tài khoản và tất cả dữ liệu liên quan. Không thể hoàn tác.",
      "young_children_message":
          "Bạn có con nhỏ không? Nếu có, chúng tôi sẽ tự động bật các danh mục dành cho con (sữa, bỉm, đồ chơi trẻ em).",
      "experience_level_progress": "Tiến trình cấp độ kinh nghiệm",
      "level_title": "Cấp độ {level} ({title})",
      "tap_to_return": "Chạm để quay lại hồ sơ",
      "streak_weeks": "Chuỗi: {count} tuần",
      "level_master": "Bậc thầy",
      "level_intermediate": "Trung cấp",
      "level_novice": "Người mới",
      "progress_steps": "Tiến độ: {completed}/{total}",
    },
    "guideline": {
      "banner_title_completed": "Chúc mừng! Bước hướng dẫn đã hoàn tất.",
      "banner_title_in_progress": "Thử thách: còn {remaining} bước",
      "banner_desc_completed":
          "Bây giờ bạn có thể bắt đầu quản lý tài chính một cách kỷ luật.",
      "banner_desc_birth_year": "Thiết lập năm sinh để nhận gợi ý phù hợp",
      "banner_desc_categories": "Lựa chọn danh mục chi tiêu & thu nhập",
      "banner_desc_wallet_balance": "Thiết lập số dư hiện tại cho Ví",
      "banner_desc_modify_cash": "Điều chỉnh số tiền thực tế cho ví tiền mặt",
      "banner_desc_budget_limit": "Đặt ngân sách chi tiêu cho từng danh mục",
      "banner_desc_min_living": "Xác định mức sống tối thiểu hàng tháng",
      "banner_desc_first_transaction": "Ghi chép giao dịch chi tiêu đầu tiên",
      "banner_desc_default": "Bạn đã sặn sàng quản lý tài chính!",
      "success_dialog_message":
          "Chúc mừng!\nBạn đã hoàn thành thiết lập ban đầu.",
      "reset_confirm_desc":
          "Bạn có {count} tác vụ đã hoàn thành. Đặt lại sẽ hoàn tác toàn bộ tiến trình.",
      "reset_confirm_agree": "Xem hướng dẫn",
      "reset_confirm_cancel": "Hủy",
    },
  };
  static const Map<String, Map<String, dynamic>> mapLocales = {
    "en": _en,
    "vi": _vi,
  };
}

abstract class CcLocaleKeys {
  static const app_name = 'app.name';
  static const app_version = 'app.version';
  static const app_description = 'app.description';
  static const app_slogan = 'app.slogan';
  static const app_copyright = 'app.copyright';
  static const app_copied_email = 'app.copied_email';
  static const app_author = 'app.author';
  static const app_role_tech = 'app.role_tech';
  static const app_role_hr = 'app.role_hr';
  static const app_author_hr_name = 'app.author_hr_name';
  static const app_author_hr_email = 'app.author_hr_email';
  static const app_author_tech_name = 'app.author_tech_name';
  static const app_author_tech_email = 'app.author_tech_email';
  static const app_address = 'app.address';
  static const app_loading = 'app.loading';
  static const app_error_general = 'app.error.general';
  static const app_error_retry = 'app.error.retry';
  static const app_error_network = 'app.error.network';
  static const app_error_server = 'app.error.server';
  static const app_app_check_initialization_failed =
      'app.app_check.initialization_failed';
  static const app_app_check_token_refresh_failed =
      'app.app_check.token_refresh_failed';
  static const app_app_check_device_not_verified =
      'app.app_check.device_not_verified';

  static const common_ok = 'common.ok';
  static const common_cancel = 'common.cancel';
  static const common_save = 'common.save';
  static const common_delete = 'common.delete';
  static const common_edit = 'common.edit';
  static const common_back = 'common.back';
  static const common_continue = 'common.continue';
  static const common_next = 'common.next';
  static const common_skip = 'common.skip';
  static const common_done = 'common.done';
  static const common_search = 'common.search';
  static const common_no_results = 'common.no_results';
  static const common_no_data = 'common.no_data';
  static const common_or = 'common.or';
  static const common_not_set = 'common.not_set';
  static const common_income = 'common.income';
  static const common_expense = 'common.expense';
  static const common_press_back_again_to_exit =
      'common.press_back_again_to_exit';
  static const common_add_source = 'common.add_source';
  static const common_add = 'common.add';
  static const common_copy = 'common.copy';
  static const common_clear = 'common.clear';
  static const common_unit_billion = 'common.unit_billion';
  static const common_unit_million = 'common.unit_million';
  static const common_unit_thousand = 'common.unit_thousand';
  static const common_weekday_names = 'common.common_weekday_names';

  static const auth_login = 'auth.login';
  static const auth_logout = 'auth.logout';
  static const auth_email = 'auth.email';
  static const auth_password = 'auth.password';
  static const auth_forgot_password = 'auth.forgot_password';
  static const auth_signup = 'auth.signup';
  static const auth_no_account = 'auth.no_account';
  static const auth_have_account = 'auth.have_account';
  static const auth_login_success = 'auth.login_success';
  static const auth_login_failed = 'auth.login_failed';
  static const auth_login_google = 'auth.login_google';
  static const auth_login_apple = 'auth.login_apple';
  static const auth_login_phone = 'auth.login_phone';
  static const auth_enter_phone_number = 'auth.enter_phone_number';
  static const auth_phone_number = 'auth.phone_number';
  static const auth_phone_number_hint = 'auth.phone_number_hint';
  static const auth_phone_hint = 'auth.phone_hint';
  static const auth_verify = 'auth.verify';
  static const auth_send_code = 'auth.send_code';
  static const auth_enter_code = 'auth.enter_code';
  static const auth_we_just_sent_sms = 'auth.we_just_sent_sms';
  static const auth_enter_security_code = 'auth.enter_security_code';
  static const auth_didnt_receive_code = 'auth.didnt_receive_code';
  static const auth_resend = 'auth.resend';
  static const auth_terms_and_privacy = 'auth.terms_and_privacy';
  static const auth_biometric_reason = 'auth.biometric.reason';
  static const auth_biometric_fallback = 'auth.biometric.fallback';
  static const auth_biometric_error_not_available =
      'auth.biometric.error.not_available';
  static const auth_biometric_error_not_enrolled =
      'auth.biometric.error.not_enrolled';
  static const auth_biometric_error_locked_out =
      'auth.biometric.error.locked_out';
  static const auth_biometric_error_permanently_locked_out =
      'auth.biometric.error.permanently_locked_out';
  static const auth_biometric_error_passcode_not_set =
      'auth.biometric.error.passcode_not_set';
  static const auth_biometric_error_user_canceled =
      'auth.biometric.error.user_canceled';
  static const auth_biometric_error_app_canceled =
      'auth.biometric.error.app_canceled';
  static const auth_biometric_error_system_canceled =
      'auth.biometric.error.system_canceled';
  static const auth_biometric_error_generic = 'auth.biometric.error.generic';
  static const auth_otp_invalid = 'auth.otp.invalid';
  static const auth_otp_expired = 'auth.otp.expired';
  static const auth_otp_too_many_attempts = 'auth.otp.too_many_attempts';

  static const validation_required = 'validation.required';
  static const validation_email = 'validation.email';
  static const validation_password_length = 'validation.password_length';
  static const validation_password_match = 'validation.password_match';
  static const validation_phone = 'validation.phone';

  static const home_title = 'home.title';
  static const home_welcome = 'home.welcome';
  static const home_recent_activity = 'home.recent_activity';
  static const home_my_wallets = 'home.my_wallets';

  static const settings_title = 'settings.title';
  static const settings_language = 'settings.language';
  static const settings_language_vietnamese = 'settings.language_vietnamese';
  static const settings_language_english = 'settings.language_english';
  static const settings_theme = 'settings.theme';
  static const settings_notifications = 'settings.notifications';
  static const settings_privacy = 'settings.privacy';
  static const settings_help = 'settings.help';
  static const settings_about = 'settings.about';

  static const nav_home = 'nav.home';
  static const nav_transaction = 'nav.transaction';
  static const nav_budget_allocation = 'nav.budget_allocation';
  static const nav_dashboard = 'nav.dashboard';
  static const nav_quick_test = 'nav.quick_test';
  static const nav_quick_test_page = 'nav.quick_test_page';
  static const nav_notification = 'nav.notification';
  static const nav_profile = 'nav.profile';
  static const nav_profile_info = 'nav.profile_info';

  static const dashboard_item_count = 'dashboard.item_count';
  static const dashboard_last_updated = 'dashboard.last_updated';
  static const dashboard_refresh_data = 'dashboard.refresh_data';
  static const dashboard_time_just_now = 'dashboard.time.just_now';
  static const dashboard_time_day = 'dashboard.time.day';
  static const dashboard_time_days = 'dashboard.time.days';
  static const dashboard_time_hour = 'dashboard.time.hour';
  static const dashboard_time_hours = 'dashboard.time.hours';
  static const dashboard_time_minute = 'dashboard.time.minute';
  static const dashboard_time_minutes = 'dashboard.time.minutes';

  static const wallet_my_account = 'wallet.my_account';
  static const wallet_spending_account = 'wallet.spending_account';
  static const wallet_total_assets = 'wallet.total_assets';
  static const wallet_your_wallets = 'wallet.your_wallets';
  static const wallet_see_all = 'wallet.see_all';
  static const wallet_empty = 'wallet.empty';
  static const wallet_investment_empty = 'wallet.investment_empty';
  static const wallet_investment_name = 'wallet.investment_name';
  static const wallet_investment_name_hint = 'wallet.investment_name_hint';
  static const wallet_investment_delete_title =
      'wallet.investment_delete_title';
  static const wallet_investment_delete_confirm =
      'wallet.investment_delete_confirm';
  static const wallet_investment_edit_title = 'wallet.investment_edit_title';
  static const wallet_add_title = 'wallet.add_title';
  static const wallet_edit_title = 'wallet.edit_title';
  static const wallet_name = 'wallet.name';
  static const wallet_name_hint = 'wallet.name_hint';
  static const wallet_initial_balance = 'wallet.initial_balance';
  static const wallet_balance_locked_hint = 'wallet.balance_locked_hint';
  static const wallet_save_info = 'wallet.save_info';
  static const wallet_bank = 'wallet.bank';
  static const wallet_ewallet = 'wallet.ewallet';
  static const wallet_emergency_fund = 'wallet.emergency_fund';
  static const wallet_emergency_fund_desc = 'wallet.emergency_fund_desc';
  static const wallet_emergency_fund_locked_hint =
      'wallet.emergency_fund_locked_hint';
  static const wallet_emergency_fund_view_ebook =
      'wallet.emergency_fund_view_ebook';
  static const wallet_added_success = 'wallet.added_success';
  static const wallet_updated_success = 'wallet.updated_success';
  static const wallet_delete_title = 'wallet.delete_title';
  static const wallet_delete_confirm_msg = 'wallet.delete_confirm_msg';
  static const wallet_delete_error_not_empty = 'wallet.delete_error_not_empty';
  static const wallet_delete_error_protected = 'wallet.delete_error_protected';
  static const wallet_liquid_assets = 'wallet.liquid_assets';
  static const wallet_liquid_assets_desc = 'wallet.liquid_assets_desc';
  static const wallet_investments = 'wallet.investments';
  static const wallet_investments_desc = 'wallet.investments_desc';
  static const wallet_liabilities = 'wallet.liabilities';
  static const wallet_liabilities_desc = 'wallet.liabilities_desc';
  static const wallet_liabilities_net = 'wallet.liabilities_net';
  static const loan_borrow = 'loan.borrow';
  static const loan_lend = 'loan.lend';

  static const transaction_title = 'transaction.title';
  static const transaction_wallet = 'transaction.wallet';
  static const transaction_emergency = 'transaction.emergency';
  static const transaction_investment = 'transaction.investment';
  static const transaction_debt = 'transaction.debt';
  static const transaction_category = 'transaction.category';
  static const transaction_amount = 'transaction.amount';
  static const transaction_source_expense = 'transaction.source_expense';
  static const transaction_reason_expense = 'transaction.reason_expense';
  static const transaction_enter_content = 'transaction.enter_content';
  static const transaction_payer = 'transaction.payer';
  static const transaction_staff_name = 'transaction.staff_name';
  static const transaction_time = 'transaction.time';
  static const transaction_history = 'transaction.history';
  static const transaction_record_expense = 'transaction.record_expense';
  static const transaction_expense_saved = 'transaction.expense_saved';
  static const transaction_income_saved = 'transaction.income_saved';
  static const transaction_expense_updated = 'transaction.expense_updated';
  static const transaction_income_updated = 'transaction.income_updated';
  static const transaction_edit_title = 'transaction.edit_title';
  static const transaction_source_income = 'transaction.source_income';
  static const transaction_reason_income = 'transaction.reason_income';
  static const transaction_recipient = 'transaction.recipient';
  static const transaction_record_income = 'transaction.record_income';
  static const transaction_source_investment = 'transaction.source_investment';
  static const transaction_destination_investment =
      'transaction.destination_investment';
  static const transaction_record_investment = 'transaction.record_investment';
  static const transaction_investment_saved = 'transaction.investment_saved';
  static const transaction_source_debt = 'transaction.source_debt';
  static const transaction_record_debt = 'transaction.record_debt';
  static const transaction_debt_saved = 'transaction.debt_saved';
  static const transaction_loan_direction_borrow =
      'transaction.loan_direction_borrow';
  static const transaction_loan_direction_lend =
      'transaction.loan_direction_lend';
  static const transaction_loan_category_borrow_label =
      'transaction.loan_category_borrow_label';
  static const transaction_loan_amount_borrow_label =
      'transaction.loan_amount_borrow_label';
  static const transaction_loan_wallet_borrow_label =
      'transaction.loan_wallet_borrow_label';
  static const transaction_loan_category_lend_label =
      'transaction.loan_category_lend_label';
  static const transaction_loan_amount_lend_label =
      'transaction.loan_amount_lend_label';
  static const transaction_loan_wallet_lend_label =
      'transaction.loan_wallet_lend_label';
  static const transaction_loan_borrower_label =
      'transaction.loan_borrower_label';
  static const transaction_loan_borrower_hint =
      'transaction.loan_borrower_hint';
  static const transaction_loan_collection_method_label =
      'transaction.loan_collection_method_label';
  static const transaction_loan_method_installment_lend =
      'transaction.loan_method_installment_lend';
  static const transaction_loan_method_lump_sum_lend =
      'transaction.loan_method_lump_sum_lend';
  static const transaction_loan_schedule_lend_label =
      'transaction.loan_schedule_lend_label';
  static const transaction_loan_reminder_once_label =
      'transaction.loan_reminder_once_label';
  static const transaction_loan_reminder_recurring_label =
      'transaction.loan_reminder_recurring_label';
  static const transaction_loan_name_label = 'transaction.loan_name_label';
  static const transaction_loan_name_hint = 'transaction.loan_name_hint';
  static const transaction_loan_counterparty_vip_locked =
      'transaction.loan_counterparty_vip_locked';
  static const transaction_loan_repayment_method_label =
      'transaction.loan_repayment_method_label';
  static const transaction_loan_method_installment =
      'transaction.loan_method_installment';
  static const transaction_loan_method_lump_sum =
      'transaction.loan_method_lump_sum';
  static const transaction_loan_final_due_date_label =
      'transaction.loan_final_due_date_label';
  static const transaction_loan_schedule_label =
      'transaction.loan_schedule_label';
  static const transaction_loan_add_period = 'transaction.loan_add_period';
  static const transaction_loan_saved = 'transaction.loan_saved';
  static const transaction_loan_payment_saved =
      'transaction.loan_payment_saved';
  static const transaction_record_loan = 'transaction.record_loan';
  static const transaction_record_repay = 'transaction.record_repay';
  static const transaction_record_collect = 'transaction.record_collect';
  static const transaction_investment_contribution =
      'transaction.investment_contribution';
  static const transaction_investment_return = 'transaction.investment_return';
  static const transaction_dest_investment = 'transaction.dest_investment';
  static const transaction_record_investment_return =
      'transaction.record_investment_return';
  static const transaction_investment_item = 'transaction.investment_item';
  static const transaction_add_new_investment_item =
      'transaction.add_new_investment_item';
  static const transaction_new_investment_item_hint =
      'transaction.new_investment_item_hint';
  static const transaction_no_investment_items_hint =
      'transaction.no_investment_items_hint';
  static const transaction_investment_item_vip_locked =
      'transaction.investment_item_vip_locked';
  static const transaction_expense_slip = 'transaction.expense_slip';
  static const transaction_income_slip = 'transaction.income_slip';
  static const transaction_category_sub = 'transaction.category_sub';
  static const transaction_today = 'transaction.today';
  static const transaction_yesterday = 'transaction.yesterday';
  static const transaction_note = 'transaction.note';
  static const transaction_note_hint = 'transaction.note_hint';
  static const transaction_more_details = 'transaction.more_details';
  static const transaction_merchant_match_hint =
      'transaction.merchant_match_hint';
  static const transaction_location_match_hint =
      'transaction.location_match_hint';
  static const quick_entry_label = 'transaction.quick_entry_label';
  static const quick_entry_hint = 'transaction.quick_entry_hint';
  static const quick_entry_parsed_result =
      'transaction.quick_entry_parsed_result';
  static const quick_entry_could_not_parse =
      'transaction.quick_entry_could_not_parse';
  static const quick_entry_cloud_consent_message =
      'transaction.quick_entry_cloud_consent_message';
  static const quick_entry_cloud_consent_accept =
      'transaction.quick_entry_cloud_consent_accept';
  static const quick_entry_cloud_consent_decline =
      'transaction.quick_entry_cloud_consent_decline';
  static const quick_entry_daily_limit_reached =
      'transaction.quick_entry_daily_limit_reached';
  static const quick_entry_mic_permission_denied =
      'transaction.quick_entry_mic_permission_denied';
  static const quick_entry_photo_permission_denied =
      'transaction.quick_entry_photo_permission_denied';
  static const quick_entry_scan_receipt =
      'transaction.quick_entry_scan_receipt';
  static const quick_entry_take_photo = 'transaction.quick_entry_take_photo';
  static const quick_entry_choose_gallery =
      'transaction.quick_entry_choose_gallery';
  static const transaction_claims_in_progress =
      'transaction.claims_in_progress';
  static const transaction_validation_amount_required =
      'transaction.validation.amount_required';
  static const transaction_validation_wallet_required =
      'transaction.validation.wallet_required';
  static const transaction_validation_category_required =
      'transaction.validation.category_required';
  static const transaction_validation_future_date =
      'transaction.validation.future_date';
  static const transaction_validation_insufficient_balance =
      'transaction.validation.insufficient_balance';
  static const transaction_validation_counterparty_required =
      'transaction.validation.counterparty_required';
  static const transaction_validation_schedule_required =
      'transaction.validation.schedule_required';
  static const transaction_validation_amount_exceeds_outstanding =
      'transaction.validation.amount_exceeds_outstanding';
  static const transaction_validation_loan_settled =
      'transaction.validation.loan_settled';
  static const transaction_validation_not_editable =
      'transaction.validation.not_editable';
  static const transaction_validation_edit_window =
      'transaction.validation.edit_window';

  static const loan_list_title = 'loan.list_title';
  static const loan_status_outstanding = 'loan.status_outstanding';
  static const loan_status_settled = 'loan.status_settled';
  static const loan_remaining_balance = 'loan.remaining_balance';
  static const loan_principal_amount = 'loan.principal_amount';
  static const loan_empty_state = 'loan.empty_state';
  static const loan_history_title = 'loan.history_title';
  static const loan_no_history = 'loan.no_history';

  static const notification_channel_name = 'notification.channel_name';
  static const notification_channel_description =
      'notification.channel_description';
  static const notification_audit_approaching_title =
      'notification.audit_approaching_title';
  static const notification_audit_approaching_body =
      'notification.audit_approaching_body';
  static const notification_audit_due_title = 'notification.audit_due_title';
  static const notification_audit_due_body = 'notification.audit_due_body';
  static const notification_cloud_backup_title =
      'notification.cloud_backup_title';
  static const notification_cloud_backup_body =
      'notification.cloud_backup_body';
  static const notification_loan_due_title = 'notification.loan_due_title';
  static const notification_loan_due_body = 'notification.loan_due_body';
  static const notification_budget_near_limit_body =
      'notification.budget_near_limit_body';
  static const notification_budget_over_body = 'notification.budget_over_body';
  static const tutorial_nav_title = 'tutorial.nav_title';
  static const tutorial_nav_desc = 'tutorial.nav_desc';
  static const tutorial_transaction_title = 'tutorial.transaction_title';
  static const tutorial_transaction_desc = 'tutorial.transaction_desc';

  static const budget_title = 'budget.title';
  static const budget_description = 'budget.description';
  static const budget_empty = 'budget.empty';
  static const budget_edit_limit = 'budget.edit_limit';
  static const budget_edit_title = 'budget.edit_title';
  static const budget_limit_locked = 'budget.limit_locked';
  static const budget_delete_title = 'budget.delete_title';
  static const budget_delete_confirm = 'budget.delete_confirm';
  static const budget_reset_period = 'budget.reset_period';
  static const budget_reset_title = 'budget.reset_title';
  static const budget_add_title = 'budget.add_title';
  static const budget_name = 'budget.name';
  static const budget_name_hint = 'budget.name_hint';
  static const budget_name_duplicate_error = 'budget.name_duplicate_error';
  static const budget_category = 'budget.category';
  static const budget_limit = 'budget.limit';
  static const budget_limit_hint = 'budget.limit_hint';
  static const budget_start_date = 'budget.start_date';
  static const budget_end_date = 'budget.end_date';
  static const budget_added = 'budget.added';
  static const budget_updated = 'budget.updated';
  static const budget_period_started = 'budget.period_started';
  static const budget_over_limit = 'budget.over_limit';
  static const budget_near_limit = 'budget.near_limit';
  static const budget_over_limit_count = 'budget.over_limit_count';
  static const budget_over_by = 'budget.over_by';
  static const budget_remaining = 'budget.remaining';
  static const budget_this_month = 'budget.this_month';
  static const budget_see_all = 'budget.see_all';
  static const budget_drag_reorder_hint = 'budget.drag_reorder_hint';
  static const budget_customize_category = 'budget.customize_category';
  static const budget_percent_used = 'budget.percent_used';
  static const budget_fixed_price = 'budget.fixed_price';
  static const budget_fixed_price_description =
      'budget.fixed_price_description';
  static const budget_pacing_hint = 'budget.pacing_hint';
  static const budget_penalty_warning = 'budget.penalty_warning';
  static const budget_deficit_warning = 'budget.deficit_warning';
  static const budget_anomaly_hint = 'budget.anomaly_hint';
  static const budget_insights_title = 'budget.insights_title';
  static const budget_insights_action_review = 'budget.insights_action_review';
  static const budget_estimate_hint = 'budget.estimate_hint';

  static const reconciliation_title = 'reconciliation.title';
  static const reconciliation_empty = 'reconciliation.empty';
  static const reconciliation_instruction = 'reconciliation.instruction';
  static const reconciliation_book_total = 'reconciliation.book_total';
  static const reconciliation_actual_total = 'reconciliation.actual_total';
  static const reconciliation_difference = 'reconciliation.difference';
  static const reconciliation_balanced = 'reconciliation.balanced';
  static const reconciliation_surplus = 'reconciliation.surplus';
  static const reconciliation_deficit = 'reconciliation.deficit';
  static const reconciliation_confirm = 'reconciliation.confirm';
  static const reconciliation_success = 'reconciliation.success';
  static const reconciliation_success_message =
      'reconciliation.success_message';
  static const reconciliation_history = 'reconciliation.history';
  static const reconciliation_undo = 'reconciliation.undo';
  static const reconciliation_undo_title = 'reconciliation.undo_title';
  static const reconciliation_undo_confirm = 'reconciliation.undo_confirm';
  static const reconciliation_week = 'reconciliation.week';
  static const reconciliation_book = 'reconciliation.book';
  static const reconciliation_actual = 'reconciliation.actual';
  static const reconciliation_book_balance = 'reconciliation.book_balance';
  static const reconciliation_cycle_subtitle = 'reconciliation.cycle_subtitle';
  static const reconciliation_description_line_1 =
      'reconciliation.description_line_1';
  static const reconciliation_description_line_2 =
      'reconciliation.description_line_2';
  static const reconciliation_mismatch_warning =
      'reconciliation.mismatch_warning';
  static const reconciliation_create_adjustment =
      'reconciliation.create_adjustment';
  static const reconciliation_matched = 'reconciliation.matched';
  static const reconciliation_lech = 'reconciliation.lech';
  static const reconciliation_review_transactions =
      'reconciliation.review_transactions';

  static const report_title = 'report.title';
  static const report_spending_proportion = 'report.spending_proportion';
  static const report_monthly_chart = 'report.monthly_chart';
  static const report_this_week = 'report.this_week';
  static const report_four_weeks_near = 'report.four_weeks_near';
  static const report_this_month = 'report.this_month';
  static const report_no_expense = 'report.no_expense';
  static const report_weekly = 'report.weekly';
  static const report_yearly = 'report.yearly';
  static const report_three_months = 'report.three_months';
  static const report_income_expense = 'report.income_expense';
  static const report_safety_index = 'report.safety_index';
  static const report_runway_desc_2 = 'report.runway_desc_2';
  static const report_runway_message = 'report.runway_message';
  static const report_runway_fixed_price_desc =
      'report.runway_fixed_price_desc';
  static const report_runway_no_fixed_price_desc =
      'report.runway_no_fixed_price_desc';
  static const report_runway_very_good = 'report.runway_very_good';
  static const report_runway_good = 'report.runway_good';
  static const report_runway_safe = 'report.runway_safe';
  static const report_runway_caution = 'report.runway_caution';
  static const report_runway_insufficient = 'report.runway_insufficient';
  static const report_runway_not_available = 'report.runway_not_available';
  static const report_investment_title = 'report.investment_title';
  static const report_investment_contributed = 'report.investment_contributed';
  static const report_investment_returned = 'report.investment_returned';
  static const report_loan_title = 'report.loan_title';
  static const report_loan_in = 'report.loan_in';
  static const report_loan_out = 'report.loan_out';
  static const report_daily_detail = 'report.daily_detail';
  static const report_income_short = 'report.income_short';
  static const report_expense_short = 'report.expense_short';
  static const report_uncategorized = 'report.uncategorized';
  static const report_filtering_wallet = 'report.filtering_wallet';
  static const report_filter_by_wallet = 'report.filter_by_wallet';
  static const report_filter_all_wallets = 'report.filter_all_wallets';
  static const report_trend_week_label = 'report.trend_week_label';
  static const report_ai_advice_title = 'report.ai_advice_title';
  static const report_ai_advice_empty_body = 'report.ai_advice_empty_body';
  static const report_ai_advice_generate_cta = 'report.ai_advice_generate_cta';
  static const report_ai_advice_loading = 'report.ai_advice_loading';
  static const report_ai_advice_generate_failed =
      'report.ai_advice_generate_failed';
  static const report_ai_advice_daily_limit_reached =
      'report.ai_advice_daily_limit_reached';
  static const report_ai_advice_generated_just_now =
      'report.ai_advice_generated_just_now';
  static const report_ai_advice_generated_minutes_ago =
      'report.ai_advice_generated_minutes_ago';
  static const report_ai_advice_generated_hours_ago =
      'report.ai_advice_generated_hours_ago';
  static const report_ai_advice_generated_days_ago =
      'report.ai_advice_generated_days_ago';

  static const category_settings_title = 'category.settings_title';
  static const category_settings_subtitle = 'category.settings_subtitle';
  static const category_settings_save = 'category.settings_save';
  static const category_settings_saved = 'category.settings_saved';
  static const category_expense_settings_title =
      'category.expense_settings_title';
  static const category_income_settings_title =
      'category.income_settings_title';
  static const category_group_food_drink = 'category.group_food_drink';
  static const category_group_transport = 'category.group_transport';
  static const category_group_utilities = 'category.group_utilities';
  static const category_group_housing = 'category.group_housing';
  static const category_group_health = 'category.group_health';
  static const category_group_education = 'category.group_education';
  static const category_group_entertainment = 'category.group_entertainment';
  static const category_group_shopping = 'category.group_shopping';
  static const category_group_insurance = 'category.group_insurance';
  static const category_group_gifts = 'category.group_gifts';
  static const category_group_personal_care = 'category.group_personal_care';
  static const category_group_service_fees = 'category.group_service_fees';
  static const category_group_family = 'category.group_family';
  static const category_food = 'category.food';
  static const category_transport = 'category.transport';
  static const category_shopping = 'category.shopping';
  static const category_health = 'category.health';
  static const category_food_drink = 'category.food_drink';
  static const category_coffee = 'category.coffee';
  static const category_water = 'category.water';
  static const category_eat_out = 'category.eat_out';
  static const category_taxi = 'category.taxi';
  static const category_gas = 'category.gas';
  static const category_parking = 'category.parking';
  static const category_maintenance = 'category.maintenance';
  static const category_electricity = 'category.electricity';
  static const category_internet = 'category.internet';
  static const category_phone = 'category.phone';
  static const category_rent = 'category.rent';
  static const category_furniture = 'category.furniture';
  static const category_laundry = 'category.laundry';
  static const category_mortgage = 'category.mortgage';
  static const category_condo_fee = 'category.condo_fee';
  static const category_doctor = 'category.doctor';
  static const category_medicine = 'category.medicine';
  static const category_health_insurance = 'category.health_insurance';
  static const category_gym = 'category.gym';
  static const category_tuition = 'category.tuition';
  static const category_books = 'category.books';
  static const category_courses = 'category.courses';
  static const category_cinema = 'category.cinema';
  static const category_travel = 'category.travel';
  static const category_gaming = 'category.gaming';
  static const category_events = 'category.events';
  static const category_appliances = 'category.appliances';
  static const category_electronics = 'category.electronics';
  static const category_clothing = 'category.clothing';
  static const category_cosmetics = 'category.cosmetics';
  static const category_installment = 'category.installment';
  static const category_life_insurance = 'category.life_insurance';
  static const category_vehicle_insurance = 'category.vehicle_insurance';
  static const category_home_insurance = 'category.home_insurance';
  static const category_gifts = 'category.gifts';
  static const category_charity = 'category.charity';
  static const category_haircut = 'category.haircut';
  static const category_spa = 'category.spa';
  static const category_personal_care_product =
      'category.personal_care_product';
  static const category_bank_fee = 'category.bank_fee';
  static const category_card_fee = 'category.card_fee';
  static const category_milk_formula = 'category.milk_formula';
  static const category_diapers = 'category.diapers';
  static const category_baby_toys = 'category.baby_toys';
  static const category_income_group_active = 'category.income_group_active';
  static const category_income_group_invest = 'category.income_group_invest';
  static const category_income_group_other = 'category.income_group_other';
  static const category_income_salary = 'category.income_salary';
  static const category_income_freelance = 'category.income_freelance';
  static const category_income_allowance = 'category.income_allowance';
  static const category_income_savings_interest =
      'category.income_savings_interest';
  static const category_income_dividends = 'category.income_dividends';
  static const category_income_rental = 'category.income_rental';
  static const category_income_bonus = 'category.income_bonus';
  static const category_income_gift = 'category.income_gift';
  static const category_income_cashback = 'category.income_cashback';
  static const category_debt_loan_settings_title =
      'category.debt_loan_settings_title';
  static const category_debt_group_borrow = 'category.debt_group_borrow';
  static const category_debt_group_lend = 'category.debt_group_lend';
  static const category_debt_personal_borrow = 'category.debt_personal_borrow';
  static const category_debt_bank_borrow = 'category.debt_bank_borrow';
  static const category_debt_mortgage = 'category.debt_mortgage';
  static const category_debt_credit_card = 'category.debt_credit_card';
  static const category_debt_installment = 'category.debt_installment';
  static const category_debt_personal_lend = 'category.debt_personal_lend';
  static const category_debt_other = 'category.debt_other';
  static const category_debt_other_lend = 'category.debt_other_lend';
  static const category_investment_settings_title =
      'category.investment_settings_title';
  static const category_investment_group_default =
      'category.investment_group_default';
  static const category_investment_stock = 'category.investment_stock';
  static const category_investment_fund = 'category.investment_fund';
  static const category_investment_bond = 'category.investment_bond';
  static const category_investment_term_deposit =
      'category.investment_term_deposit';
  static const category_investment_gold = 'category.investment_gold';
  static const category_investment_real_estate =
      'category.investment_real_estate';
  static const category_investment_crypto = 'category.investment_crypto';
  static const category_investment_business = 'category.investment_business';
  static const category_investment_linked_insurance =
      'category.investment_linked_insurance';
  static const category_investment_other = 'category.investment_other';

  static const comment_detail_title = 'comment.detail.title';
  static const comment_detail_content = 'comment.detail.content';
  static const comment_detail_post_id = 'comment.detail.post_id';
  static const comment_detail_id = 'comment.detail.id';

  static const sync_offline_tooltip = 'sync.offline_tooltip';
  static const sync_pending_tooltip = 'sync.pending_tooltip';
  static const sync_synced_tooltip = 'sync.synced_tooltip';

  static const profile_guest = 'profile.guest';
  static const profile_not_logged_in = 'profile.not_logged_in';
  static const profile_register_login = 'profile.register_login';
  static const profile_display_name_title = 'profile.display_name_title';
  static const profile_display_name_hint = 'profile.display_name_hint';
  static const profile_display_name_save = 'profile.display_name_save';
  static const profile_display_name_updated = 'profile.display_name_updated';
  static const profile_link_account_title = 'profile.link_account_title';
  static const profile_link_account_subtitle = 'profile.link_account_subtitle';
  static const profile_link_account_google = 'profile.link_account_google';
  static const profile_link_account_phone = 'profile.link_account_phone';
  static const profile_link_account_linked = 'profile.link_account_linked';
  static const profile_link_account_action = 'profile.link_account_action';
  static const profile_link_account_success = 'profile.link_account_success';
  static const profile_link_account_phone_hint =
      'profile.link_account_phone_hint';
  static const profile_link_account_send_code =
      'profile.link_account_send_code';
  static const profile_link_account_verify_code =
      'profile.link_account_verify_code';
  static const profile_birth_year = 'profile.birth_year';
  static const profile_birth_year_subtitle = 'profile.birth_year_subtitle';
  static const profile_birth_year_hint = 'profile.birth_year_hint';
  static const profile_birth_year_task_desc = 'profile.birth_year_task_desc';
  static const profile_weekly_audit = 'profile.weekly_audit';
  static const profile_weekly_audit_day_hint = 'profile.weekly_audit_day_hint';
  static const profile_days_left = 'profile.days_left';
  static const profile_debt_loan = 'profile.debt_loan';
  static const profile_unlock_at_lv = 'profile.unlock_at_lv';
  static const profile_unlocked = 'profile.unlocked';
  static const profile_vip = 'profile.vip';
  static const profile_vip_subtitle = 'profile.vip_subtitle';
  static const profile_force_full_access = 'profile.force_full_access';
  static const profile_force_full_access_subtitle =
      'profile.force_full_access_subtitle';
  static const profile_weekly_audit_day = 'profile.weekly_audit_day';
  static const profile_weekly_audit_day_subtitle =
      'profile.weekly_audit_day_subtitle';
  static const profile_reminder = 'profile.reminder';
  static const profile_reminder_subtitle = 'profile.reminder_subtitle';
  static const profile_theme_subtitle = 'profile.theme_subtitle';
  static const profile_language_subtitle = 'profile.language_subtitle';
  static const profile_currency = 'profile.currency';
  static const profile_currency_subtitle = 'profile.currency_subtitle';
  static const profile_currency_dong = 'profile.currency_dong';
  static const profile_view_tutorial = 'profile.view_tutorial';
  static const profile_view_tutorial_subtitle =
      'profile.view_tutorial_subtitle';
  static const profile_terms = 'profile.terms';
  static const profile_terms_subtitle = 'profile.terms_subtitle';
  static const profile_about = 'profile.about';
  static const profile_about_subtitle = 'profile.about_subtitle';
  static const profile_delete_account = 'profile.delete_account';
  static const profile_delete_confirm = 'profile.delete_confirm';
  static const profile_delete_confirm_desc = 'profile.delete_confirm_desc';
  static const profile_young_children_message =
      'profile.young_children_message';
  static const profile_experience_level_progress =
      'profile.experience_level_progress';
  static const profile_level_title = 'profile.level_title';
  static const profile_tap_to_return = 'profile.tap_to_return';
  static const profile_streak_weeks = 'profile.streak_weeks';
  static const profile_level_master = 'profile.level_master';
  static const profile_level_intermediate = 'profile.level_intermediate';
  static const profile_level_novice = 'profile.level_novice';
  static const profile_progress_steps = 'profile.progress_steps';

  static const guideline_banner_title_completed =
      'guideline.banner_title_completed';
  static const guideline_banner_title_in_progress =
      'guideline.banner_title_in_progress';
  static const guideline_banner_desc_completed =
      'guideline.banner_desc_completed';
  static const guideline_banner_desc_birth_year =
      'guideline.banner_desc_birth_year';
  static const guideline_banner_desc_categories =
      'guideline.banner_desc_categories';
  static const guideline_banner_desc_wallet_balance =
      'guideline.banner_desc_wallet_balance';
  static const guideline_banner_desc_modify_cash =
      'guideline.banner_desc_modify_cash';
  static const guideline_banner_desc_budget_limit =
      'guideline.banner_desc_budget_limit';
  static const guideline_banner_desc_min_living =
      'guideline.banner_desc_min_living';
  static const guideline_banner_desc_first_transaction =
      'guideline.banner_desc_first_transaction';
  static const guideline_banner_desc_default = 'guideline.banner_desc_default';
  static const guideline_success_dialog_message =
      'guideline.success_dialog_message';
  static const guideline_reset_confirm_desc = 'guideline.reset_confirm_desc';
  static const guideline_reset_confirm_agree = 'guideline.reset_confirm_agree';
  static const guideline_reset_confirm_cancel =
      'guideline.reset_confirm_cancel';
}
