// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names, avoid_escaping_inner_quotes

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
      "name": "So Sach Xin",
      "version": "Version {version}",
      "description": "Lean and efficient personal finance management",
      "slogan":
          "Manage income, expenses, investment, debt according to single-entry accounting principle, towards financial freedom",
      "copyright": "© 2026 So Sach Xin · Made by",
      "copied_email": "Copied email: {email}",
      "author": "by Tran Huy",
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
      "max_length_reached": "Maximum {count} characters reached",
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
      "language_korean": "Korean",
      "language_japanese": "Japanese",
      "language_chinese": "Chinese",
      "theme": "Theme",
      "theme_static": "Static",
      "theme_light": "Light Mode",
      "theme_dark": "Dark Mode",
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
      "nav_reconcile": "Reconcile",
      "reconciliation.title": "Reconcile",
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
      "investment_delete_title": "Delete Investment",
      "investment_delete_confirm":
          "Deleting an investment item is only possible when its total performance value is 0. All related transactions will be soft-deleted. Continue?",
      "investment_edit_title": "Edit Investment",
      "add_title": "Add New Wallet",
      "edit_title": "Edit Wallet",
      "name": "Wallet Name",
      "name_hint": "e.g. Techcombank, tcb777, vcb789",
      "name_duplicate_error": "This wallet name already exists",
      "initial_balance": "Opening Balance",
      "initial_balance_hint": "e.g. 1000000",
      "balance_locked_hint":
          "Cannot change opening balance once the wallet has transactions\nConsider creating a new wallet to track the adjustment",
      "balance_hidden": "*****",
      "save_info": "Save",
      "bank": "Bank",
      "cash": "Cash",
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
          "A wallet can only be deleted when it has no transactions. All transactions of the wallet will be soft-deleted. Continue?",
      "delete_error_not_empty": "Cannot delete: wallet has transactions",
      "delete_error_protected": "This wallet is required and cannot be deleted",
      "liquid_assets": "Liquid Assets",
      "liquid_assets_desc": "Cash + Bank + E-wallet · ready to spend",
      "investments": "Investments / Accumulation",
      "investments_desc": "Stocks, funds, real estate...",
      "liabilities": "Liabilities",
      "liabilities_desc":
          "Loans + Credit cards · balance tracking, stress monitor",
      "investment_roi": "ROI",
      "investment_breakeven": "Breakeven Rate",
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
      "expense_saved": "Expense of {amount} saved successfully!",
      "income_saved": "Income of {amount} saved successfully!",
      "expense_updated": "Expense of {amount} updated!",
      "income_updated": "Income of {amount} updated!",
      "edit_title": "Edit transaction",
      "delete_title": "Delete transaction",
      "delete_confirm_desc": "This action cannot be undone.",
      "liability_payment_saved": "Payment of {amount} recorded!",
      "source_income": "Source of Income",
      "reason_income": "Reason for Income",
      "recipient": "Recipient",
      "record_income": "Record Income",
      "source_investment": "Source of Investment",
      "destination_investment": "Receiving wallet",
      "record_investment": "Record Investment",
      "investment_saved": "Investment of {amount} saved successfully!",
      "source_debt": "Source of Debt",
      "record_debt": "Record Debt",
      "debt_saved": "Debt of {amount} saved successfully!",
      "liability_direction_borrow": "Borrowed from",
      "liability_direction_lend": "Lend",
      "liability_name_label": "Liability name",
      "liability_name_hint": "e.g. Laptop purchase, Bank loan...",
      "record_liability": "Record Liability",
      "liability_amount_borrow_label": "Liability amount",
      "liability_amount_lend_label": "Lending amount",
      "liability_wallet_borrow_label": "Receiving wallet",
      "liability_wallet_lend_label": "Lending wallet",
      "liability_saved": "Liability of {amount} recorded!",
      "liability_name_duplicate_error": "This liability name already exists",
      "liability_category_borrow_label": "Loan type",
      "liability_category_lend_label": "Lending type",
      "liability_borrower_label": "Loan name",
      "liability_borrower_hint":
          "e.g. House purchase loan, Loan to a friend...",
      "liability_collection_method_label": "Collection method",
      "liability_method_installment_lend": "Installments",
      "liability_method_lump_sum_lend": "Collect once",
      "liability_schedule_lend_label": "Collection schedule",
      "liability_reminder_once_label": "Remind 1 day before",
      "liability_reminder_recurring_label": "Remind 1 day before each due date",
      "liability_counterparty_vip_locked":
          "Free plan uses the category's default name '{name}'. Upgrade to VIP to set a custom name.",
      "liability_repayment_method_label": "Repayment method",
      "liability_method_installment": "Installment",
      "liability_method_lump_sum": "Lump sum at maturity",
      "liability_final_due_date_label": "Due date",
      "liability_schedule_label": "Installment schedule",
      "liability_add_period": "Add period",
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
      "bill_match_hint": "Monthly bill: {label}",
      "monthly_income_match_hint": "Monthly income: {label}",
      "auto_save_countdown": "Auto-save in {countdown}s...",
      "quick_entry_hint": "spend phone 50,000 by cash",
      "quick_entry_parsed_result": "Got it: {label}",
      "quick_entry_category_missing": "Category not found (need +): {label}",
      "quick_entry_could_not_parse":
          "Couldn't understand that — please fill in manually",
      "quick_entry_daily_limit_reached":
          "Daily AI quick-entry limit reached — please fill in manually",
      "quick_entry_mic_permission_denied":
          "Microphone access is needed for voice entry",
      "quick_entry_photo_permission_denied":
          "Camera/photo access is needed to scan a receipt",
      "quick_entry_batch_label": "{count} transactions · {total}",
      "quick_entry_batch_failed":
          "Couldn't read receipt(s) {indexes} — nothing was saved",
      "quick_entry_batch_saved": "Saved {count} transactions · {total}",
      "quick_entry_batch_save_failed":
          "Couldn't save receipt {index}: {reason} — nothing was saved",
      "quick_entry_batch_partial":
          "Saved {saved} of {total} — receipt {index} failed: {reason}",
      "quick_entry_scan_receipt": "Scan a receipt",
      "quick_entry_take_photo": "Take photo",
      "quick_entry_choose_gallery": "Choose from gallery",
      "quick_entry_camera_not_available": "Camera feature is not available yet",
      "smart_entry_preview_title_one": "Review transaction",
      "smart_entry_preview_title_many": "Review {count} transactions",
      "smart_entry_preview_subtitle": "Check and edit before saving",
      "smart_entry_preview_confirm_one": "Confirm",
      "smart_entry_preview_confirm_many": "Confirm all ({count})",
      "smart_entry_preview_apply_form": "Apply to form",
      "smart_entry_preview_pick_category": "Choose category",
      "smart_entry_preview_pick_wallet": "Choose wallet",
      "smart_entry_preview_save_failed":
          "Couldn't save transaction {index}: {reason} — nothing was saved",
      "smart_entry_preview_save_partial":
          "Saved {saved} of {total} — transaction {index} failed: {reason}",
      "smart_entry_preview_saved_one": "Transaction saved",
      "smart_entry_preview_saved_many": "Saved {count} transactions",
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
        "liability_settled": "This liability is already settled",
        "not_editable": "This transaction can't be edited",
        "edit_window": "You can only edit transactions from the last 30 days",
      },
      "transfer_money": "Transfer money",
      "transfer_from": "From wallet",
      "transfer_to": "To wallet",
      "transfer_swap": "Swap wallets",
      "transfer_saved": "Transfer saved successfully",
    },
    "liability": {
      "title": "Liabilities",
      "list_title": "Liabilities",
      "status_outstanding": "Outstanding",
      "status_settled": "Settled",
      "remaining_balance": "Remaining",
      "principal_amount": "Principal",
      "empty_state": "No liabilities yet",
      "empty_state_v2": "No liability/lend yet\nPress + to add.",
      "history_title": "Transaction history",
      "no_history": "No repayment/collection yet",
      "delete_title": "Delete Liability",
      "delete_confirm_msg":
          "Are you sure you want to delete this liability? This action cannot be undone.",
      "borrow": "Borrowed from",
      "lend": "Lend",
      "borrow_type_personal": "Personal",
      "lend_type_personal": "Personal",
      "repaid_prefix": "Repaid: ",
      "borrow_prefix": "Borrowed: ",
      "received": "Received",
      "to_collect": "To collect",
      "total_lend": "Total lent",
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
      "month_indicator": "{month}",
      "see_all": "See all",
      "drag_reorder_hint": "Hold and drag to reorder",
      "customize_category": "Customize category",
      "percent_used": "{percent}% used",
      "spent_prefix": "Spent",
      "limit_prefix": "Limit",
      "fixed_price": "Fixed Price",
      "fixed_price_description":
          "Fixed monthly costs (minimum survival cost), affecting your safety index in the report section.",
      "pacing_hint": "{name}: {days} days left · Suggested ≤{amount}/day",
      "penalty_warning": "{name} exceeded {percent}%!",
      "deficit_warning":
          "Spending more than income this month (deficit {amount})",
      "debt_inflow_warning":
          "{percent}% of this month's inflow ({amount}) comes from debt, not income",
      "debt_outflow_warning":
          "{percent}% of this month's outflow ({amount}) is debt lent or repaid, not spending",
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
      "no_expense":
          "No expenses in this period. \nRecord any Expense/Income, then update if need",
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
          "Start recording expenses so the system can calculate your safety index.",
      "runway_not_available": "Insufficient data",
      "investment_title": "Investments",
      "investment_contributed": "Contributed",
      "investment_returned": "Returns",
      "liability_title": "Liabilities",
      "liability_in": "Borrowed from",
      "liability_out": "Lend",
      "daily_detail": "Daily Detail",
      "income_short": "Inc",
      "expense_short": "Exp",
      "uncategorized": "Uncategorized",
      "filtering_wallet": "Filtering: {wallet}",
      "filter_by_wallet": "Filter by wallet",
      "filter_all_wallets": "All wallets",
      "filter_by_type": "Filter by type",
      "filter_all_types": "All types",
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
      "ai_advice_gemini_disabled":
          "Gemini AI is turned off in Profile settings.",
      "ai_advice_generated_just_now": "Generated just now",
      "ai_advice_generated_minutes_ago": "Generated {count} minutes ago",
      "ai_advice_generated_hours_ago": "Generated {count} hours ago",
      "ai_advice_generated_days_ago": "Generated {count} days ago",
    },
    "category": {
      "settings_title": "Category Settings",
      "settings_subtitle": "Manage custom categories and groups",
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
      "food_drink": "Dining & Coffee",
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
      "debt_personal_borrow": "Personal Loan (Friend)",
      "debt_bank_borrow": "Bank/Financial Loan",
      "debt_mortgage": "Mortgage",
      "debt_credit_card": "Credit Card Debt",
      "debt_installment": "Installment",
      "debt_personal_lend": "Personal Lending",
      "debt_other": "Other",
      "debt_other_lend": "Other",
      "investment_bond": "Bond",
      "investment_business": "Business",
      "investment_crypto": "Crypto",
      "investment_fund": "Fund",
      "investment_gold": "Gold",
      "investment_group_default": "Investments",
      "investment_linked_insurance": "Investment-linked Insurance",
      "investment_other": "Other",
      "investment_real_estate": "Real Estate",
      "investment_settings_title": "Investment Categories",
      "investment_stock": "Stock",
      "investment_term_deposit": "Term Deposit",
      "market_supermarket": "Market & Supermarket",
      "religious": "Religious/Spirituality",
      "leisure": "Leisure & Travel",
      "expense_settings_title": "Expense Categories",
    },
    "sync": {
      "offline_tooltip":
          "Offline — your data is only saved on this device until you reconnect",
      "syncing_tooltip": "Syncing — backing up your data to Cloud…",
      "pending_tooltip":
          "{count} item(s) not yet backed up to Cloud — tap to sync",
      "synced_tooltip": "All data backed up to Cloud",
      "logout_blocked_offline": "Connect to the internet before logging out",
      "logout_blocked_pending":
          "You have data that hasn't synced yet. Reconnect and sync before logging out.",
      "discard_title": "Discard unsynced data?",
      "discard_message":
          "Some of your data could not be backed up and will be permanently deleted from this device. This cannot be undone.",
      "discard_confirm": "Discard",
      "discard_done": "Discarded unsynced data",
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
      "birth_year_hint":
          "Choose your actual birth year, it affects your daily income and expense calculations",
      "birth_year_task_desc": "Task: set up your birth year",
      "weekly_audit": "Weekly audit",
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
      "gemini_ai": "Gemini AI features",
      "gemini_ai_subtitle":
          "Debug/QA — on: text, voice and receipt entries are parsed by Gemini first (local as fallback). Off: nothing is sent to Gemini, only local parsing runs",
      "weekly_audit_day": "Weekly audit day",
      "weekly_audit_day_subtitle": "The day you review your weekly balance",
      "weekly_audit_day_hint":
          "Select your weekly audit day, usually at the end of your spending cycle",
      "audit_shortcut": "Audit",
      "reminder": "Reminders",
      "reminder_subtitle": "Get notified to record your reconcile",
      "theme_subtitle": "Switch between light and dark mode",
      "language_subtitle": "Select your preferred language",
      "currency": "Currency unit",
      "currency_subtitle": "Change your primary currency unit",
      "currency_dong": "Dong",
      "currency_vnd": "Vietnamese Dong",
      "currency_usd": "United States Dollar",
      "currency_eur": "Euro",
      "currency_jpy": "Japanese Yen",
      "currency_krw": "South Korean Won",
      "currency_cny": "Chinese Yuan",
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
      "progress_steps": "Progress steps",
      "reconciliation_streak_title": "{count} week streak",
      "reconciliation_streak_desc": "Audit day: {day}",
      "rate_app": "Rate app",
      "rate_app_subtitle": "Help us improve So Sach Xin",
      "customer_reviews": "Customer reviews",
      "customer_ratings_count": "{count} customer ratings",
      "calculate_ratings_info": "How do we calculate ratings?",
      "out_of_5": "{rating} out of 5",
      "star_count": "{count} star",
      "feedback_hint": "Tell us more (optional)",
      "feedback_send": "Send feedback",
      "feedback_required": "Choose a tag or write a message",
      "feedback_sent": "Thanks for your feedback",
      "feedback_praise_fast": "Lightning-fast entry",
      "feedback_praise_offline": "Works great offline",
      "feedback_praise_runway": "Real Runway calculation",
      "feedback_praise_reconciliation": "Accurate reconciliation",
      "feedback_praise_lending": "Clear lending/borrowing",
      "feedback_praise_suggestions": "Precise money suggestions",
      "feedback_praise_interface": "Minimalist interface",
      "feedback_praise_scanning": "Sensitive bill scanning ✨",
      "feedback_praise_alerts": "Accurate alerts",
      "feedback_praise_leveling": "Fun leveling up",
      "feedback_criticism_sync": "Sync error",
      "feedback_criticism_balance": "Balance mismatch",
      "feedback_criticism_unlock": "Unlock takes too long",
      "feedback_criticism_scanning": "Scanned bill is incorrect",
      "feedback_criticism_amount": "Hard to enter amount",
      "feedback_criticism_categories": "Missing categories",
      "feedback_criticism_limits": "Hard to edit limit",
      "feedback_criticism_notifications": "No notifications",
      "feedback_criticism_charts": "Charts are hard to view",
      "feedback_criticism_speed": "App is slow",
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
      "banner_desc_investment":
          "Create your first investment to grow your wealth",
      "banner_desc_liability":
          "Record your first liability to manage your debts",
      "banner_desc_lend": "Record your first lend to manage your loans",
      "banner_desc_default": "You are ready to manage your finances!",
      "success_dialog_message":
          "Congratulations!\nYou have completed the initial setup.",
      "reset_confirm_desc":
          "You have {count} completed tasks. Resetting will undo all progress.",
      "reset_confirm_agree": "View Tutorial",
      "reset_confirm_cancel": "Cancel",
    },
    "level_lock": {
      "unlock_at_lv": "UNLOCK AT LV{level}",
      "unlock_free_at_lv3": "Free to unlock at LV3",
      "remaining_percent": "{percent}% REMAINING",
      "investment_title": "Track Investment & Accumulation",
      "investment_desc":
          "Record stocks, funds, real estate and track ROI directly in the app — unlock by completing spending discipline challenges.",
      "liability_title": "Debt & Loan Management",
      "liability_desc":
          "Track debts, interest rates, and professional repayment schedules — unlock when higher financial discipline is achieved.",
      "task_setup_budget": "Setup first budget",
      "task_record_transactions": "Record first 5 transactions",
      "task_setup_birth_year": "Setup birth year",
      "task_reconciliation_streak": "Audit discipline {current}/{total} weeks",
      "task_fixed_budgets": "Setup {current}/{total} fixed budgets",
      "task_positive_cash_flow": "Positive cash flow this month",
      "progress_archived": "{percent}% exp archived",
    },
  };

  static const Map<String, dynamic> _vi = {
    "app": {
      "name": "Sổ Sách Xịn",
      "version": "Phiên bản {version}",
      "description": "Quản lý tài chính cá nhân tinh gọn và hiệu quả",
      "slogan":
          "Quản lý thu chi, đầu tư, vay nợ theo nguyên lý kế toán đơn, hướng dẫn tự do tài chính",
      "copyright": "© 2026 Sổ Sách Xịn • Made by",
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
      "not_set": "Chưa đặt",
      "sunday_short": "CN",
      "select_date": "Chọn ngày",
      "income": "Thu nhập",
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
      "we_just_sent_sms": "Chúng tôi vừa gửi một bản tin nhắn SMS",
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
      "max_length_reached": "Đã đạt tối đa {count} ký tự",
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
      "language_english": "Anh",
      "language_korean": "Hàn",
      "language_japanese": "Nhật",
      "language_chinese": "Trung",
      "theme": "Giao diện",
      "theme_static": "Tĩnh",
      "theme_light": "Chế độ sáng",
      "theme_dark": "Chế độ tối",
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
      "nav_reconcile": "Kiểm toán",
      "reconciliation.title": "Kiểm toán",
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
      "investment_delete_title": "Xoá khoản đầu tư",
      "investment_delete_confirm":
          "Chỉ có thể xoá khoản đầu tư khi tổng giá trị hiệu suất bằng 0. Mọi giao dịch liên quan sẽ bị xoá (soft-delete). Tiếp tục?",
      "investment_edit_title": "Sửa khoản đầu tư",
      "add_title": "Thêm ví mới",
      "edit_title": "Sửa ví",
      "name": "Tên ví",
      "name_hint": "Ví dụ: Techcombank, tcb777, vcb789",
      "name_duplicate_error": "Tên ví này đã tồn tại",
      "initial_balance": "Số dư đầu kỳ",
      "initial_balance_hint": "Ví dụ: 1000000",
      "balance_locked_hint":
          "Không thể sửa số dư đầu kỳ khi ví đã có giao dịch\nKhuyến khích tạo thêm ví mới để quản lý khoản điều chỉnh phát sinh",
      "balance_hidden": "*****",
      "save_info": "Lưu",
      "bank": "Ngân hàng",
      "cash": "Tiền mặt",
      "ewallet": "Ví điện tử",
      "emergency_fund": "Quỹ dự phòng",
      "emergency_fund_desc":
          "Dự phòng cho tình huống khẩn cấp • nên duy trì 3-6 tháng chi tiêu",
      "emergency_fund_locked_hint":
          "Mở khoá ở LV2, sau khi bạn đã đọc hướng dẫn về Quỹ dự phòng",
      "emergency_fund_view_ebook": "Đọc hướng dẫn",
      "added_success": "Đã thêm ví mới",
      "updated_success": "Đã cập nhật ví",
      "delete_title": "Xóa ví",
      "delete_confirm_msg":
          "Chỉ có thể xóa ví khi không có giao dịch nào. Mọi giao dịch của ví sẽ được xóa (soft-delete). Tiếp tục?",
      "delete_error_not_empty": "Không thể xóa: ví có giao dịch",
      "delete_error_protected": "Ví này là bắt buộc và không thể xóa",
      "liquid_assets": "Tổng tiền thanh khoản",
      "liquid_assets_desc":
          "Tiền mặt + Ngân hàng + Ví điện tử • sẵn sàng chi tiêu ngay",
      "investments": "Đầu tư / Tích lũy",
      "investments_desc": "Cổ phiếu, quỹ, bất động sản...",
      "liabilities": "Nợ phải trả",
      "liabilities_desc":
          "Vay + Thẻ tín dụng • dư nợ còn lại, theo dõi áp lực tài chính",
      "investment_roi": "ROI",
      "investment_breakeven": "Tỷ lệ hòa vốn",
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
      "expense_saved": "Đã lưu chi tiêu {amount} thành công!",
      "income_saved": "Đã lưu thu nhập {amount} thành công!",
      "expense_updated": "Đã cập nhật chi tiêu {amount}!",
      "income_updated": "Đã cập nhật thu nhập {amount}!",
      "edit_title": "Sửa giao dịch",
      "delete_title": "Xóa giao dịch",
      "delete_confirm_desc": "Hành động này không thể hoàn tác.",
      "source_income": "Nguồn thu nhập",
      "reason_income": "Lý do thu nhập",
      "recipient": "Người nhận",
      "record_income": "Ghi chép thu nhập",
      "source_investment": "Nguồn đầu tư",
      "destination_investment": "Ví nhận tiền",
      "record_investment": "Ghi chép đầu tư",
      "investment_saved": "Đã lưu khoản đầu tư {amount} thành công!",
      "source_debt": "Nguồn vay nợ",
      "record_debt": "Ghi chép vay nợ",
      "debt_saved": "Đã lưu khoản vay nợ {amount} thành công!",
      "record_liability": "Ghi nhận khoản nợ/vay",
      "liability_direction_borrow": "Đi vay",
      "liability_direction_lend": "Cho mượn",
      "liability_name_label": "Tên khoản nợ/vay",
      "liability_name_hint": "VD: Mua laptop, Vay ngân hàng...",
      "liability_amount_borrow_label": "Số tiền vay",
      "liability_amount_lend_label": "Số tiền cho mượn",
      "liability_wallet_borrow_label": "Ví nhận tiền",
      "liability_wallet_lend_label": "Ví nguồn tiền",
      "liability_saved": "Đã ghi nhận khoản nợ/vay {amount}!",
      "liability_name_duplicate_error": "Tên khoản nợ/vay này đã tồn tại",
      "liability_payment_saved": "Đã ghi nhận thanh toán {amount}!",
      "liability_category_borrow_label": "Hình thức vay",
      "liability_category_lend_label": "Hình thức cho mượn",
      "liability_borrower_label": "Tên khoản vay",
      "liability_borrower_hint": "VD: Vay mua nhà, Vay ngân hàng...",
      "liability_collection_method_label": "Hình thức thu hồi",
      "liability_method_installment_lend": "Thu góp",
      "liability_method_lump_sum_lend": "Thu 1 lần",
      "liability_schedule_lend_label": "Lịch thu góp",
      "liability_reminder_once_label": "Nhắc trước 1 ngày",
      "liability_reminder_recurring_label": "Nhắc trước 1 ngày mỗi kỳ",
      "liability_counterparty_vip_locked":
          "Gói miễn phí dùng tên mặc định theo danh mục '{name}'. Nâng cấp VIP để đặt tên riêng.",
      "liability_repayment_method_label": "Hình thức trả nợ",
      "liability_method_installment": "Trả góp",
      "liability_method_lump_sum": "Trả 1 lần",
      "liability_final_due_date_label": "Ngày đáo hạn",
      "liability_schedule_label": "Lịch trả góp",
      "liability_add_period": "Thêm kỳ",
      "record_repay": "Trả nợ",
      "record_collect": "Thu hồi",
      "investment_contribution": "Chi ra",
      "investment_return": "Thu vào",
      "dest_investment": "Nhận vào ví",
      "record_investment_return": "Ghi chép Thu vào",
      "investment_item": "Khoản đầu tư",
      "add_new_investment_item": "Khoản mới",
      "new_investment_item_hint": "Tên khoản đầu tư (vd: Tiệm lẩu bò)",
      "no_investment_items_hint": "Chưa có khoản đầu tư nào\nNhấn + để thêm ",
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
      "bill_match_hint": "Hóa đơn hàng tháng: {label}",
      "monthly_income_match_hint": "Thu nhập hàng tháng: {label}",
      "location_match_hint": "Bạn đang ở gần đây: {label}",
      "auto_save_countdown": "Tự động lưu trong {countdown}s...",
      "quick_entry_hint": "chi điện thoại 50.000 từ tiền mặt",
      "quick_entry_parsed_result": "Đã nhận diện: {label}",
      "quick_entry_category_missing": "Danh mục chưa có (hãy thêm +): {label}",
      "quick_entry_could_not_parse":
          "Không hiểu được nội dung này — vui lòng nhập thủ công",
      "quick_entry_daily_limit_reached":
          "Đã đạt giới hạn AI nhập nhanh hôm nay — vui lòng nhập thủ công",
      "quick_entry_mic_permission_denied":
          "Cần quyền truy cập micro để nhập bằng giọng nói",
      "quick_entry_photo_permission_denied":
          "Cần quyền truy cập máy ảnh/thư viện ảnh để quét hóa đơn",
      "quick_entry_batch_label": "{count} giao dịch · {total}",
      "quick_entry_batch_failed":
          "Không đọc được hóa đơn {indexes} — chưa lưu giao dịch nào",
      "quick_entry_batch_saved": "Đã lưu {count} giao dịch · {total}",
      "quick_entry_batch_save_failed":
          "Không lưu được hóa đơn {index}: {reason} — chưa lưu giao dịch nào",
      "quick_entry_batch_partial":
          "Đã lưu {saved}/{total} — hóa đơn {index} bị lỗi: {reason}",
      "quick_entry_scan_receipt": "Quét hóa đơn",
      "quick_entry_take_photo": "Chụp ảnh",
      "quick_entry_choose_gallery": "Chọn từ thư viện",
      "quick_entry_camera_not_available":
          "Tính năng chụp/quét ảnh chưa khả dụng",
      "smart_entry_preview_title_one": "Xem lại giao dịch",
      "smart_entry_preview_title_many": "Xem lại {count} giao dịch",
      "smart_entry_preview_subtitle": "Kiểm tra và chỉnh sửa trước khi lưu",
      "smart_entry_preview_confirm_one": "Xác nhận",
      "smart_entry_preview_confirm_many": "Xác nhận tất cả ({count})",
      "smart_entry_preview_apply_form": "Áp dụng vào biểu mẫu",
      "smart_entry_preview_pick_category": "Chọn danh mục",
      "smart_entry_preview_pick_wallet": "Chọn ví",
      "smart_entry_preview_save_failed":
          "Không lưu được giao dịch {index}: {reason} — chưa lưu gì cả",
      "smart_entry_preview_save_partial":
          "Đã lưu {saved}/{total} — giao dịch {index} bị lỗi: {reason}",
      "smart_entry_preview_saved_one": "Đã lưu giao dịch",
      "smart_entry_preview_saved_many": "Đã lưu {count} giao dịch",
      "claims_in_progress": "Bạn có {count} yêu cầu đang xử lý",
      "validation": {
        "amount_required": "Số tiền phải lớn hơn 0!",
        "wallet_required": "Vui lòng chọn ví!",
        "category_required": "Vui lòng chọn hạng mục!",
        "future_date": "Không thể ghi giao dịch ở tương lai!",
        "insufficient_balance": "Số dư ví không đủ!",
        "counterparty_required": "Vui lòng nhập đối tượng vay/cho mượn!",
        "schedule_required": "Vui lòng nhập lịch trả nợ!",
        "amount_exceeds_outstanding": "Số tiền vượt quá số dư còn lại!",
        "liability_settled": "Khoản nợ/vay này đã tất toán!",
        "not_editable": "Không thể sửa giao dịch này!",
        "edit_window": "Chỉ có thể sửa giao dịch trong 30 ngày gần nhất!",
      },
      "transfer_money": "Chuyển tiền",
      "transfer_from": "Ví nguồn",
      "transfer_to": "Ví nhận",
      "transfer_swap": "Đổi ví",
      "transfer_saved": "Đã lưu chuyển tiền thành công",
    },
    "budget": {
      "title": "Ngân sách",
      "description":
          "Giới hạn là số tiền tối đa bạn cho phép cho một danh mục mỗi tháng — vượt quá nghĩa là bạn đã chi vượt kế hoạch.",
      "empty": "Chưa có ngân sách nào.\nNhấn + để thêm giới hạn chi tiêu.",
      "edit_limit": "Sửa giới hạn",
      "edit_title": "Sửa ngân sách",
      "limit_locked":
          "Giới hạn chỉ có thể thay đổi trong 7 ngày đầu tiên của tháng.",
      "delete_title": "Xóa ngân sách",
      "delete_confirm": "Xóa \"{name}\"?",
      "reset_period": "Đặt lại kỳ",
      "reset_title": "Đặt lại ngân sách",
      "add_title": "Thêm ngân sách",
      "name": "Tên ngân sách",
      "name_hint": "Ví dụ: Điện tòa nhà A",
      "name_duplicate_error": "Tên ngân sách đã tồn tại",
      "category": "Danh mục",
      "limit": "Giới hạn",
      "limit_hint": "Ví dụ: 1000000",
      "start_date": "Bắt đầu",
      "end_date": "Kết thúc",
      "added": "Đã thêm ngân sách \"{name}\"",
      "updated": "Đã cập nhật ngân sách \"{name}\"",
      "period_started": "Đã bắt đầu kỳ mới cho \"{name}\"",
      "over_limit": "Bạn đã vượt quá giới hạn!",
      "near_limit": "Đang gần giới hạn!",
      "over_limit_count":
          "Bạn đã vượt quá giới hạn \"{name}\" {count} lần trong tháng này!",
      "over_by": "Vượt quá {amount}",
      "remaining": "Còn lại {amount}",
      "this_month": "Ngân sách tháng này",
      "month_indicator": "{month}",
      "see_all": "Xem tất cả",
      "drag_reorder_hint": "Giữ và kéo để sắp xếp lại",
      "customize_category": "Tùy chỉnh danh mục",
      "percent_used": "{percent}% đã dùng",
      "spent_prefix": "Đã chi",
      "limit_prefix": "Hạn mức",
      "fixed_price": "Chi phí cố định",
      "fixed_price_description":
          "Chi phí hàng tháng cố định (chi phí sinh tồn tối thiểu), ảnh hưởng đến chỉ số an toàn trong phần báo cáo.",
      "pacing_hint": "{name}: còn {days} ngày · Đề xuất ≤{amount}/ngày",
      "penalty_warning": "{name} đã vượt quá {percent}%!",
      "deficit_warning":
          "Chi tiêu nhiều hơn thu nhập trong tháng này (thâm hụt {amount})",
      "debt_inflow_warning":
          "{percent}% dòng tiền vào tháng này ({amount}) đến từ nợ, không phải thu nhập",
      "debt_outflow_warning":
          "{percent}% dòng tiền ra tháng này ({amount}) là tiền cho vay hoặc trả nợ, không phải chi tiêu",
      "anomaly_hint":
          "{count} chi tiêu bất thường so với trung bình 3 tháng trước",
      "insights_title": "Thông tin & cảnh báo",
      "insights_action_review": "Xem báo cáo",
      "estimate_hint": "Đề xuất: {amount} (trung bình 3 tháng gần nhất)",
    },
    "reconciliation": {
      "title": "Đối soát số dư",
      "week": "Tuần {week}/{year}",
      "book": "Sổ sách",
      "actual": "Thực tế",
      "book_balance": "Sổ sách: {amount}",
      "cycle_subtitle": "Tuần này • đến hạn Chủ Nhật",
      "description_line_1":
          "Đối soát giúp bạn khớp số dư thực tế với ứng dụng để đảm bảo mọi ghi chép tài chính luôn chính xác và minh bạch.",
      "description_line_2":
          "Tự động tạo các bút toán điều chỉnh để khớp số dư ứng dụng với thực tế mà không cần xem lại các giao dịch bị bỏ sót.",
      "mismatch_warning": "{count} ví chưa khớp, hãy xử lý trước khi xác nhận",
      "create_adjustment": "Tạo điều chỉnh",
      "matched": "Đã khớp",
      "lech": "Lệch {amount}",
      "review_transactions": "Xem giao dịch",
      "empty": "Không có ví nào để đối soát.",
      "instruction": "Nhập số dư thực tế kiểm đếm cho mỗi ví:",
      "book_total": "Tổng sổ sách",
      "actual_total": "Tổng thực tế",
      "difference": "Chênh lệch",
      "balanced": "Đã cân bằng ✓",
      "surplus": "Thặng dư {amount}",
      "deficit": "Thâm hụt {amount}",
      "confirm": "Xác nhận đối soát",
      "success": "Đã xác nhận đối soát",
      "success_message":
          "Chúc mừng! Bạn đã hoàn thành đối soát #{count} thành công.",
      "history": "Lịch sử đối soát",
      "undo": "Hoàn tác",
      "undo_title": "Hoàn tác đối soát",
      "undo_confirm":
          "Hoàn tác đối soát mới nhất và xóa các bút toán điều chỉnh?",
    },
    "report": {
      "title": "Báo cáo",
      "filter_by_wallet": "Lọc theo ví",
      "filter_all_wallets": "Tất cả các ví",
      "filter_by_type": "Lọc theo loại",
      "filter_all_types": "Tất cả các loại",
      "spending_proportion": "Tỷ trọng chi tiêu",
      "monthly_chart": "Thu chi",
      "this_week": "Tuần này",
      "four_weeks_near": "4 tuần gần nhất",
      "this_month": "Tháng này",
      "no_expense":
          "Chưa có khoản chi nào trong kỳ này.\n Hãy ghi lại bất kỳ 1 khoản chi tiêu/thu nhập, và sau đó cập nhật nếu cần",
      "weekly": "Tuần",
      "monthly": "Tháng",
      "yearly": "Năm",
      "three_months": "3 tháng",
      "income_expense": "Thu nhập & Chi tiêu",
      "safety_index": "Chỉ số an toàn (Runway)",
      "runway_desc_2":
          "Runway cho biết bạn có thể sống sót được bao lâu nếu mất thu nhập, đồng thời giúp bạn nhìn ra bức tranh tích lũy thông qua biểu đồ thu chi hàng tháng để điều chỉnh kế hoạch tài chính bền vững hơn.",
      "runway_message": "Bạn có thể duy trì {months} tháng {days} ngày",
      "runway_fixed_price_desc": "Phong cách quản lý tài chính nghiêm túc",
      "runway_no_fixed_price_desc":
          "Runway sử dụng chi tiêu thực tế của bạn. Thiết lập chi phí cố định để ước tính chính xác hơn.",
      "runway_perfect": "Chi tiêu của bạn rất xuất sắc!",
      "runway_very_good": "Rất tốt! Bạn có hơn 1 năm dự phòng",
      "runway_good": "Khá tốt! Chỉ số an toàn của bạn khá cao",
      "runway_safe": "An toàn! Bạn có ít nhất 3 tháng dự phòng",
      "runway_caution": "Cảnh báo! Bạn nên tích lũy thêm dự phòng",
      "runway_insufficient":
          "Hãy bắt đầu ghi chi tiêu để hệ thống tính chỉ số an toàn",
      "runway_not_available": "Chưa đủ dữ liệu",
      "investment_title": "Đầu tư",
      "investment_contributed": "Đã đầu tư",
      "investment_returned": "Lợi nhuận thu về",
      "liability_title": "Vay nợ",
      "liability_in": "Đi vay từ",
      "liability_out": "Cho mượn",
      "daily_detail": "Báo cáo ngày",
      "income_short": "Thu",
      "expense_short": "Chi",
      "uncategorized": "Chưa phân loại",
      "filtering_wallet": "Đang lọc: {wallet}",
      "trend_week_label": "Tuần {number}",
      "ai_advice_title": "Gợi ý tài chính từ AI",
      "ai_advice_empty_body":
          "Nhận đánh giá chi tiêu tháng này và gợi ý cải thiện tài chính, được cá nhân hóa cho bạn.",
      "ai_advice_generate_cta": "Tạo gợi ý",
      "ai_advice_loading": "Đang tạo gợi ý...",
      "ai_advice_generate_failed":
          "Không thể tạo gợi ý lúc này, vui lòng thử lại.",
      "ai_advice_daily_limit_reached":
          "Bạn đã đạt giới hạn gợi ý AI hôm nay. Vui lòng thử lại vào ngày mai.",
      "ai_advice_gemini_disabled": "Gemini AI đang tắt trong cài đặt Hồ sơ.",
      "ai_advice_generated_just_now": "Vừa tạo xong",
      "ai_advice_generated_minutes_ago": "Tạo {count} phút trước",
      "ai_advice_generated_hours_ago": "Tạo {count} giờ trước",
      "ai_advice_generated_days_ago": "Tạo {count} ngày trước",
    },
    "liability": {
      "title": "Vay nợ",
      "list_title": "Vay nợ",
      "status_outstanding": "Chưa thanh toán",
      "status_settled": "Đã thanh toán",
      "remaining_balance": "Còn lại",
      "principal_amount": "Số tiền gốc",
      "empty_state": "Chưa có khoản nợ nào",
      "empty_state_v2": "Chưa có khoản nợ/vay nào\nNhấn + để thêm vào.",
      "history_title": "Lịch sử giao dịch",
      "no_history": "Chưa có thanh toán/thu hồi nào",
      "delete_title": "Xóa khoản nợ",
      "delete_confirm_msg":
          "Bạn có chắc muốn xóa khoản nợ này? Hành động này không thể hoàn tác.",
      "borrow": "Đi vay từ",
      "lend": "Cho mượn",
      "borrow_type_personal": "Cá nhân",
      "lend_type_personal": "Cá nhân",
      "repaid_prefix": "Đã trả: ",
      "borrow_prefix": "Đi vay: ",
      "received": "Đã nhận",
      "to_collect": "Cần thu",
      "total_lend": "Tổng mượn",
    },
    "profile": {
      "guest": "Khách",
      "not_logged_in": "Chưa đăng nhập",
      "register_login": "Đăng ký / Đăng nhập",
      "display_name_title": "Sửa tên",
      "display_name_hint": "Nhập tên hiển thị của bạn",
      "display_name_save": "Lưu",
      "display_name_updated": "Đã cập nhật tên",
      "link_account_title": "Liên kết tài khoản",
      "link_account_subtitle": "Đăng nhập bằng số điện thoại hoặc Google",
      "link_account_google": "Google",
      "link_account_phone": "Số điện thoại",
      "link_account_linked": "Đã liên kết",
      "link_account_action": "Liên kết",
      "link_account_success": "Liên kết thành công",
      "link_account_phone_hint": "Nhập số điện thoại",
      "link_account_send_code": "Gửi mã",
      "link_account_verify_code": "Xác minh",
      "birth_year": "Năm sinh",
      "birth_year_subtitle": "Dùng để gợi ý danh mục phù hợp",
      "birth_year_hint":
          "Chọn năm sinh thực tế của bạn, nó ảnh hưởng đến tính toán thu nhập và chi tiêu hàng ngày",
      "birth_year_task_desc": "Nhiệm vụ: thiết lập năm sinh",
      "weekly_audit": "Kiểm tra hàng tuần",
      "days_left": "Còn {count} ngày",
      "debt_loan": "Nợ / Vay",
      "unlock_at_lv": "Mở ở LV{level}",
      "unlocked": "Đã mở khóa",
      "vip": "VIP",
      "vip_subtitle":
          "Nâng giới hạn miễn phí cho mục Đầu tư / bản ghi Nợ (chuyển đổi cục bộ, chưa có thanh toán thực tế)",
      "force_full_access": "Mở khóa tất cả tính năng",
      "force_full_access_subtitle":
          "Ghi đè Debug/QA — mở khóa ngay lập tức Đầu tư + Nợ/Vay (LV3), bất kể tiến độ thực tế của bạn",
      "gemini_ai": "Tính năng Gemini AI",
      "gemini_ai_subtitle":
          "Debug/QA — bật: nhập văn bản, giọng nói và hóa đơn được Gemini phân tích trước (cục bộ làm dự phòng). Tắt: không gửi gì tới Gemini, chỉ phân tích cục bộ",
      "weekly_audit_day": "Ngày kiểm tra hàng tuần",
      "weekly_audit_day_subtitle": "Ngày bạn xem xét số dư hàng tuần",
      "weekly_audit_day_hint":
          "Chọn ngày kiểm tra hàng tuần, thường là vào cuối chu kỳ chi tiêu của bạn",
      "audit_shortcut": "Kiểm toán",
      "reminder": "Nhắc nhở",
      "reminder_subtitle": "Nhận thông báo để ghi nhận đối soát",
      "theme_subtitle": "Chuyển đổi giữa chế độ sáng và tối",
      "language_subtitle": "Chọn ngôn ngữ ưa thích của bạn",
      "currency": "Đơn vị tiền tệ",
      "currency_subtitle": "Thay đổi đơn vị tiền tệ chính",
      "currency_dong": "Đồng",
      "currency_vnd": "Đồng Việt Nam",
      "currency_usd": "Đô la Mỹ",
      "currency_eur": "Euro",
      "currency_jpy": "Yên Nhật",
      "currency_krw": "Won Hàn Quốc",
      "currency_cny": "Nhân dân tệ",
      "view_tutorial": "Xem hướng dẫn lại",
      "view_tutorial_subtitle": "Tìm hiểu cách sử dụng ứng dụng hiệu quả",
      "terms": "Điều khoản sử dụng",
      "terms_subtitle":
          "Đọc điều khoản dịch vụ và chính sách bảo mật của chúng tôi",
      "about": "Về ứng dụng",
      "about_subtitle": "Thông tin ứng dụng và nhật ký phát triển",
      "delete_account": "Xóa tài khoản",
      "delete_confirm": "Xóa Tài Khoản?",
      "delete_confirm_desc":
          "Điều này sẽ xóa vĩnh viễn tài khoản và tất cả dữ liệu liên quan của bạn. Hành động này không thể hoàn tác.",
      "young_children_message":
          "Bạn có con nhỏ không? Nếu có, chúng tôi sẽ tự động bật các danh mục liên quan đến trẻ em (sữa, tã, đồ chơi).",
      "experience_level_progress": "Tiến độ Cấp độ Kinh nghiệm",
      "level_title": "Cấp độ {level} ({title})",
      "tap_to_return": "Chạm để quay lại hồ sơ",
      "streak_weeks": "Chuỗi: {count} tuần",
      "level_master": "Chuyên gia",
      "level_intermediate": "Trung cấp",
      "level_novice": "Sơ cấp",
      "progress_steps": "Các bước tiến độ",
      "reconciliation_streak_title": "{count} tuần chuỗi",
      "reconciliation_streak_desc": "Ngày kiểm tra: {day}",
      "rate_app": "Đánh giá ứng dụng",
      "rate_app_subtitle": "Giúp chúng tôi cải thiện Sổ Sách Xịn",
      "customer_reviews": "Khách hàng đánh giá",
      "customer_ratings_count": "{count} lượt đánh giá",
      "calculate_ratings_info": "Cách chúng tôi tính toán đánh giá",
      "out_of_5": "{rating} trên 5",
      "star_count": "{count} sao",
      "feedback_hint": "Chia sẻ thêm (không bắt buộc)",
      "feedback_send": "Gửi góp ý",
      "feedback_required": "Hãy chọn thẻ hoặc viết nội dung",
      "feedback_sent": "Cảm ơn góp ý của bạn",
      "feedback_praise_fast": "Nhập liệu rất nhanh",
      "feedback_praise_offline": "Hoạt động tốt khi ngoại tuyến",
      "feedback_praise_runway": "Tính Runway thực tế",
      "feedback_praise_reconciliation": "Đối soát chính xác",
      "feedback_praise_lending": "Quản lý vay/cho mượn rõ ràng",
      "feedback_praise_suggestions": "Gợi ý tiền chính xác",
      "feedback_praise_interface": "Giao diện tối giản",
      "feedback_praise_scanning": "Quét hóa đơn nhạy ✨",
      "feedback_praise_alerts": "Thông báo chính xác",
      "feedback_praise_leveling": "Tăng cấp thú vị",
      "feedback_criticism_sync": "Lỗi đồng bộ",
      "feedback_criticism_balance": "Số dư không khớp",
      "feedback_criticism_unlock": "Mở khóa quá lâu",
      "feedback_criticism_scanning": "Quét hóa đơn sai",
      "feedback_criticism_amount": "Khó nhập số tiền",
      "feedback_criticism_categories": "Thiếu danh mục",
      "feedback_criticism_limits": "Khó sửa hạn mức",
      "feedback_criticism_notifications": "Không có thông báo",
      "feedback_criticism_charts": "Biểu đồ khó xem",
      "feedback_criticism_speed": "Ứng dụng chậm",
    },
    "guideline": {
      "banner_title_completed":
          "Chúc mừng! Đã hoàn thành tất cả các bước thiết lập",
      "banner_title_in_progress": "Thử thách: còn {remaining} bước",
      "banner_desc_completed":
          "Bây giờ bạn có thể bắt đầu quản lý tài chính một cách kỷ luật.",
      "banner_desc_birth_year": "Thiết lập năm sinh để nhận gợi ý phù hợp",
      "banner_desc_categories": "Chọn các hạng mục thu chi của bạn",
      "banner_desc_wallet_balance": "Thiết lập số dư hiện tại cho ví của bạn",
      "banner_desc_modify_cash": "Điều chỉnh số dư trong ví tiền mặt",
      "banner_desc_budget_limit":
          "Thiết lập hạn mức chi tiêu cho từng danh mục",
      "banner_desc_min_living": "Xác định mức sinh hoạt tối thiểu hàng tháng",
      "banner_desc_first_transaction": "Ghi chép giao dịch chi tiêu đầu tiên",
      "banner_desc_investment": "Tạo khoản đầu tư đầu tiên để gia tăng tài sản",
      "banner_desc_liability": "Ghi chép khoản nợ đầu tiên để quản lý nợ",
      "banner_desc_lend":
          "Ghi chép khoản cho mượn đầu tiên (Cho mượn/Thu hồi) để quản lý cho mượn",
      "banner_desc_default": "Bạn đã sẵn sàng quản lý tài chính!",
      "success_dialog_message":
          "Chúc mừng!\nBạn đã hoàn thành thiết lập ban đầu.",
      "reset_confirm_desc":
          "Bạn có {count} nhiệm vụ đã hoàn thành. Đặt lại sẽ hủy bỏ mọi tiến độ.",
      "reset_confirm_agree": "Xem hướng dẫn",
      "reset_confirm_cancel": "Hủy",
    },
    "level_lock": {
      "unlock_at_lv": "MỞ KHÓA Ở LV{level}",
      "unlock_free_at_lv3": "Mở miễn phí khi lên LV3",
      "remaining_percent": "CÒN LẠI {percent}%",
      "investment_title": "Theo dõi Đầu tư & Tích lũy",
      "investment_desc":
          "Ghi chép cổ phiếu, quỹ, bất động sản và theo dõi ROI ngay trong ứng dụng — mở khóa bằng cách hoàn thành các thử thách kỷ luật chi tiêu.",
      "liability_title": "Quản lý Nợ & Cho mượn",
      "liability_desc":
          "Theo dõi các khoản nợ, lãi suất và lịch trả nợ chuyên nghiệp — mở khóa khi đạt được kỷ luật tài chính cao hơn.",
      "task_setup_budget": "Thiết lập ngân sách đầu tiên",
      "task_record_transactions": "Ghi chép 5 giao dịch đầu tiên",
      "task_setup_birth_year": "Thiết lập năm sinh",
      "task_reconciliation_streak": "Kỷ luật đối soát {current}/{total} tuần",
      "task_fixed_budgets": "Thiết lập {current}/{total} ngân sách cố định",
      "task_positive_cash_flow": "Dòng tiền dương trong tháng này",
      "progress_archived": "đã đạt {percent}% exp",
    },
    "category": {
      "settings_title": "Cài đặt danh mục",
      "settings_subtitle": "Quản lý danh mục và nhóm tùy chỉnh",
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
      "group_family": "Gia đình & Trẻ em",
      "food": "Thực phẩm",
      "transport": "Di chuyển",
      "shopping": "Mua sắm",
      "health": "Sức khỏe",
      "food_drink": "Ăn uống & Cà phê",
      "coffee": "Cà phê",
      "water": "Nước",
      "eat_out": "Ăn ngoài",
      "taxi": "Taxi",
      "gas": "Xăng",
      "parking": "Gửi xe",
      "maintenance": "Bảo trì",
      "electricity": "Điện",
      "internet": "Internet",
      "phone": "Điện thoại",
      "rent": "Tiền nhà",
      "furniture": "Đồ nội thất",
      "laundry": "Giặt ủi",
      "mortgage": "Vay mua nhà",
      "condo_fee": "Phí chung cư",
      "doctor": "Bác sĩ",
      "medicine": "Thuốc",
      "health_insurance": "Bảo hiểm y tế",
      "gym": "Gym",
      "tuition": "Học phí",
      "books": "Sách",
      "courses": "Khóa học",
      "cinema": "Rạp chiếu phim",
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
      "gifts": "Quà tặng",
      "charity": "Từ thiện",
      "haircut": "Cắt tóc",
      "spa": "Spa",
      "personal_care_product": "Chăm sóc cá nhân",
      "bank_fee": "Phí ngân hàng",
      "card_fee": "Phí thẻ hàng năm",
      "milk_formula": "Sữa công thức",
      "diapers": "Tã",
      "baby_toys": "Đồ chơi trẻ em",
      "income_settings_title": "Danh mục thu nhập",
      "income_group_active": "Thu nhập chủ động",
      "income_group_invest": "Thu nhập đầu tư",
      "income_group_other": "Thu nhập khác",
      "income_salary": "Lương chính",
      "income_freelance": "Tự do",
      "income_allowance": "Tiền trợ cấp",
      "income_savings_interest": "Lãi tiết kiệm",
      "income_dividends": "Cổ tức",
      "income_rental": "Cho thuê tài sản",
      "income_bonus": "Thưởng",
      "income_gift": "Quà tặng",
      "income_cashback": "Hoàn tiền",
      "debt_loan_settings_title": "Danh mục Nợ & Vay",
      "debt_group_borrow": "Đi vay",
      "debt_group_lend": "Cho vay",
      "debt_personal_borrow": "Vay cá nhân (Bạn bè)",
      "debt_bank_borrow": "Vay ngân hàng",
      "debt_mortgage": "Vay mua nhà",
      "debt_credit_card": "Nợ thẻ tín dụng",
      "debt_installment": "Trả góp",
      "debt_personal_lend": "Cho vay cá nhân",
      "debt_other": "Khác",
      "debt_other_lend": "Khác",
      "investment_bond": "Trái phiếu",
      "investment_business": "Kinh doanh",
      "investment_crypto": "Tiền mã hóa",
      "investment_fund": "Quỹ",
      "investment_gold": "Vàng",
      "investment_group_default": "Đầu tư",
      "investment_linked_insurance": "Bảo hiểm liên kết đầu tư",
      "investment_other": "Khác",
      "investment_real_estate": "Bất động sản",
      "investment_settings_title": "Danh mục đầu tư",
      "investment_stock": "Cổ phiếu",
      "investment_term_deposit": "Tiết kiệm kỳ hạn",
      "market_supermarket": "Chợ & Siêu thị",
      "religious": "Tôn giáo/Tâm linh",
      "leisure": "Giải trí & Du lịch",
      "expense_settings_title": "Danh mục chi tiêu",
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
    "sync": {
      "offline_tooltip":
          "Ngoại tuyến — dữ liệu của bạn chỉ được lưu trên thiết bị này cho đến khi kết nối lại",
      "syncing_tooltip": "Đang đồng bộ — sao lưu dữ liệu của bạn lên Cloud…",
      "pending_tooltip":
          "{count} mục chưa được sao lưu lên Cloud — nhấn để đồng bộ",
      "synced_tooltip": "Đã sao lưu toàn bộ dữ liệu lên Cloud",
      "logout_blocked_offline": "Kết nối mạng trước khi đăng xuất",
      "logout_blocked_pending":
          "Bạn có dữ liệu chưa đồng bộ. Kết nối mạng và đồng bộ trước khi đăng xuất.",
      "discard_title": "Xoá dữ liệu chưa đồng bộ?",
      "discard_message":
          "Một phần dữ liệu của bạn không thể sao lưu và sẽ bị xoá vĩnh viễn khỏi thiết bị này. Hành động này không thể hoàn tác.",
      "discard_confirm": "Xoá",
      "discard_done": "Đã xoá dữ liệu chưa đồng bộ",
    },
  };

  static const Map<String, dynamic> _ko = {
    "app": {
      "name": "So Sach Xin",
      "version": "버전 {version}",
      "description": "간편하고 효율적인 개인 재정 관리",
      "slogan": "단식부기 원칙에 따라 수입, 지출, 투자, 부채를 관리하여 재정적 자유를 향해 나아갑니다",
      "copyright": "© 2026 So Sach Xin · Made by",
      "copied_email": "이메일 복사됨: {email}",
      "author": "Tran Huy 제작",
      "role_tech": "기술",
      "role_hr": "HR",
      "author_hr_name": "Kien Nguyen",
      "author_hr_email": "kien.1000doanhnhan@gmail.com",
      "author_tech_name": "Huy Tran",
      "author_tech_email": "huytd46.fpt@gmail.com",
      "address": "Vinhome Grand Park, District 9",
      "loading": "로딩 중...",
      "error": {
        "general": "오류가 발생했습니다",
        "retry": "다시 로드하려면 탭하세요",
        "network": "네트워크 오류. 연결을 확인하세요.",
        "server": "서버 오류. 나중에 다시 시도하세요.",
      },
      "app_check": {
        "initialization_failed": "App Check 초기화 실패. 앱을 다시 시작하세요.",
        "token_refresh_failed": "보안 토큰 새로고침 실패. 연결을 확인하세요.",
        "device_not_verified": "기기 확인 실패. 이 기기는 지원되지 않을 수 있습니다.",
      },
    },
    "common": {
      "ok": "확인",
      "cancel": "취소",
      "save": "저장",
      "delete": "삭제",
      "edit": "편집",
      "back": "뒤로",
      "continue": "계속",
      "next": "다음",
      "skip": "건너뛰기",
      "done": "완료",
      "search": "검색",
      "no_results": "결과를 찾을 수 없습니다",
      "no_data": "데이터가 없습니다",
      "or": "또는",
      "not_set": "설정되지 않음",
      "sunday_short": "일",
      "select_date": "날짜 선택",
      "income": "수입",
      "expense": "지출",
      "common_weekday_names": "월|화|수|목|금|토|일",
      "press_back_again_to_exit": "종료하려면 뒤로 버튼을 다시 누르세요",
      "add_source": "소스 추가",
      "add": "추가",
      "copy": "복사",
      "clear": "지우기",
      "unit_billion": "조",
      "unit_million": "백만",
      "unit_thousand": "천",
    },
    "auth": {
      "login": "로그인",
      "logout": "로그아웃",
      "email": "이메일",
      "password": "비밀번호",
      "forgot_password": "비밀번호를 잊으셨나요?",
      "signup": "회원가입",
      "no_account": "계정이 없으신가요?",
      "have_account": "이미 계정이 있으신가요?",
      "login_success": "로그인 성공",
      "login_failed": "로그인 실패. 자격 증명을 확인하세요.",
      "login_google": "Google로 로그인",
      "login_apple": "Apple로 로그인",
      "login_phone": "전화번호로 로그인",
      "enter_phone_number": "전화번호로\n로그인",
      "phone_number": "전화번호",
      "phone_number_hint": "전화번호 입력",
      "phone_hint": "+1234567890",
      "verify": "확인",
      "send_code": "코드 보내기",
      "enter_code": "SMS 코드 입력",
      "we_just_sent_sms": "SMS를 보냈습니다",
      "enter_security_code": "보낸 보안 코드를 입력하세요",
      "didnt_receive_code": "코드를 받지 못하셨나요?",
      "resend": "후에 재전송",
      "terms_and_privacy": "계속하면 서비스 약관 및 개인정보 보호정책에 동의합니다",
      "biometric": {
        "reason": "인증 필요",
        "fallback": "설정에서 이 앱의 생체 인식을 활성화하세요.",
        "not_available_log": "생체 인식을 사용할 수 없습니다",
        "init_error": "생체 인식 초기화 오류: {error}",
        "error": {
          "not_available": "이 기기에서 생체 인식을 사용할 수 없습니다.",
          "not_enrolled": "이 기기에 등록된 생체 인식이 없습니다.",
          "locked_out": "시도 횟수 초과. 나중에 다시 시도하세요.",
          "permanently_locked_out": "생체 인식이 영구적으로 잠겨 있습니다.",
          "passcode_not_set": "기기에 비밀번호가 설정되지 않았습니다.",
          "user_canceled": "사용자가 인증을 취소했습니다.",
          "app_canceled": "앱이 인증을 취소했습니다.",
          "system_canceled": "시스템이 인증을 취소했습니다.",
          "generic": "인증 오류: {error}",
        },
      },
      "otp": {
        "invalid": "잘못된 OTP 코드",
        "expired": "OTP 코드가 만료되었습니다",
        "too_many_attempts": "시도 횟수 초과. 나중에 다시 시도하세요",
      },
    },
    "validation": {
      "required": "이 필드는 필수입니다",
      "email": "유효한 이메일을 입력하세요",
      "password_length": "비밀번호는 최소 {length}자 이상이어야 합니다",
      "password_match": "비밀번호가 일치하지 않습니다",
      "phone": "잘못된 전화번호 형식",
      "max_length_reached": "최대 {count}자에 도달했습니다",
    },
    "home": {
      "title": "홈",
      "welcome": "환영합니다, {name}님!",
      "recent_activity": "최근 활동",
      "view_all": "모두 보기",
      "my_wallets": "내 지갑",
    },
    "settings": {
      "title": "설정",
      "language": "언어",
      "language_vietnamese": "베트남어",
      "language_english": "영어",
      "language_korean": "한국어",
      "language_japanese": "일본어",
      "language_chinese": "중국어",
      "theme": "테마",
      "theme_static": "고정",
      "theme_light": "라이트 모드",
      "theme_dark": "다크 모드",
      "notifications": "알림",
      "privacy": "개인정보 보호",
      "help": "도움말 및 지원",
      "about": "정보",
    },
    "nav": {
      "home": "홈",
      "transaction": "거래",
      "budget_allocation": "예산 할당",
      "dashboard": "대시보드",
      "quick_test": "빠른 테스트",
      "quick_test_page": "빠른 테스트 페이지",
      "notification": "알림",
      "profile": "프로필",
      "profile_info": "개인 정보",
    },
    "dashboard": {
      "item_count": "항목 수",
      "last_updated": "마지막 업데이트",
      "refresh_data": "데이터 새로고침",
      "time": {
        "just_now": "방금",
        "day": "{count}일 전",
        "days": "{count}일 전",
        "hour": "{count}시간 전",
        "hours": "{count}시간 전",
        "minute": "{count}분 전",
        "minutes": "{count}분 전",
      },
    },
    "wallet": {
      "my_account": "내 계좌",
      "spending_account": "지출 계좌",
      "total_assets": "총 자산",
      "your_wallets": "유동 자산 지갑",
      "see_all": "모두 보기",
      "empty": "지갑이 없습니다.\n+를 탭하여 추가하세요.",
      "investment_empty": "투자 지갑이 없습니다\n+를 탭하여 추가",
      "investment_name": "투자 이름",
      "investment_name_hint": "예: BTC, Apple 주식...",
      "investment_delete_title": "투자 삭제",
      "investment_delete_confirm":
          "총 성과 가치가 0일 때만 투자 항목을 삭제할 수 있습니다. 관련 거래가 소프트 삭제됩니다. 계속하시겠습니까?",
      "investment_edit_title": "투자 편집",
      "add_title": "새 지갑 추가",
      "edit_title": "지갑 편집",
      "name": "지갑 이름",
      "name_hint": "예: Techcombank, tcb777, vcb789",
      "name_duplicate_error": "이 지갑 이름이 이미 존재합니다",
      "initial_balance": "개시 잔액",
      "initial_balance_hint": "예: 1000000",
      "balance_locked_hint":
          "지갑에 거래가 있으면 개시 잔액을 변경할 수 없습니다\n조정을 추적하려면 새 지갑을 만드세요",
      "balance_hidden": "*****",
      "save_info": "저장",
      "bank": "은행",
      "cash": "현금",
      "ewallet": "전자지갑",
      "emergency_fund": "비상 자금",
      "emergency_fund_desc": "비상시용 · 지출의 3-6개월을 목표로 유지",
      "emergency_fund_locked_hint": "비상 자금 가이드를 읽은 후 LV2에서 열립니다",
      "emergency_fund_view_ebook": "가이드 읽기",
      "added_success": "새 지갑이 추가되었습니다",
      "updated_success": "지갑이 업데이트되었습니다",
      "delete_title": "지갑 삭제",
      "delete_confirm_msg":
          "거래가 없는 지갑만 삭제할 수 있습니다. 지갑의 모든 거래가 소프트 삭제됩니다. 계속하시겠습니까?",
      "delete_error_not_empty": "삭제할 수 없음: 지갑에 거래가 있습니다",
      "delete_error_protected": "이 지갑은 필수이며 삭제할 수 없습니다",
      "liquid_assets": "유동 자산",
      "liquid_assets_desc": "현금 + 은행 + 전자지갑 · 즉시 사용 가능",
      "investments": "투자 / 축적",
      "investments_desc": "주식, 펀드, 부동산...",
      "liabilities": "부채",
      "liabilities_desc": "대출 + 신용카드 · 잔액 추적, 스트레스 모니터링",
      "investment_roi": "ROI",
      "investment_breakeven": "손익분기점",
    },
    "comment": {
      "detail": {
        "title": "댓글 세부정보",
        "content": "댓글 내용",
        "post_id": "게시물 ID",
        "id": "댓글 ID",
      },
    },
    "transaction": {
      "title": "거래",
      "wallet": "총 지갑",
      "emergency": "비상",
      "investment": "투자",
      "debt": "부채 및 대출",
      "category": "카테고리",
      "amount": "금액",
      "source_expense": "지출 원천",
      "reason_expense": "지출 사유",
      "enter_content": "내용 입력",
      "payer": "지불자",
      "staff_name": "직원 이름",
      "time": "시간",
      "history": "기록",
      "record_expense": "지출 기록",
      "expense_saved": "{amount} 지출이 성공적으로 저장되었습니다!",
      "income_saved": "{amount} 수입이 성공적으로 저장되었습니다!",
      "expense_updated": "{amount} 지출이 업데이트되었습니다!",
      "income_updated": "{amount} 수입이 업데이트되었습니다!",
      "edit_title": "거래 편집",
      "delete_title": "거래 삭제",
      "delete_confirm_desc": "이 작업은 취소할 수 없습니다.",
      "liability_payment_saved": "{amount} 지불이 기록되었습니다!",
      "source_income": "수입 원천",
      "reason_income": "수입 사유",
      "recipient": "수취인",
      "record_income": "수입 기록",
      "source_investment": "투자 원천",
      "destination_investment": "수신 지갑",
      "record_investment": "투자 기록",
      "investment_saved": "{amount} 투자가 성공적으로 저장되었습니다!",
      "source_debt": "부채 원천",
      "record_debt": "부채 기록",
      "debt_saved": "{amount} 부채가 성공적으로 저장되었습니다!",
      "liability_direction_borrow": "차용",
      "liability_direction_lend": "대여",
      "liability_name_label": "부채 이름",
      "liability_name_hint": "예: 노트북 구매, 은행 대출...",
      "record_liability": "부채 기록",
      "liability_amount_borrow_label": "차용 금액",
      "liability_amount_lend_label": "대여 금액",
      "liability_wallet_borrow_label": "수신 지갑",
      "liability_wallet_lend_label": "대여 지갑",
      "liability_saved": "{amount} 부채가 기록되었습니다!",
      "liability_name_duplicate_error": "이 부채 이름이 이미 존재합니다",
      "liability_category_borrow_label": "대출 유형",
      "liability_category_lend_label": "대여 유형",
      "liability_borrower_label": "대출 이름",
      "liability_borrower_hint": "예: 주택 구매 대출, 친구 대출...",
      "liability_collection_method_label": "수금 방법",
      "liability_method_installment_lend": "할부",
      "liability_method_lump_sum_lend": "일시불",
      "liability_schedule_lend_label": "수금 일정",
      "liability_reminder_once_label": "1일 전 알림",
      "liability_reminder_recurring_label": "각 만기일 1일 전 알림",
      "liability_counterparty_vip_locked":
          "무료 플랜은 카테고리의 기본 이름 '{name}'을 사용합니다. 사용자 정의 이름을 설정하려면 VIP로 업그레이드하세요.",
      "liability_repayment_method_label": "상환 방법",
      "liability_method_installment": "할부",
      "liability_method_lump_sum": "만기 일시불",
      "liability_final_due_date_label": "만기일",
      "liability_schedule_label": "할부 일정",
      "liability_add_period": "기간 추가",
      "record_repay": "상환",
      "record_collect": "수금",
      "investment_contribution": "출자",
      "investment_return": "회수",
      "dest_investment": "지갑에 수신",
      "record_investment_return": "회수 기록",
      "investment_item": "투자 항목",
      "add_new_investment_item": "새 항목",
      "new_investment_item_hint": "항목 이름 (예: 커피숍)",
      "no_investment_items_hint": "이 카테고리에 투자 항목이 아직 없습니다 — 먼저 출자하세요.",
      "investment_item_vip_locked":
          "무료 플랜은 카테고리의 기본 이름 '{name}'을 사용합니다. 사용자 정의 투자 항목 이름을 설정하려면 VIP로 업그레이드하세요.",
      "expense_slip": "지출",
      "income_slip": "수입",
      "category_sub": "하위 카테고리",
      "today": "오늘",
      "yesterday": "어제",
      "note": "메모",
      "note_hint": "메모 (선택 사항)",
      "more_details": "더 많은 세부정보",
      "merchant_match_hint": "지난번과 같음: {label}",
      "location_match_hint": "근처에 있음: {label}",
      "bill_match_hint": "월간 청구서: {label}",
      "monthly_income_match_hint": "월간 수입: {label}",
      "auto_save_countdown": "{countdown}초 후 자동 저장...",
      "quick_entry_hint": "현금으로 휴대폰 50,000 지출",
      "quick_entry_parsed_result": "이해됨: {label}",
      "quick_entry_category_missing": "카테고리를 찾을 수 없음 (+ 필요): {label}",
      "quick_entry_could_not_parse": "이해할 수 없습니다 — 수동으로 입력하세요",
      "quick_entry_daily_limit_reached": "오늘 AI 빠른 입력 한도에 도달했습니다 — 수동으로 입력하세요",
      "quick_entry_mic_permission_denied": "음성 입력에 마이크 권한이 필요합니다",
      "quick_entry_photo_permission_denied": "영수증 스캔에 카메라/사진 권한이 필요합니다",
      "quick_entry_batch_label": "{count} 거래 · {total}",
      "quick_entry_batch_failed":
          "영수증 {indexes}을(를) 읽을 수 없습니다 — 아무것도 저장되지 않았습니다",
      "quick_entry_batch_saved": "{count} 거래 저장됨 · {total}",
      "quick_entry_batch_save_failed":
          "영수증 {index}을(를) 저장할 수 없음: {reason} — 아무것도 저장되지 않았습니다",
      "quick_entry_batch_partial":
          "{saved}/{total} 저장됨 — 영수증 {index} 실패: {reason}",
      "quick_entry_scan_receipt": "영수증 스캔",
      "quick_entry_take_photo": "사진 촬영",
      "quick_entry_choose_gallery": "갤러리에서 선택",
      "quick_entry_camera_not_available": "카메라 기능을 아직 사용할 수 없습니다",
      "smart_entry_preview_title_one": "거래 확인",
      "smart_entry_preview_title_many": "거래 {count}건 확인",
      "smart_entry_preview_subtitle": "저장하기 전에 확인하고 수정하세요",
      "smart_entry_preview_confirm_one": "확인",
      "smart_entry_preview_confirm_many": "모두 확인 ({count})",
      "smart_entry_preview_apply_form": "양식에 적용",
      "smart_entry_preview_pick_category": "카테고리 선택",
      "smart_entry_preview_pick_wallet": "지갑 선택",
      "smart_entry_preview_save_failed":
          "거래 {index}을(를) 저장하지 못했습니다: {reason} — 아무것도 저장되지 않았습니다",
      "smart_entry_preview_save_partial":
          "{saved}/{total} 저장됨 — 거래 {index} 실패: {reason}",
      "smart_entry_preview_saved_one": "거래가 저장되었습니다",
      "smart_entry_preview_saved_many": "거래 {count}건이 저장되었습니다",
      "claims_in_progress": "{count} 요청이 진행 중입니다",
      "validation": {
        "amount_required": "금액은 0보다 커야 합니다",
        "wallet_required": "지갑을 선택하세요",
        "category_required": "카테고리를 선택하세요",
        "future_date": "미래 거래를 기록할 수 없습니다",
        "insufficient_balance": "지갑 잔액이 부족합니다",
        "counterparty_required": "대출 상대를 입력하세요",
        "schedule_required": "상환 일정을 입력하세요",
        "amount_exceeds_outstanding": "금액이 남은 잔액을 초과합니다",
        "liability_settled": "이 부채는 이미 정산되었습니다",
        "not_editable": "이 거래는 편집할 수 없습니다",
        "edit_window": "최근 30일 이내의 거래만 편집할 수 있습니다",
      },
      "transfer_money": "송금",
      "transfer_from": "출금 지갑",
      "transfer_to": "입금 지갑",
      "transfer_swap": "지갑 바꾸기",
      "transfer_saved": "송금이 저장되었습니다",
    },
    "liability": {
      "title": "부채",
      "list_title": "부채",
      "status_outstanding": "미결",
      "status_settled": "정산됨",
      "remaining_balance": "잔액",
      "principal_amount": "원금",
      "empty_state": "부채가 아직 없습니다",
      "empty_state_v2": "부채/대여가 아직 없습니다\n+를 탭하여 추가하세요.",
      "history_title": "거래 기록",
      "no_history": "상환/수금 기록이 아직 없습니다",
      "delete_title": "부채 삭제",
      "delete_confirm_msg": "이 부채를 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.",
      "borrow": "차용",
      "lend": "대여",
      "borrow_type_personal": "개인",
      "lend_type_personal": "개인",
      "repaid_prefix": "상환됨: ",
      "borrow_prefix": "차용됨: ",
      "received": "수신됨",
      "to_collect": "수금",
      "total_lend": "총 대여",
    },
    "notification": {
      "channel_name": "알림",
      "channel_description": "감사 알림, 클라우드 등록 및 대출 만기일 알림",
      "audit_approaching_title": "감사일이 다가오고 있습니다",
      "audit_approaching_body": "내일이 주간 감사일입니다. 잔액을 조정하는 것을 잊지 마세요!",
      "audit_due_title": "감사일입니다",
      "audit_due_body": "오늘이 주간 감사일입니다. 지금 잔액을 조정하세요!",
      "cloud_backup_title": "데이터 보호",
      "cloud_backup_body": "계정을 등록하여 데이터를 클라우드에 백업하고 손실을 방지하세요.",
      "loan_due_title": "대출 만기일이 다가오고 있습니다",
      "loan_due_body": "대출 '{name}'이(가) {date}에 만기됩니다.",
      "budget_near_limit_body": "예산 \"{name}\"이(가) 80%에 도달했습니다.",
      "budget_over_body": "예산 \"{name}\"이(가) 한도를 초과했습니다.",
    },
    "tutorial": {
      "nav_title": "내비게이션 바",
      "nav_desc":
          "Phân 할당은 지갑과 예산을 보여주고, Giao dịch는 거래를 기록하며, Hồ sơ는 프로필과 설정입니다.",
      "transaction_title": "거래 기록",
      "transaction_desc":
          "여기에서 Chi tiêu/Thu nhập/Đầu tư/Vay-Nợ를 선택한 다음 금액을 입력하고 저장하세요.",
    },
    "budget": {
      "title": "예산",
      "description":
          "한도는 월별 카테고리에 허용하는 최대 금액입니다 — 초과하면 계획보다 더 많이 지출하는 것을 의미합니다.",
      "empty": "예산이 아직 없습니다.\n+를 탭하여 지출 한도를 추가하세요.",
      "edit_limit": "한도 편집",
      "edit_title": "예산 편집",
      "limit_locked": "한도는 월초 7일 동안만 변경할 수 있습니다.",
      "delete_title": "예산 삭제",
      "delete_confirm": "\"{name}\"을(를) 삭제하시겠습니까?",
      "reset_period": "기간 재설정",
      "reset_title": "예산 재설정",
      "add_title": "예산 추가",
      "name": "예산 이름",
      "name_hint": "예: A동 전기",
      "name_duplicate_error": "예산 이름이 이미 존재합니다",
      "category": "카테고리",
      "limit": "한도",
      "limit_hint": "예: 1000000",
      "start_date": "시작",
      "end_date": "종료",
      "added": "예산 \"{name}\"이(가) 추가되었습니다",
      "updated": "예산 \"{name}\"이(가) 업데이트되었습니다",
      "period_started": "\"{name}\"에 대한 새 기간이 시작되었습니다",
      "over_limit": "한도를 초과했습니다!",
      "near_limit": "한도에 가까워지고 있습니다!",
      "over_limit_count": "이번 달 \"{name}\" 한도를 {count}번 초과했습니다!",
      "over_by": "{amount} 초과",
      "remaining": "{amount} 남음",
      "this_month": "이번 달 예산",
      "month_indicator": "{month}",
      "see_all": "모두 보기",
      "drag_reorder_hint": "길게 눌러 드래그하여 재정렬",
      "customize_category": "카테고리 사용자 정의",
      "percent_used": "{percent}% 사용됨",
      "spent_prefix": "지출됨",
      "limit_prefix": "한도",
      "fixed_price": "고정 가격",
      "fixed_price_description":
          "고정 월간 비용 (최소 생존 비용), 보고서 섹션의 안전 지수에 영향을 미칩니다.",
      "pacing_hint": "{name}: {days}일 남음 · 제안 ≤{amount}/일",
      "penalty_warning": "{name}이(가) {percent}% 초과했습니다!",
      "deficit_warning": "이번 달 수입보다 더 많이 지출합니다 (적자 {amount})",
      "debt_inflow_warning": "이번 달 유입의 {percent}%({amount})가 수입이 아닌 부채에서 옵니다",
      "debt_outflow_warning":
          "이번 달 유출의 {percent}%({amount})가 지출이 아닌 대여 또는 상환입니다",
      "anomaly_hint": "지난 3개월 평균 대비 {count}개의 이상 지출",
      "insights_title": "인사이트 및 경고",
      "insights_action_review": "보고서 보기",
      "estimate_hint": "제안: {amount} (최근 3개월 평균)",
    },
    "reconciliation": {
      "title": "조정",
      "empty": "조정할 지갑이 없습니다.",
      "instruction": "각 지갑의 실제 계산 잔액을 입력하세요:",
      "book_total": "장부 총계",
      "actual_total": "실제 총계",
      "difference": "차이",
      "balanced": "균형 ✓",
      "surplus": "흑자 {amount}",
      "deficit": "적자 {amount}",
      "confirm": "조정 확인",
      "success": "조정 확인됨",
      "success_message": "축하합니다! 조정 #{count}을(를) 성공적으로 완료했습니다.",
      "history": "조정 기록",
      "undo": "실행 취소",
      "undo_title": "조정 실행 취소",
      "undo_confirm": "최신 조정을 실행 취소하고 조정 항목을 제거하시겠습니까?",
      "week": "{week}/{year}주",
      "book": "장부",
      "actual": "실제",
      "book_balance": "장부: {amount}",
      "cycle_subtitle": "이번 주 · 일요일 마감",
      "description_line_1":
          "조정은 실제 잔액을 앱과 일치시켜 모든 재무 기록이 항상 정확하고 투명하게 유지되도록 돕습니다.",
      "description_line_2":
          "누락된 거래를 검토할 필요 없이 실제와 일치하도록 장부 잔액을 조정하는 조정 항목을 자동으로 생성합니다.",
      "mismatch_warning": "{count}개 지갑이 일치하지 않습니다. 확인하기 전에 처리하세요",
      "create_adjustment": "조정 생성",
      "matched": "일치함",
      "lech": "{amount} 차이",
      "review_transactions": "거래 검토",
    },
    "report": {
      "title": "보고서",
      "spending_proportion": "지출 분포",
      "monthly_chart": "수입 및 지출",
      "this_week": "이번 주",
      "four_weeks_near": "최근 4주",
      "this_month": "이번 달",
      "no_expense": "이 기간에 지출이 없습니다. \n지출/수입을 기록한 다음 필요한 경우 업데이트하세요",
      "weekly": "주간",
      "monthly": "월간",
      "yearly": "연간",
      "three_months": "3개월",
      "income_expense": "수입 및 지출",
      "safety_index": "안전 지수 (런웨이)",
      "runway_desc_2":
          "런웨이는 수입 없이 생존할 수 있는 기간을 보여주며, 월간 수입 및 지출 차트를 통해 축적을 확인하여 더 지속 가능한 재정 계획으로 조정할 수 있도록 돕습니다.",
      "runway_message": "{months}개월 {days}일 동안 유지할 수 있습니다",
      "runway_fixed_price_desc": "진지한 재정 관리 라이프스타일",
      "runway_no_fixed_price_desc":
          "런웨이는 실제 지출을 사용합니다. 더 정확한 추정을 위해 고정 비용을 설정하세요.",
      "runway_perfect": "지출이 훌륭합니다!",
      "runway_very_good": "훌륭합니다! 1년 이상의 버퍼가 있습니다",
      "runway_good": "매우 좋습니다! 안전 지수가 상당히 높습니다",
      "runway_safe": "안전합니다! 최소 3개월의 버퍼가 있습니다",
      "runway_caution": "주의! 더 많은 버퍼를 구축해야 합니다",
      "runway_insufficient": "시스템이 안전 지수를 계산할 수 있도록 지출 기록을 시작하세요.",
      "runway_not_available": "데이터 부족",
      "investment_title": "투자",
      "investment_contributed": "출자",
      "investment_returned": "회수",
      "liability_title": "부채",
      "liability_in": "차용",
      "liability_out": "대여",
      "daily_detail": "일별 세부정보",
      "income_short": "수입",
      "expense_short": "지출",
      "uncategorized": "분류되지 않음",
      "filtering_wallet": "필터링: {wallet}",
      "filter_by_wallet": "지갑으로 필터",
      "filter_all_wallets": "모든 지갑",
      "filter_by_type": "유형으로 필터",
      "filter_all_types": "모든 유형",
      "trend_week_label": "{number}주",
      "ai_advice_title": "AI 재정 조언",
      "ai_advice_empty_body": "이번 달 지출에 대한 개인화된 검토와 재정 개선 제안을 받으세요.",
      "ai_advice_generate_cta": "조언 생성",
      "ai_advice_loading": "조언 생성 중...",
      "ai_advice_generate_failed": "지금 조언을 생성할 수 없습니다. 나중에 다시 시도하세요.",
      "ai_advice_daily_limit_reached": "오늘 AI 조언 한도에 도달했습니다. 내일 다시 시도하세요.",
      "ai_advice_gemini_disabled": "프로필 설정에서 Gemini AI가 꺼져 있습니다.",
      "ai_advice_generated_just_now": "방금 생성됨",
      "ai_advice_generated_minutes_ago": "{count}분 전 생성됨",
      "ai_advice_generated_hours_ago": "{count}시간 전 생성됨",
      "ai_advice_generated_days_ago": "{count}일 전 생성됨",
    },
    "category": {
      "settings_title": "카테고리 설정",
      "settings_subtitle": "사용자 정의 카테고리 및 그룹 관리",
      "group_daily": "일일",
      "group_personal": "개인",
      "group_food_drink": "식사 및 커피",
      "group_transport": "교통",
      "group_utilities": "유틸리티",
      "group_housing": "주거",
      "group_health": "의료 및 건강",
      "group_education": "교육",
      "group_entertainment": "엔터테인먼트",
      "group_shopping": "쇼핑",
      "group_insurance": "보험",
      "group_gifts": "선물 및 기부",
      "group_personal_care": "개인 관리",
      "group_service_fees": "서비스 수수료",
      "group_family": "가족 및 아동",
      "food": "식품",
      "transport": "교통",
      "shopping": "쇼핑",
      "health": "건강",
      "food_drink": "식사 및 커피",
      "coffee": "커피",
      "water": "물",
      "eat_out": "외식",
      "taxi": "택시",
      "gas": "가스",
      "parking": "주차",
      "maintenance": "유지보수",
      "electricity": "전기",
      "internet": "인터넷",
      "phone": "전화",
      "rent": "임대료",
      "furniture": "가구",
      "laundry": "세탁",
      "mortgage": "모기지",
      "condo_fee": "콘도 수수료",
      "doctor": "의사",
      "medicine": "약",
      "health_insurance": "건강 보험",
      "gym": "헬스장",
      "tuition": "수업료",
      "books": "책",
      "courses": "강좌",
      "cinema": "영화관",
      "travel": "여행",
      "gaming": "게이밍",
      "events": "이벤트",
      "appliances": "가전제품",
      "electronics": "전자제품",
      "clothing": "의류",
      "cosmetics": "화장품",
      "installment": "할부",
      "life_insurance": "생명 보험",
      "vehicle_insurance": "차량 보험",
      "home_insurance": "주택 보험",
      "gifts": "선물",
      "charity": "기부",
      "haircut": "이발",
      "spa": "스파",
      "personal_care_product": "개인 관리 용품",
      "bank_fee": "은행 수수료",
      "card_fee": "카드 연회비",
      "milk_formula": "유아용 분유",
      "diapers": "기저귀",
      "baby_toys": "유아 장난감",
      "income_settings_title": "수입 카테고리",
      "income_group_active": "활성 수입",
      "income_group_invest": "투자 수입",
      "income_group_other": "기타 수입",
      "income_salary": "기본 급여",
      "income_freelance": "프리랜서",
      "income_allowance": "용돈",
      "income_savings_interest": "저축 이자",
      "income_dividends": "배당금",
      "income_rental": "자산 임대료",
      "income_bonus": "보너스",
      "income_gift": "선물/선물",
      "income_cashback": "캐시백",
      "debt_loan_settings_title": "부채 및 대출 카테고리",
      "debt_group_borrow": "차용",
      "debt_group_lend": "대여",
      "debt_personal_borrow": "개인 대출 (친구)",
      "debt_bank_borrow": "은행/금융 대출",
      "debt_mortgage": "모기지",
      "debt_credit_card": "신용카드 부채",
      "debt_installment": "할부",
      "debt_personal_lend": "개인 대여",
      "debt_other": "기타",
      "debt_other_lend": "기타",
      "investment_bond": "채권",
      "investment_business": "비즈니스",
      "investment_crypto": "암호화폐",
      "investment_fund": "펀드",
      "investment_gold": "금",
      "investment_group_default": "투자",
      "investment_linked_insurance": "투자 연계 보험",
      "investment_other": "기타",
      "investment_real_estate": "부동산",
      "investment_settings_title": "투자 카테고리",
      "investment_stock": "주식",
      "investment_term_deposit": "정기 예금",
      "market_supermarket": "시장 및 슈퍼마켓",
      "religious": "종교/영성",
      "leisure": "여가 및 여행",
      "expense_settings_title": "지출 카테고리",
    },
    "sync": {
      "offline_tooltip": "오프라인 — 데이터는 재연결될 때까지 이 기기에만 저장됩니다",
      "syncing_tooltip": "동기화 중 — 데이터를 클라우드에 백업 중…",
      "pending_tooltip": "{count}개 항목이 아직 클라우드에 백업되지 않았습니다 — 탭하여 동기화",
      "synced_tooltip": "모든 데이터가 클라우드에 백업되었습니다",
      "logout_blocked_offline": "로그아웃하기 전에 인터넷에 연결하세요",
      "logout_blocked_pending":
          "아직 동기화되지 않은 데이터가 있습니다. 로그아웃하기 전에 재연결하고 동기화하세요.",
      "discard_title": "동기화되지 않은 데이터를 삭제하시겠습니까?",
      "discard_message":
          "일부 데이터를 백업할 수 없었으며 이 기기에서 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다.",
      "discard_confirm": "삭제",
      "discard_done": "동기화되지 않은 데이터가 삭제되었습니다",
    },
    "profile": {
      "guest": "게스트",
      "not_logged_in": "로그인되지 않음",
      "register_login": "등록 / 로그인",
      "display_name_title": "이름 편집",
      "display_name_hint": "표시 이름 입력",
      "display_name_save": "저장",
      "display_name_updated": "이름이 업데이트되었습니다",
      "link_account_title": "계정 연결",
      "link_account_subtitle": "전화번호 또는 Google로 로그인",
      "link_account_google": "Google",
      "link_account_phone": "전화번호",
      "link_account_linked": "연결됨",
      "link_account_action": "연결",
      "link_account_success": "성공적으로 연결되었습니다",
      "link_account_phone_hint": "전화번호 입력",
      "link_account_send_code": "코드 보내기",
      "link_account_verify_code": "확인",
      "birth_year": "출생 연도",
      "birth_year_subtitle": "적절한 카테고리를 제안하는 데 사용",
      "birth_year_hint": "실제 출생 연도를 선택하세요. 일일 수입 및 지출 계산에 영향을 미칩니다",
      "birth_year_task_desc": "작업: 출생 연도 설정",
      "weekly_audit": "주간 감사",
      "days_left": "{count}일 남음",
      "debt_loan": "부채 / 대출",
      "unlock_at_lv": "LV{level}에서 열림",
      "unlocked": "잠금 해제됨",
      "vip": "VIP",
      "vip_subtitle": "투자 항목 / 대출 기록의 무료 계층 한도를 해제합니다 (로컬 토글, 실제 결제 없음)",
      "force_full_access": "모든 기능 잠금 해제",
      "force_full_access_subtitle":
          "디버그/QA 재정의 — 실제 진행 상관없이 투자 + 부채/대출(LV3)을 즉시 잠금 해제",
      "gemini_ai": "Gemini AI 기능",
      "gemini_ai_subtitle":
          "디버그/QA — 켜짐: 텍스트, 음성 및 영수증 항목이 Gemini에 의해 먼저 구문 분석됨(로컬 대체). 꺼짐: Gemini에 아무것도 전송되지 않고 로컬 구문 분석만 실행",
      "weekly_audit_day": "주간 감사일",
      "weekly_audit_day_subtitle": "주간 잔액을 검토하는 날",
      "weekly_audit_day_hint": "주간 감사일을 선택하세요. 일반적으로 지출 주기의 끝",
      "audit_shortcut": "감사",
      "reminder": "알림",
      "reminder_subtitle": "조정 기록 알림 수신",
      "theme_subtitle": "라이트 및 다크 모드 전환",
      "language_subtitle": "선호하는 언어 선택",
      "currency": "통화 단위",
      "currency_subtitle": "기본 통화 단위 변경",
      "currency_dong": "동",
      "currency_vnd": "베트남 동",
      "currency_usd": "미국 달러",
      "currency_eur": "유로",
      "currency_jpy": "일본 엔",
      "currency_krw": "대한민국 원",
      "currency_cny": "중국 위안",
      "view_tutorial": "튜토리얼 다시 보기",
      "view_tutorial_subtitle": "앱을 효과적으로 사용하는 방법 배우기",
      "terms": "이용 약관",
      "terms_subtitle": "서비스 약관 및 개인정보 보호정책 읽기",
      "about": "앱 정보",
      "about_subtitle": "앱 정보 및 개발자 로그",
      "delete_account": "계정 삭제",
      "delete_confirm": "계정을 삭제하시겠습니까?",
      "delete_confirm_desc": "계정 및 모든 관련 데이터를 영구적으로 삭제합니다. 이 작업은 취소할 수 없습니다.",
      "young_children_message":
          "어린 자녀가 있으신가요? 예라면 우유, 기저귀, 장난감 관련 카테고리를 자동으로 활성화합니다.",
      "experience_level_progress": "경험 수준 진행",
      "level_title": "레벨 {level} ({title})",
      "tap_to_return": "탭하여 프로필로 돌아가기",
      "streak_weeks": "연속: {count}주",
      "level_master": "마스터",
      "level_intermediate": "중급",
      "level_novice": "초급",
      "progress_steps": "진행 단계",
      "reconciliation_streak_title": "{count}주 연속",
      "reconciliation_streak_desc": "감사일: {day}",
      "rate_app": "앱 평가",
      "rate_app_subtitle": "So Sach Xin 개선에 도움을 주세요",
      "customer_reviews": "고객 리뷰",
      "customer_ratings_count": "{count}개의 고객 평가",
      "calculate_ratings_info": "평가는 어떻게 계산되나요?",
      "out_of_5": "5점 만점에 {rating}점",
      "star_count": "{count}점",
      "feedback_hint": "더 자세히 알려주세요 (선택 사항)",
      "feedback_send": "피드백 보내기",
      "feedback_required": "태그를 선택하거나 내용을 입력하세요",
      "feedback_sent": "피드백 감사합니다",
      "feedback_praise_fast": "빠른 입력",
      "feedback_praise_offline": "오프라인에서도 잘 작동",
      "feedback_praise_runway": "정확한 런웨이 계산",
      "feedback_praise_reconciliation": "정확한 조정",
      "feedback_praise_lending": "명확한 대여/차용 관리",
      "feedback_praise_suggestions": "정확한 금액 제안",
      "feedback_praise_interface": "미니멀한 인터페이스",
      "feedback_praise_scanning": "똑똑한 영수증 스캔 ✨",
      "feedback_praise_alerts": "정확한 알림",
      "feedback_praise_leveling": "재미있는 레벨업",
      "feedback_criticism_sync": "동기화 오류",
      "feedback_criticism_balance": "잔액 불일치",
      "feedback_criticism_unlock": "잠금 해제가 너무 느림",
      "feedback_criticism_scanning": "영수증 스캔 오류",
      "feedback_criticism_amount": "금액 입력이 어려움",
      "feedback_criticism_categories": "카테고리 부족",
      "feedback_criticism_limits": "한도 수정이 어려움",
      "feedback_criticism_notifications": "알림 없음",
      "feedback_criticism_charts": "차트를 보기 어려움",
      "feedback_criticism_speed": "앱이 느림",
    },
    "guideline": {
      "banner_title_completed": "축하합니다! 모든 설정 단계가 완료되었습니다",
      "banner_title_in_progress": "도전: {remaining}개 남은 단계",
      "banner_desc_completed": "이제 규율적인 방식으로 재정을 관리할 수 있습니다.",
      "banner_desc_birth_year": "적절한 제안을 받으려면 출생 연도를 설정하세요",
      "banner_desc_categories": "지출 및 수입 카테고리 선택",
      "banner_desc_wallet_balance": "지갑의 현재 잔액 설정",
      "banner_desc_modify_cash": "현금 지갑의 금액 값 수정",
      "banner_desc_budget_limit": "각 카테고리에 지출 한도 설정",
      "banner_desc_min_living": "최소 월간 생활비 정의",
      "banner_desc_first_transaction": "첫 번째 지출 거래 기록",
      "banner_desc_investment": "부를 키우기 위해 첫 번째 투자 생성",
      "banner_desc_liability": "부채를 관리하기 위해 첫 번째 부채 기록",
      "banner_desc_lend": "대출을 관리하기 위해 첫 번째 대여 기록",
      "banner_desc_default": "재정을 관리할 준비가 되었습니다!",
      "success_dialog_message": "축하합니다!\n초기 설정을 완료했습니다.",
      "reset_confirm_desc": "{count}개 완료된 작업이 있습니다. 재설정하면 모든 진행 상태가 취소됩니다.",
      "reset_confirm_agree": "튜토리얼 보기",
      "reset_confirm_cancel": "취소",
    },
    "level_lock": {
      "unlock_at_lv": "LV{level}에서 잠금 해제",
      "unlock_free_at_lv3": "LV3에서 무료 잠금 해제",
      "remaining_percent": "{percent}% 남음",
      "investment_title": "투자 및 축적 추적",
      "investment_desc":
          "주식, 펀드, 부동산을 기록하고 앱에서 ROI를 직접 추적 — 지출 규율 챌린지 완료로 잠금 해제",
      "liability_title": "부채 및 대출 관리",
      "liability_desc": "부채, 이자율 및 전문 상환 일정 추적 — 더 높은 재정 규율이 달성될 때 잠금 해제",
      "task_setup_budget": "첫 번째 예산 설정",
      "task_record_transactions": "첫 5개 거래 기록",
      "task_setup_birth_year": "출생 연도 설정",
      "task_reconciliation_streak": "감사 규율 {current}/{total}주",
      "task_fixed_budgets": "고정 예산 {current}/{total}개 설정",
      "task_positive_cash_flow": "이번 달 양의 현금 흐름",
      "progress_archived": "{progress}% 경험 보관됨",
    },
  };
  static const Map<String, dynamic> _ja = {
    "app": {
      "name": "So Sach Xin",
      "version": "バージョン {version}",
      "description": "シンプルで効率的な個人財務管理",
      "slogan": "単式簿記の原則に従って収入、支出、投資、負債を管理し、財務的自由を目指します",
      "copyright": "© 2026 So Sach Xin · Made by",
      "copied_email": "メールをコピーしました: {email}",
      "author": "Tran Huy 作成",
      "role_tech": "技術",
      "role_hr": "HR",
      "author_hr_name": "Kien Nguyen",
      "author_hr_email": "kien.1000doanhnhan@gmail.com",
      "author_tech_name": "Huy Tran",
      "author_tech_email": "huytd46.fpt@gmail.com",
      "address": "Vinhome Grand Park, District 9",
      "loading": "読み込み中...",
      "error": {
        "general": "エラーが発生しました",
        "retry": "タップして再読み込み",
        "network": "ネットワークエラー。接続を確認してください。",
        "server": "サーバーエラー。後でもう一度お試しください。",
      },
      "app_check": {
        "initialization_failed": "App Checkの初期化に失敗しました。アプリを再起動してください。",
        "token_refresh_failed": "セキュリティトークンの更新に失敗しました。接続を確認してください。",
        "device_not_verified": "デバイスの認証に失敗しました。このデバイスはサポートされていない可能性があります。",
      },
    },
    "common": {
      "ok": "OK",
      "cancel": "キャンセル",
      "save": "保存",
      "delete": "削除",
      "edit": "編集",
      "back": "戻る",
      "continue": "続行",
      "next": "次へ",
      "skip": "スキップ",
      "done": "完了",
      "search": "検索",
      "no_results": "結果が見つかりません",
      "no_data": "データがありません",
      "or": "または",
      "not_set": "未設定",
      "sunday_short": "日",
      "select_date": "日付を選択",
      "income": "収入",
      "expense": "支出",
      "common_weekday_names": "月|火|水|木|金|土|日",
      "press_back_again_to_exit": "終了するにはもう一度戻るボタンを押してください",
      "add_source": "ソースを追加",
      "add": "追加",
      "copy": "コピー",
      "clear": "クリア",
      "unit_billion": "億",
      "unit_million": "百万",
      "unit_thousand": "千",
    },
    "auth": {
      "login": "ログイン",
      "logout": "ログアウト",
      "email": "メール",
      "password": "パスワード",
      "forgot_password": "パスワードをお忘れですか？",
      "signup": "新規登録",
      "no_account": "アカウントをお持ちでないですか？",
      "have_account": "すでにアカウントをお持ちですか？",
      "login_success": "ログイン成功",
      "login_failed": "ログインに失敗しました。認証情報を確認してください。",
      "login_google": "Googleでログイン",
      "login_apple": "Appleでログイン",
      "login_phone": "電話番号でログイン",
      "enter_phone_number": "電話番号で\nログイン",
      "phone_number": "電話番号",
      "phone_number_hint": "電話番号を入力",
      "phone_hint": "+1234567890",
      "verify": "確認",
      "send_code": "コードを送信",
      "enter_code": "SMSコードを入力",
      "we_just_sent_sms": "SMSを送信しました",
      "enter_security_code": "送信したセキュリティコードを入力してください",
      "didnt_receive_code": "コードを受け取りませんでしたか？",
      "resend": "後で再送信",
      "terms_and_privacy": "続行することで、利用規約とプライバシーポリシーに同意します",
      "biometric": {
        "reason": "認証が必要です",
        "fallback": "設定でこのアプリの生体認証を有効にしてください。",
        "not_available_log": "生体認証が利用できません",
        "init_error": "生体認証の初期化エラー: {error}",
        "error": {
          "not_available": "このデバイスでは生体認証が利用できません。",
          "not_enrolled": "このデバイスに登録された生体認証がありません。",
          "locked_out": "試行回数が多すぎます。後でもう一度お試しください。",
          "permanently_locked_out": "生体認証が永続的にロックされています。",
          "passcode_not_set": "デバイスにパスコードが設定されていません。",
          "user_canceled": "ユーザーが認証をキャンセルしました。",
          "app_canceled": "アプリが認証をキャンセルしました。",
          "system_canceled": "システムが認証をキャンセルしました。",
          "generic": "認証エラー: {error}",
        },
      },
      "otp": {
        "invalid": "無効なOTPコード",
        "expired": "OTPコードの有効期限が切れました",
        "too_many_attempts": "試行回数が多すぎます。後でもう一度お試しください",
      },
    },
    "validation": {
      "required": "このフィールドは必須です",
      "email": "有効なメールアドレスを入力してください",
      "password_length": "パスワードは最低{length}文字である必要があります",
      "password_match": "パスワードが一致しません",
      "phone": "無効な電話番号形式",
      "max_length_reached": "最大{count}文字に達しました",
    },
    "home": {
      "title": "ホーム",
      "welcome": "ようこそ、{name}さん！",
      "recent_activity": "最近のアクティビティ",
      "view_all": "すべて表示",
      "my_wallets": "マイウォレット",
    },
    "settings": {
      "title": "設定",
      "language": "言語",
      "language_vietnamese": "ベトナム語",
      "language_english": "英語",
      "language_korean": "韓国語",
      "language_japanese": "日本語",
      "language_chinese": "中国語",
      "theme": "テーマ",
      "theme_static": "固定",
      "theme_light": "ライトモード",
      "theme_dark": "ダークモード",
      "notifications": "通知",
      "privacy": "プライバシー",
      "help": "ヘルプとサポート",
      "about": "情報",
    },
    "nav": {
      "home": "ホーム",
      "transaction": "取引",
      "budget_allocation": "予算配分",
      "dashboard": "ダッシュボード",
      "quick_test": "クイックテスト",
      "quick_test_page": "クイックテストページ",
      "notification": "通知",
      "profile": "プロフィール",
      "profile_info": "個人情報",
    },
    "dashboard": {
      "item_count": "アイテム数",
      "last_updated": "最終更新",
      "refresh_data": "データを更新",
      "time": {
        "just_now": "たった今",
        "day": "{count}日前",
        "days": "{count}日前",
        "hour": "{count}時間前",
        "hours": "{count}時間前",
        "minute": "{count}分前",
        "minutes": "{count}分前",
      },
    },
    "wallet": {
      "my_account": "マイアカウント",
      "spending_account": "支出アカウント",
      "total_assets": "総資産",
      "your_wallets": "流動性ウォレット",
      "see_all": "すべて表示",
      "empty": "ウォレットがまだありません。\n+をタップして追加してください。",
      "investment_empty": "投資ウォレットがまだありません\n+をタップして追加",
      "investment_name": "投資名",
      "investment_name_hint": "例: BTC、Apple株...",
      "investment_delete_title": "投資を削除",
      "investment_delete_confirm":
          "総パフォーマンス価値が0の場合のみ投資アイテムを削除できます。関連する取引はソフト削除されます。続行しますか？",
      "investment_edit_title": "投資を編集",
      "add_title": "新しいウォレットを追加",
      "edit_title": "ウォレットを編集",
      "name": "ウォレット名",
      "name_hint": "例: Techcombank、tcb777、vcb789",
      "name_duplicate_error": "このウォレット名は既に存在します",
      "initial_balance": "開始残高",
      "initial_balance_hint": "例: 1000000",
      "balance_locked_hint":
          "ウォレットに取引がある場合、開始残高を変更できません\n調整を追跡するには新しいウォレットを作成してください",
      "balance_hidden": "*****",
      "save_info": "保存",
      "bank": "銀行",
      "cash": "現金",
      "ewallet": "電子ウォレット",
      "emergency_fund": "緊急資金",
      "emergency_fund_desc": "緊急時用 · 支出の3-6ヶ月分を目標に維持",
      "emergency_fund_locked_hint": "緊急資金ガイドを読んだ後、LV2で開きます",
      "emergency_fund_view_ebook": "ガイドを読む",
      "added_success": "新しいウォレットが追加されました",
      "updated_success": "ウォレットが更新されました",
      "delete_title": "ウォレットを削除",
      "delete_confirm_msg": "取引がないウォレットのみ削除できます。ウォレットのすべての取引がソフト削除されます。続行しますか？",
      "delete_error_not_empty": "削除できません: ウォレットに取引があります",
      "delete_error_protected": "このウォレットは必須であり削除できません",
      "liquid_assets": "流動資産",
      "liquid_assets_desc": "現金 + 銀行 + 電子ウォレット · 即座に使用可能",
      "investments": "投資 / 蓄積",
      "investments_desc": "株式、ファンド、不動産...",
      "liabilities": "負債",
      "liabilities_desc": "ローン + クレジットカード · 残高追跡、ストレス監視",
      "investment_roi": "ROI",
      "investment_breakeven": "損益分岐点",
    },
    "comment": {
      "detail": {
        "title": "コメント詳細",
        "content": "コメント内容",
        "post_id": "投稿ID",
        "id": "コメントID",
      },
    },
    "transaction": {
      "title": "取引",
      "wallet": "総ウォレット",
      "emergency": "緊急",
      "investment": "投資",
      "debt": "負債とローン",
      "category": "カテゴリ",
      "amount": "金額",
      "source_expense": "支出元",
      "reason_expense": "支出理由",
      "enter_content": "内容を入力",
      "payer": "支払者",
      "staff_name": "スタッフ名",
      "time": "時間",
      "history": "履歴",
      "record_expense": "支出を記録",
      "expense_saved": "{amount}の支出が正常に保存されました！",
      "income_saved": "{amount}の収入が正常に保存されました！",
      "expense_updated": "{amount}の支出が更新されました！",
      "income_updated": "{amount}の収入が更新されました！",
      "edit_title": "取引を編集",
      "delete_title": "取引を削除",
      "delete_confirm_desc": "この操作は取り消せません。",
      "liability_payment_saved": "{amount}の支払いが記録されました！",
      "source_income": "収入元",
      "reason_income": "収入理由",
      "recipient": "受取人",
      "record_income": "収入を記録",
      "source_investment": "投資元",
      "destination_investment": "受取ウォレット",
      "record_investment": "投資を記録",
      "investment_saved": "{amount}の投資が正常に保存されました！",
      "source_debt": "負債元",
      "record_debt": "負債を記録",
      "debt_saved": "{amount}の負債が正常に保存されました！",
      "liability_direction_borrow": "借り入れ",
      "liability_direction_lend": "貸付",
      "liability_name_label": "負債名",
      "liability_name_hint": "例: ノートPC購入、銀行ローン...",
      "record_liability": "負債を記録",
      "liability_amount_borrow_label": "借入金額",
      "liability_amount_lend_label": "貸付金額",
      "liability_wallet_borrow_label": "受取ウォレット",
      "liability_wallet_lend_label": "貸付ウォレット",
      "liability_saved": "{amount}の負債が記録されました！",
      "liability_name_duplicate_error": "この負債名は既に存在します",
      "liability_category_borrow_label": "ローンタイプ",
      "liability_category_lend_label": "貸付タイプ",
      "liability_borrower_label": "ローン名",
      "liability_borrower_hint": "例: 住宅購入ローン、友人へのローン...",
      "liability_collection_method_label": "回収方法",
      "liability_method_installment_lend": "分割払い",
      "liability_method_lump_sum_lend": "一括回収",
      "liability_schedule_lend_label": "回収スケジュール",
      "liability_reminder_once_label": "1日前に通知",
      "liability_reminder_recurring_label": "各支払期日の1日前に通知",
      "liability_counterparty_vip_locked":
          "無料プランはカテゴリのデフォルト名'{name}'を使用します。カスタム名を設定するにはVIPにアップグレードしてください。",
      "liability_repayment_method_label": "返済方法",
      "liability_method_installment": "分割払い",
      "liability_method_lump_sum": "満期一括払い",
      "liability_final_due_date_label": "支払期日",
      "liability_schedule_label": "分割スケジュール",
      "liability_add_period": "期間を追加",
      "record_repay": "返済",
      "record_collect": "回収",
      "investment_contribution": "出資",
      "investment_return": "回収",
      "dest_investment": "ウォレットに受取",
      "record_investment_return": "回収を記録",
      "investment_item": "投資アイテム",
      "add_new_investment_item": "新しいアイテム",
      "new_investment_item_hint": "アイテム名（例: カフェ）",
      "no_investment_items_hint": "このカテゴリにはまだ投資アイテムがありません — まず出資してください。",
      "investment_item_vip_locked":
          "無料プランはカテゴリのデフォルト名'{name}'を使用します。カスタム投資アイテム名を設定するにはVIPにアップグレードしてください。",
      "expense_slip": "支出",
      "income_slip": "収入",
      "category_sub": "サブカテゴリ",
      "today": "今日",
      "yesterday": "昨日",
      "note": "メモ",
      "note_hint": "メモ（オプション）",
      "more_details": "詳細を表示",
      "merchant_match_hint": "前回と同じ: {label}",
      "location_match_hint": "近くにいます: {label}",
      "bill_match_hint": "月次請求書: {label}",
      "monthly_income_match_hint": "月次収入: {label}",
      "auto_save_countdown": "{countdown}秒後に自動保存...",
      "quick_entry_hint": "現金で携帯電話50,000を支出",
      "quick_entry_parsed_result": "理解しました: {label}",
      "quick_entry_category_missing": "カテゴリが見つかりません（+が必要）: {label}",
      "quick_entry_could_not_parse": "理解できませんでした — 手動で入力してください",
      "quick_entry_daily_limit_reached": "本日のAI高速入力の上限に達しました — 手動で入力してください",
      "quick_entry_mic_permission_denied": "音声入力にはマイク権限が必要です",
      "quick_entry_photo_permission_denied": "レシートのスキャンにはカメラ/写真権限が必要です",
      "quick_entry_batch_label": "{count}取引 · {total}",
      "quick_entry_batch_failed": "レシート{indexes}を読み取れませんでした — 何も保存されませんでした",
      "quick_entry_batch_saved": "{count}取引保存済み · {total}",
      "quick_entry_batch_save_failed":
          "レシート{index}を保存できません: {reason} — 何も保存されませんでした",
      "quick_entry_batch_partial":
          "{saved}/{total}保存済み — レシート{index}失敗: {reason}",
      "quick_entry_scan_receipt": "レシートをスキャン",
      "quick_entry_take_photo": "写真を撮影",
      "quick_entry_choose_gallery": "ギャラリーから選択",
      "quick_entry_camera_not_available": "カメラ機能はまだ利用できません",
      "smart_entry_preview_title_one": "取引を確認",
      "smart_entry_preview_title_many": "{count}件の取引を確認",
      "smart_entry_preview_subtitle": "保存する前に確認・編集してください",
      "smart_entry_preview_confirm_one": "確定",
      "smart_entry_preview_confirm_many": "すべて確定（{count}）",
      "smart_entry_preview_apply_form": "フォームに反映",
      "smart_entry_preview_pick_category": "カテゴリを選択",
      "smart_entry_preview_pick_wallet": "ウォレットを選択",
      "smart_entry_preview_save_failed":
          "取引{index}を保存できませんでした: {reason} — 何も保存されませんでした",
      "smart_entry_preview_save_partial":
          "{saved}/{total}保存済み — 取引{index}失敗: {reason}",
      "smart_entry_preview_saved_one": "取引を保存しました",
      "smart_entry_preview_saved_many": "{count}件の取引を保存しました",
      "claims_in_progress": "{count}件のリクエストが進行中です",
      "validation": {
        "amount_required": "金額は0より大きくなければなりません",
        "wallet_required": "ウォレットを選択してください",
        "category_required": "カテゴリを選択してください",
        "future_date": "将来の取引を記録できません",
        "insufficient_balance": "ウォレット残高が不足しています",
        "counterparty_required": "ローン相手を入力してください",
        "schedule_required": "返済スケジュールを入力してください",
        "amount_exceeds_outstanding": "金額が残りの残高を超えています",
        "liability_settled": "この負債はすでに決済されています",
        "not_editable": "この取引は編集できません",
        "edit_window": "過去30日以内の取引のみ編集できます",
      },
      "transfer_money": "送金",
      "transfer_from": "送金元ウォレット",
      "transfer_to": "送金先ウォレット",
      "transfer_swap": "ウォレットを入れ替え",
      "transfer_saved": "送金を保存しました",
    },
    "liability": {
      "title": "負債",
      "list_title": "負債",
      "status_outstanding": "未決済",
      "status_settled": "決済済み",
      "remaining_balance": "残額",
      "principal_amount": "元金",
      "empty_state": "まだ負債がありません",
      "empty_state_v2": "まだ負債/貸付がありません\n+をタップして追加してください。",
      "history_title": "取引履歴",
      "no_history": "まだ返済/回収履歴がありません",
      "delete_title": "負債を削除",
      "delete_confirm_msg": "この負債を削除しますか？この操作は取り消せません。",
      "borrow": "借り入れ",
      "lend": "貸付",
      "borrow_type_personal": "個人",
      "lend_type_personal": "個人",
      "repaid_prefix": "返済済み: ",
      "borrow_prefix": "借り入れ: ",
      "received": "受取済み",
      "to_collect": "回収",
      "total_lend": "総貸付",
    },
    "notification": {
      "channel_name": "通知",
      "channel_description": "監査通知、クラウド登録、ローン支払期日の通知",
      "audit_approaching_title": "監査日が近づいています",
      "audit_approaching_body": "明日は毎週の監査日です。残高を調整することを忘れないでください！",
      "audit_due_title": "監査日です",
      "audit_due_body": "今日は毎週の監査日です。今すぐ残高を調整してください！",
      "cloud_backup_title": "データを保護",
      "cloud_backup_body": "アカウントを登録してデータをクラウドにバックアップし、損失を防いでください。",
      "loan_due_title": "ローン支払期日が近づいています",
      "loan_due_body": "ローン'{name}'の支払期日は{date}です。",
      "budget_near_limit_body": "予算\"{name}\"が80%に達しました。",
      "budget_over_body": "予算\"{name}\"が上限を超えました。",
    },
    "tutorial": {
      "nav_title": "ナビゲーションバー",
      "nav_desc": "Phân 割り当てはウォレットと予算を表示し、Giao dịchは取引を記録し、Hồ sơはプロフィールと設定です。",
      "transaction_title": "取引を記録",
      "transaction_desc":
          "ここでChi tiêu/Thu nhập/Đầu tư/Vay-Nợを選択し、金額を入力して保存してください。",
    },
    "budget": {
      "title": "予算",
      "description": "上限は月次カテゴリに許可する最大金額です — 超過すると計画より多く支出することを意味します。",
      "empty": "まだ予算がありません。\n+をタップして支出上限を追加してください。",
      "edit_limit": "上限を編集",
      "edit_title": "予算を編集",
      "limit_locked": "上限は月の最初の7日間のみ変更できます。",
      "delete_title": "予算を削除",
      "delete_confirm": "\"{name}\"を削除しますか？",
      "reset_period": "期間をリセット",
      "reset_title": "予算をリセット",
      "add_title": "予算を追加",
      "name": "予算名",
      "name_hint": "例: A棟の電気",
      "name_duplicate_error": "予算名は既に存在します",
      "category": "カテゴリ",
      "limit": "上限",
      "limit_hint": "例: 1000000",
      "start_date": "開始",
      "end_date": "終了",
      "added": "予算\"{name}\"が追加されました",
      "updated": "予算\"{name}\"が更新されました",
      "period_started": "\"{name}\"の新しい期間が開始されました",
      "over_limit": "上限を超えました！",
      "near_limit": "上限に近づいています！",
      "over_limit_count": "今月\"{name}\"の上限を{count}回超えました！",
      "over_by": "{amount}超過",
      "remaining": "{amount}残り",
      "this_month": "今月の予算",
      "month_indicator": "{month}",
      "see_all": "すべて表示",
      "drag_reorder_hint": "長押ししてドラッグして並べ替え",
      "customize_category": "カテゴリをカスタマイズ",
      "percent_used": "{percent}%使用済み",
      "spent_prefix": "支出済み",
      "limit_prefix": "上限",
      "fixed_price": "固定価格",
      "fixed_price_description": "固定月次費用（最低生存費）、レポートセクションの安全指数に影響します。",
      "pacing_hint": "{name}: {days}日残り · 提案 ≤{amount}/日",
      "penalty_warning": "{name}が{percent}%超過しました！",
      "deficit_warning": "今月収入より多く支出しています（赤字{amount}）",
      "debt_inflow_warning": "今月の流入の{percent}%（{amount}）が収入ではなく負債から来ています",
      "debt_outflow_warning": "今月の流出の{percent}%（{amount}）が支出ではなく貸付または返済です",
      "anomaly_hint": "過去3ヶ月の平均と比較して{count}件の異常な支出",
      "insights_title": "インサイトと警告",
      "insights_action_review": "レポートを表示",
      "estimate_hint": "提案: {amount}（過去3ヶ月の平均）",
    },
    "reconciliation": {
      "title": "調整",
      "empty": "調整するウォレットがありません。",
      "instruction": "各ウォレットの実際のカウント残高を入力してください:",
      "book_total": "帳簿合計",
      "actual_total": "実際の合計",
      "difference": "差額",
      "balanced": "均衡 ✓",
      "surplus": "黒字 {amount}",
      "deficit": "赤字 {amount}",
      "confirm": "調整を確認",
      "success": "調整が確認されました",
      "success_message": "おめでとうございます！調整#{count}を正常に完了しました。",
      "history": "調整履歴",
      "undo": "元に戻す",
      "undo_title": "調整を元に戻す",
      "undo_confirm": "最新の調整を元に戻し、調整エントリを削除しますか？",
      "week": "{week}/{year}週",
      "book": "帳簿",
      "actual": "実際",
      "book_balance": "帳簿: {amount}",
      "cycle_subtitle": "今週 · 日曜日期限",
      "description_line_1": "調整は実際の残高をアプリと一致させ、すべての財務記録が常に正確で透明であることを保証します。",
      "description_line_2":
          "見落とした取引を確認する必要なく、実際と一致するように帳簿残高を調整する調整エントリを自動的に生成します。",
      "mismatch_warning": "{count}個のウォレットが一致しません。確認する前に処理してください",
      "create_adjustment": "調整を作成",
      "matched": "一致",
      "lech": "{amount}の差",
      "review_transactions": "取引を確認",
    },
    "report": {
      "title": "レポート",
      "spending_proportion": "支出分布",
      "monthly_chart": "収入と支出",
      "this_week": "今週",
      "four_weeks_near": "過去4週間",
      "this_month": "今月",
      "no_expense": "この期間に支出がありません。 \n支出/収入を記録し、必要に応じて更新してください",
      "weekly": "週次",
      "monthly": "月次",
      "yearly": "年次",
      "three_months": "3ヶ月",
      "income_expense": "収入と支出",
      "safety_index": "安全指数（ランウェイ）",
      "runway_desc_2":
          "ランウェイは収入なしで生存できる期間を示し、月次収入・支出チャートを通じて蓄積を確認し、より持続可能な財務計画に調整するのに役立ちます。",
      "runway_message": "{months}ヶ月{days}日間維持できます",
      "runway_fixed_price_desc": "真剣な財務管理ライフスタイル",
      "runway_no_fixed_price_desc":
          "ランウェイは実際の支出を使用します。より正確な推定のために固定費用を設定してください。",
      "runway_perfect": "支出は素晴らしいです！",
      "runway_very_good": "素晴らしいです！1年以上のバッファがあります",
      "runway_good": "非常に良いです！安全指数はかなり高いです",
      "runway_safe": "安全です！最低3ヶ月のバッファがあります",
      "runway_caution": "注意！より多くのバッファを構築する必要があります",
      "runway_insufficient": "システムが安全指数を計算できるように支出の記録を開始してください。",
      "runway_not_available": "データ不足",
      "investment_title": "投資",
      "investment_contributed": "出資",
      "investment_returned": "回収",
      "liability_title": "負債",
      "liability_in": "借り入れ",
      "liability_out": "貸付",
      "daily_detail": "日次詳細",
      "income_short": "収入",
      "expense_short": "支出",
      "uncategorized": "未分類",
      "filtering_wallet": "フィルタリング: {wallet}",
      "filter_by_wallet": "ウォレットでフィルタ",
      "filter_all_wallets": "すべてのウォレット",
      "filter_by_type": "タイプでフィルタ",
      "filter_all_types": "すべてのタイプ",
      "trend_week_label": "{number}週",
      "ai_advice_title": "AI財務アドバイス",
      "ai_advice_empty_body": "今月の支出の個別化されたレビューと財務改善の提案を受け取ってください。",
      "ai_advice_generate_cta": "アドバイスを生成",
      "ai_advice_loading": "アドバイスを生成中...",
      "ai_advice_generate_failed": "今すぐアドバイスを生成できません。後でもう一度お試しください。",
      "ai_advice_daily_limit_reached": "本日のAIアドバイスの上限に達しました。明日お試しください。",
      "ai_advice_gemini_disabled": "プロフィール設定でGemini AIがオフになっています。",
      "ai_advice_generated_just_now": "たった今生成されました",
      "ai_advice_generated_minutes_ago": "{count}分前に生成されました",
      "ai_advice_generated_hours_ago": "{count}時間前に生成されました",
      "ai_advice_generated_days_ago": "{count}日前に生成されました",
    },
    "category": {
      "settings_title": "カテゴリ設定",
      "settings_subtitle": "カスタムカテゴリとグループを管理",
      "group_daily": "日常",
      "group_personal": "個人",
      "group_food_drink": "食事とコーヒー",
      "group_transport": "交通",
      "group_utilities": "ユーティリティ",
      "group_housing": "住宅",
      "group_health": "医療と健康",
      "group_education": "教育",
      "group_entertainment": "エンターテインメント",
      "group_shopping": "ショッピング",
      "group_insurance": "保険",
      "group_gifts": "ギフトと寄付",
      "group_personal_care": "パーソナルケア",
      "group_service_fees": "サービス料金",
      "group_family": "家族と子供",
      "food": "食品",
      "transport": "交通",
      "shopping": "ショッピング",
      "health": "健康",
      "food_drink": "食事とコーヒー",
      "coffee": "コーヒー",
      "water": "水",
      "eat_out": "外食",
      "taxi": "タクシー",
      "gas": "ガソリン",
      "parking": "駐車",
      "maintenance": "メンテナンス",
      "electricity": "電気",
      "internet": "インターネット",
      "phone": "電話",
      "rent": "家賃",
      "furniture": "家具",
      "laundry": "ランドリー",
      "mortgage": "住宅ローン",
      "condo_fee": "コンドミニアム費",
      "doctor": "医師",
      "medicine": "薬",
      "health_insurance": "健康保険",
      "gym": "ジム",
      "tuition": "授業料",
      "books": "本",
      "courses": "コース",
      "cinema": "映画館",
      "travel": "旅行",
      "gaming": "ゲーム",
      "events": "イベント",
      "appliances": "家電",
      "electronics": "電子機器",
      "clothing": "衣類",
      "cosmetics": "化粧品",
      "installment": "分割払い",
      "life_insurance": "生命保険",
      "vehicle_insurance": "車両保険",
      "home_insurance": "住宅保険",
      "gifts": "ギフト",
      "charity": "寄付",
      "haircut": "散髪",
      "spa": "スパ",
      "personal_care_product": "パーソナルケア用品",
      "bank_fee": "銀行手数料",
      "card_fee": "カード年会費",
      "milk_formula": "粉ミルク",
      "diapers": "おむつ",
      "baby_toys": "赤ちゃんのおもちゃ",
      "income_settings_title": "収入カテゴリ",
      "income_group_active": "アクティブ収入",
      "income_group_invest": "投資収入",
      "income_group_other": "その他の収入",
      "income_salary": "基本給",
      "income_freelance": "フリーランス",
      "income_allowance": "お小遣い",
      "income_savings_interest": "貯金利息",
      "income_dividends": "配当金",
      "income_rental": "資産賃貸料",
      "income_bonus": "ボーナス",
      "income_gift": "ギフト/プレゼント",
      "income_cashback": "キャッシュバック",
      "debt_loan_settings_title": "負債とローンカテゴリ",
      "debt_group_borrow": "借り入れ",
      "debt_group_lend": "貸付",
      "debt_personal_borrow": "個人ローン（友人）",
      "debt_bank_borrow": "銀行/金融ローン",
      "debt_mortgage": "住宅ローン",
      "debt_credit_card": "クレジットカード債務",
      "debt_installment": "分割払い",
      "debt_personal_lend": "個人貸付",
      "debt_other": "その他",
      "debt_other_lend": "その他",
      "investment_bond": "債券",
      "investment_business": "ビジネス",
      "investment_crypto": "暗号資産",
      "investment_fund": "ファンド",
      "investment_gold": "金",
      "investment_group_default": "投資",
      "investment_linked_insurance": "投資型保険",
      "investment_other": "その他",
      "investment_real_estate": "不動産",
      "investment_settings_title": "投資カテゴリ",
      "investment_stock": "株式",
      "investment_term_deposit": "定期預金",
      "market_supermarket": "市場とスーパーマーケット",
      "religious": "宗教/精神性",
      "leisure": "余暇と旅行",
      "expense_settings_title": "支出カテゴリ",
    },
    "sync": {
      "offline_tooltip": "オフライン — データは再接続するまでこのデバイスにのみ保存されます",
      "syncing_tooltip": "同期中 — データをクラウドにバックアップ中…",
      "pending_tooltip": "{count}個のアイテムがまだクラウドにバックアップされていません — タップして同期",
      "synced_tooltip": "すべてのデータがクラウドにバックアップされました",
      "logout_blocked_offline": "ログアウトする前にインターネットに接続してください",
      "logout_blocked_pending": "まだ同期されていないデータがあります。ログアウトする前に再接続して同期してください。",
      "discard_title": "同期されていないデータを破棄しますか？",
      "discard_message": "一部のデータをバックアップできず、このデバイスから永続的に削除されます。この操作は取り消せません。",
      "discard_confirm": "破棄",
      "discard_done": "同期されていないデータが破棄されました",
    },
    "profile": {
      "guest": "ゲスト",
      "not_logged_in": "ログインしていません",
      "register_login": "登録 / ログイン",
      "display_name_title": "名前を編集",
      "display_name_hint": "表示名を入力",
      "display_name_save": "保存",
      "display_name_updated": "名前が更新されました",
      "link_account_title": "アカウントをリンク",
      "link_account_subtitle": "電話番号またはGoogleでログイン",
      "link_account_google": "Google",
      "link_account_phone": "電話番号",
      "link_account_linked": "リンク済み",
      "link_account_action": "リンク",
      "link_account_success": "正常にリンクされました",
      "link_account_phone_hint": "電話番号を入力",
      "link_account_send_code": "コードを送信",
      "link_account_verify_code": "確認",
      "birth_year": "生年",
      "birth_year_subtitle": "適切なカテゴリを提案するために使用",
      "birth_year_hint": "実際の生年を選択してください。日次収入および支出計算に影響します",
      "birth_year_task_desc": "タスク: 生年を設定",
      "weekly_audit": "週次監査",
      "days_left": "{count}日残り",
      "debt_loan": "負債 / ローン",
      "unlock_at_lv": "LV{level}で開く",
      "unlocked": "ロック解除済み",
      "vip": "VIP",
      "vip_subtitle": "投資アイテム / ローン記録の無料階層制限を解除します（ローカルトグル、実際の支払いなし）",
      "force_full_access": "すべての機能をロック解除",
      "force_full_access_subtitle":
          "デバッグ/QAオーバーライド — 実際の進行状況に関係なく、投資 + 負債/ローン(LV3)を即座にロック解除",
      "gemini_ai": "Gemini AI機能",
      "gemini_ai_subtitle":
          "デバッグ/QA — オン: テキスト、音声、レシートエントリがGeminiによって最初に解析されます（ローカルフォールバック）。オフ: Geminiには何も送信されず、ローカル解析のみ実行",
      "weekly_audit_day": "週次監査日",
      "weekly_audit_day_subtitle": "週次残高を確認する日",
      "weekly_audit_day_hint": "週次監査日を選択してください。通常、支出サイクルの終わり",
      "audit_shortcut": "監査",
      "reminder": "通知",
      "reminder_subtitle": "調整記録の通知を受信",
      "theme_subtitle": "ライトモードとダークモードの切り替え",
      "language_subtitle": "希望する言語を選択",
      "currency": "通貨単位",
      "currency_subtitle": "主な通貨単位を変更",
      "currency_dong": "ドン",
      "currency_vnd": "ベトナムドン",
      "currency_usd": "米ドル",
      "currency_eur": "ユーロ",
      "currency_jpy": "日本円",
      "currency_krw": "韓国ウォン",
      "currency_cny": "中国元",
      "view_tutorial": "チュートリアルをもう一度見る",
      "view_tutorial_subtitle": "アプリを効果的に使用する方法を学ぶ",
      "terms": "利用規約",
      "terms_subtitle": "サービス規約とプライバシーポリシーを読む",
      "about": "アプリについて",
      "about_subtitle": "アプリ情報と開発者ログ",
      "delete_account": "アカウントを削除",
      "delete_confirm": "アカウントを削除しますか？",
      "delete_confirm_desc": "アカウントとすべての関連データが永続的に削除されます。この操作は取り消せません。",
      "young_children_message": "幼児がいますか？はいの場合、ミルク、おむつ、おもちゃ関連のカテゴリを自動的に有効にします。",
      "experience_level_progress": "経験レベルの進行",
      "level_title": "レベル{level}（{title}）",
      "tap_to_return": "タップしてプロフィールに戻る",
      "streak_weeks": "連続: {count}週",
      "level_master": "マスター",
      "level_intermediate": "中級",
      "level_novice": "初級",
      "progress_steps": "進行ステップ",
      "reconciliation_streak_title": "{count}週連続",
      "reconciliation_streak_desc": "監査日: {day}",
      "rate_app": "アプリを評価",
      "rate_app_subtitle": "So Sach Xinの改善にご協力ください",
      "customer_reviews": "カスタマーレビュー",
      "customer_ratings_count": "{count}件のカスタマー評価",
      "calculate_ratings_info": "評価の計算方法について",
      "out_of_5": "5段階中{rating}",
      "star_count": "{count}つ星",
      "feedback_hint": "詳しく教えてください（任意）",
      "feedback_send": "フィードバックを送信",
      "feedback_required": "タグを選択するか内容を入力してください",
      "feedback_sent": "フィードバックありがとうございます",
      "feedback_praise_fast": "入力が速い",
      "feedback_praise_offline": "オフラインでも快適",
      "feedback_praise_runway": "正確なランウェイ計算",
      "feedback_praise_reconciliation": "正確な調整",
      "feedback_praise_lending": "貸し借りが明確",
      "feedback_praise_suggestions": "正確な金額提案",
      "feedback_praise_interface": "ミニマルな画面",
      "feedback_praise_scanning": "高精度なレシートスキャン ✨",
      "feedback_praise_alerts": "正確な通知",
      "feedback_praise_leveling": "楽しいレベルアップ",
      "feedback_criticism_sync": "同期エラー",
      "feedback_criticism_balance": "残高が一致しない",
      "feedback_criticism_unlock": "解除に時間がかかる",
      "feedback_criticism_scanning": "レシートの読み取りが不正確",
      "feedback_criticism_amount": "金額入力が難しい",
      "feedback_criticism_categories": "カテゴリが足りない",
      "feedback_criticism_limits": "上限の編集が難しい",
      "feedback_criticism_notifications": "通知がない",
      "feedback_criticism_charts": "グラフが見づらい",
      "feedback_criticism_speed": "アプリが遅い",
    },
    "guideline": {
      "banner_title_completed": "おめでとうございます！すべての設定ステップが完了しました",
      "banner_title_in_progress": "チャレンジ: {remaining}個の残りのステップ",
      "banner_desc_completed": "これから規律ある方法で財政を管理できます。",
      "banner_desc_birth_year": "適切な提案を受けるには生年を設定してください",
      "banner_desc_categories": "支出および収入カテゴリを選択",
      "banner_desc_wallet_balance": "ウォレットの現在の残高を設定",
      "banner_desc_modify_cash": "現金ウォレットの金額を変更",
      "banner_desc_budget_limit": "各カテゴリに支出上限を設定",
      "banner_desc_min_living": "最低月次生活費を定義",
      "banner_desc_first_transaction": "最初の支出取引を記録",
      "banner_desc_investment": "富を増やすために最初の投資を作成",
      "banner_desc_liability": "負債を管理するために最初の負債を記録",
      "banner_desc_lend": "ローンを管理するために最初の貸付を記録",
      "banner_desc_default": "財政を管理する準備ができました！",
      "success_dialog_message": "おめでとうございます！\n初期設定を完了しました。",
      "reset_confirm_desc": "{count}個の完了したタスクがあります。リセットするとすべての進行状況が取り消されます。",
      "reset_confirm_agree": "チュートリアルを見る",
      "reset_confirm_cancel": "キャンセル",
    },
    "level_lock": {
      "unlock_at_lv": "LV{level}でロック解除",
      "unlock_free_at_lv3": "LV3で無料ロック解除",
      "remaining_percent": "{percent}%残り",
      "investment_title": "投資と蓄積の追跡",
      "investment_desc": "株式、ファンド、不動産を記録し、アプリでROIを直接追跡 — 支出規律チャレンジ完了でロック解除",
      "liability_title": "負債とローン管理",
      "liability_desc": "負債、金利、プロフェッショナルな返済スケジュールを追跡 — より高い財政規律が達成されたときにロック解除",
      "task_setup_budget": "最初の予算を設定",
      "task_record_transactions": "最初の5つの取引を記録",
      "task_setup_birth_year": "生年を設定",
      "task_reconciliation_streak": "監査規律{current}/{total}週",
      "task_fixed_budgets": "固定予算{current}/{total}個を設定",
      "task_positive_cash_flow": "今月プラスのキャッシュフロー",
      "progress_archived": "{progress}%経験がアーカイブされました",
    },
  };
  static const Map<String, dynamic> _zh = {
    "app": {
      "name": "So Sach Xin",
      "version": "版本 {version}",
      "description": "精简高效的个人财务管理",
      "slogan": "按照单式记账原则管理收入、支出、投资、债务，迈向财务自由",
      "copyright": "© 2026 So Sach Xin · Made by",
      "copied_email": "已复制邮箱: {email}",
      "author": "Tran Huy 制作",
      "role_tech": "技术",
      "role_hr": "HR",
      "author_hr_name": "Kien Nguyen",
      "author_hr_email": "kien.1000doanhnhan@gmail.com",
      "author_tech_name": "Huy Tran",
      "author_tech_email": "huytd46.fpt@gmail.com",
      "address": "Vinhome Grand Park, District 9",
      "loading": "加载中...",
      "error": {
        "general": "发生错误",
        "retry": "点击此处重新加载",
        "network": "网络错误。请检查您的连接。",
        "server": "服务器错误。请稍后再试。",
      },
      "app_check": {
        "initialization_failed": "App Check 初始化失败。请重新启动应用程序。",
        "token_refresh_failed": "无法刷新安全令牌。请检查您的连接。",
        "device_not_verified": "设备验证失败。此设备可能不受支持。",
      },
    },
    "common": {
      "ok": "确定",
      "cancel": "取消",
      "save": "保存",
      "delete": "删除",
      "edit": "编辑",
      "back": "返回",
      "continue": "继续",
      "next": "下一步",
      "skip": "跳过",
      "done": "完成",
      "search": "搜索",
      "no_results": "未找到结果",
      "no_data": "无数据",
      "or": "或",
      "not_set": "未设置",
      "sunday_short": "日",
      "select_date": "选择日期",
      "income": "收入",
      "expense": "支出",
      "common_weekday_names": "周一|周二|周三|周四|周五|周六|周日",
      "press_back_again_to_exit": "再次按返回键退出",
      "add_source": "添加来源",
      "add": "添加",
      "copy": "复制",
      "clear": "清除",
      "unit_billion": "十亿",
      "unit_million": "百万",
      "unit_thousand": "千",
    },
    "auth": {
      "login": "登录",
      "logout": "退出",
      "email": "邮箱",
      "password": "密码",
      "forgot_password": "忘记密码？",
      "signup": "注册",
      "no_account": "没有账户？",
      "have_account": "已有账户？",
      "login_success": "登录成功",
      "login_failed": "登录失败。请检查您的凭据。",
      "login_google": "使用 Google 登录",
      "login_apple": "使用 Apple 登录",
      "login_phone": "使用手机号码登录",
      "enter_phone_number": "使用手机号码\n登录",
      "phone_number": "手机号码",
      "phone_number_hint": "输入手机号码",
      "phone_hint": "+1234567890",
      "verify": "验证",
      "send_code": "发送代码",
      "enter_code": "输入短信代码",
      "we_just_sent_sms": "我们刚刚发送了一条短信",
      "enter_security_code": "输入我们发送给您的安全代码",
      "didnt_receive_code": "没有收到代码？",
      "resend": "后重发",
      "terms_and_privacy": "继续即表示您同意我们的服务条款和隐私政策",
      "biometric": {
        "reason": "需要身份验证",
        "fallback": "请在设置中为此应用启用生物识别。",
        "not_available_log": "生物识别不可用",
        "init_error": "生物识别初始化错误: {error}",
        "error": {
          "not_available": "此设备上不可用生物识别。",
          "not_enrolled": "此设备上未注册生物识别。",
          "locked_out": "尝试次数过多。请稍后再试。",
          "permanently_locked_out": "生物识别已被永久锁定。",
          "passcode_not_set": "设备上未设置密码。",
          "user_canceled": "用户取消了身份验证。",
          "app_canceled": "应用程序取消了身份验证。",
          "system_canceled": "系统取消了身份验证。",
          "generic": "身份验证错误: {error}",
        },
      },
      "otp": {
        "invalid": "无效的 OTP 代码",
        "expired": "OTP 代码已过期",
        "too_many_attempts": "尝试次数过多。请稍后再试",
      },
    },
    "validation": {
      "required": "此字段为必填项",
      "email": "请输入有效的邮箱",
      "password_length": "密码必须至少 {length} 个字符",
      "password_match": "密码不匹配",
      "phone": "无效的手机号码格式",
      "max_length_reached": "已达到最大 {count} 个字符",
    },
    "home": {
      "title": "首页",
      "welcome": "欢迎，{name}！",
      "recent_activity": "最近活动",
      "view_all": "查看全部",
      "my_wallets": "我的钱包",
    },
    "settings": {
      "title": "设置",
      "language": "语言",
      "language_vietnamese": "越南语",
      "language_english": "英语",
      "language_korean": "韩语",
      "language_japanese": "日语",
      "language_chinese": "中文",
      "theme": "主题",
      "theme_static": "静态",
      "theme_light": "浅色模式",
      "theme_dark": "深色模式",
      "notifications": "通知",
      "privacy": "隐私",
      "help": "帮助与支持",
      "about": "关于",
    },
    "nav": {
      "home": "首页",
      "transaction": "交易",
      "budget_allocation": "预算分配",
      "dashboard": "仪表板",
      "quick_test": "快速测试",
      "quick_test_page": "快速测试页面",
      "notification": "通知",
      "profile": "个人资料",
      "profile_info": "个人信息",
    },
    "dashboard": {
      "item_count": "项目数量",
      "last_updated": "最后更新",
      "refresh_data": "刷新数据",
      "time": {
        "just_now": "刚刚",
        "day": "{count}天前",
        "days": "{count}天前",
        "hour": "{count}小时前",
        "hours": "{count}小时前",
        "minute": "{count}分钟前",
        "minutes": "{count}分钟前",
      },
    },
    "wallet": {
      "my_account": "我的账户",
      "spending_account": "支出账户",
      "total_assets": "总资产",
      "your_wallets": "流动钱包",
      "see_all": "查看全部",
      "empty": "还没有钱包。\n点击 + 添加一个。",
      "investment_empty": "还没有投资钱包\n点击 + 添加",
      "investment_name": "投资名称",
      "investment_name_hint": "例如: BTC、Apple 股票...",
      "investment_delete_title": "删除投资",
      "investment_delete_confirm": "只有当总绩效价值为 0 时才能删除投资项目。所有相关交易将被软删除。继续吗？",
      "investment_edit_title": "编辑投资",
      "add_title": "添加新钱包",
      "edit_title": "编辑钱包",
      "name": "钱包名称",
      "name_hint": "例如: Techcombank、tcb777、vcb789",
      "name_duplicate_error": "此钱包名称已存在",
      "initial_balance": "期初余额",
      "initial_balance_hint": "例如: 1000000",
      "balance_locked_hint": "钱包有交易后无法更改期初余额\n考虑创建新钱包来跟踪调整",
      "balance_hidden": "*****",
      "save_info": "保存",
      "bank": "银行",
      "cash": "现金",
      "ewallet": "电子钱包",
      "emergency_fund": "应急基金",
      "emergency_fund_desc": "应急用途 · 目标保持 3-6 个月的支出",
      "emergency_fund_locked_hint": "在 LV2 打开，阅读应急基金指南后",
      "emergency_fund_view_ebook": "阅读指南",
      "added_success": "已添加新钱包",
      "updated_success": "钱包已更新",
      "delete_title": "删除钱包",
      "delete_confirm_msg": "只有没有交易的钱包才能删除。钱包的所有交易将被软删除。继续吗？",
      "delete_error_not_empty": "无法删除: 钱包有交易",
      "delete_error_protected": "此钱包是必需的，无法删除",
      "liquid_assets": "流动资产",
      "liquid_assets_desc": "现金 + 银行 + 电子钱包 · 随时可花费",
      "investments": "投资 / 积累",
      "investments_desc": "股票、基金、房地产...",
      "liabilities": "负债",
      "liabilities_desc": "贷款 + 信用卡 · 余额跟踪、压力监控",
      "investment_roi": "ROI",
      "investment_breakeven": "盈亏平衡点",
    },
    "comment": {
      "detail": {
        "title": "评论详情",
        "content": "评论内容",
        "post_id": "帖子 ID",
        "id": "评论 ID",
      },
    },
    "transaction": {
      "title": "交易",
      "wallet": "总钱包",
      "emergency": "应急",
      "investment": "投资",
      "debt": "债务与贷款",
      "category": "类别",
      "amount": "金额",
      "source_expense": "支出来源",
      "reason_expense": "支出原因",
      "enter_content": "输入内容",
      "payer": "付款人",
      "staff_name": "员工姓名",
      "time": "时间",
      "history": "历史",
      "record_expense": "记录支出",
      "expense_saved": "{amount} 支出已成功保存！",
      "income_saved": "{amount} 收入已成功保存！",
      "expense_updated": "{amount} 支出已更新！",
      "income_updated": "{amount} 收入已更新！",
      "edit_title": "编辑交易",
      "delete_title": "删除交易",
      "delete_confirm_desc": "此操作无法撤销。",
      "liability_payment_saved": "已记录 {amount} 的付款！",
      "source_income": "收入来源",
      "reason_income": "收入原因",
      "recipient": "收款人",
      "record_income": "记录收入",
      "source_investment": "投资来源",
      "destination_investment": "接收钱包",
      "record_investment": "记录投资",
      "investment_saved": "{amount} 投资已成功保存！",
      "source_debt": "债务来源",
      "record_debt": "记录债务",
      "debt_saved": "{amount} 债务已成功保存！",
      "liability_direction_borrow": "借入",
      "liability_direction_lend": "借出",
      "liability_name_label": "债务名称",
      "liability_name_hint": "例如: 购买笔记本电脑、银行贷款...",
      "record_liability": "记录债务",
      "liability_amount_borrow_label": "借款金额",
      "liability_amount_lend_label": "借出金额",
      "liability_wallet_borrow_label": "接收钱包",
      "liability_wallet_lend_label": "借出钱包",
      "liability_saved": "已记录 {amount} 的债务！",
      "liability_name_duplicate_error": "此债务名称已存在",
      "liability_category_borrow_label": "贷款类型",
      "liability_category_lend_label": "借出类型",
      "liability_borrower_label": "贷款名称",
      "liability_borrower_hint": "例如: 购房贷款、向朋友贷款...",
      "liability_collection_method_label": "收款方式",
      "liability_method_installment_lend": "分期",
      "liability_method_lump_sum_lend": "一次性收款",
      "liability_schedule_lend_label": "收款计划",
      "liability_reminder_once_label": "提前 1 天提醒",
      "liability_reminder_recurring_label": "每个还款日前 1 天提醒",
      "liability_counterparty_vip_locked":
          "免费计划使用类别的默认名称 '{name}'。升级 VIP 以设置自定义名称。",
      "liability_repayment_method_label": "还款方式",
      "liability_method_installment": "分期",
      "liability_method_lump_sum": "到期一次性还款",
      "liability_final_due_date_label": "到期日",
      "liability_schedule_label": "分期计划",
      "liability_add_period": "添加期数",
      "record_repay": "还款",
      "record_collect": "收款",
      "investment_contribution": "出资",
      "investment_return": "回收",
      "dest_investment": "收款到钱包",
      "record_investment_return": "记录回收",
      "investment_item": "投资项目",
      "add_new_investment_item": "新项目",
      "new_investment_item_hint": "项目名称（例如: 咖啡店）",
      "no_investment_items_hint": "此类别中还没有投资项目 — 先出资。",
      "investment_item_vip_locked":
          "免费计划使用类别的默认名称 '{name}'。升级 VIP 以设置自定义投资项目名称。",
      "expense_slip": "支出",
      "income_slip": "收入",
      "category_sub": "子类别",
      "today": "今天",
      "yesterday": "昨天",
      "note": "备注",
      "note_hint": "备注（可选）",
      "more_details": "更多详情",
      "merchant_match_hint": "和上次一样: {label}",
      "location_match_hint": "您在附近: {label}",
      "bill_match_hint": "月度账单: {label}",
      "monthly_income_match_hint": "月度收入: {label}",
      "auto_save_countdown": "{countdown}秒后自动保存...",
      "quick_entry_hint": "现金支付手机 50,000",
      "quick_entry_parsed_result": "已理解: {label}",
      "quick_entry_category_missing": "未找到类别（需要 +）: {label}",
      "quick_entry_could_not_parse": "无法理解 — 请手动填写",
      "quick_entry_daily_limit_reached": "今日 AI 快速输入上限已达到 — 请手动输入",
      "quick_entry_mic_permission_denied": "语音输入需要麦克风权限",
      "quick_entry_photo_permission_denied": "扫描收据需要相机/照片权限",
      "quick_entry_batch_label": "{count} 笔交易 · {total}",
      "quick_entry_batch_failed": "无法读取收据 {indexes} — 未保存任何内容",
      "quick_entry_batch_saved": "已保存 {count} 笔交易 · {total}",
      "quick_entry_batch_save_failed": "无法保存收据 {index}: {reason} — 未保存任何内容",
      "quick_entry_batch_partial":
          "已保存 {saved}/{total} — 收据 {index} 失败: {reason}",
      "quick_entry_scan_receipt": "扫描收据",
      "quick_entry_take_photo": "拍照",
      "quick_entry_choose_gallery": "从图库选择",
      "quick_entry_camera_not_available": "相机功能尚不可用",
      "smart_entry_preview_title_one": "确认交易",
      "smart_entry_preview_title_many": "确认 {count} 笔交易",
      "smart_entry_preview_subtitle": "保存前请检查并编辑",
      "smart_entry_preview_confirm_one": "确认",
      "smart_entry_preview_confirm_many": "全部确认（{count}）",
      "smart_entry_preview_apply_form": "应用到表单",
      "smart_entry_preview_pick_category": "选择类别",
      "smart_entry_preview_pick_wallet": "选择钱包",
      "smart_entry_preview_save_failed":
          "无法保存交易 {index}: {reason} — 未保存任何内容",
      "smart_entry_preview_save_partial":
          "已保存 {saved}/{total} — 交易 {index} 失败: {reason}",
      "smart_entry_preview_saved_one": "交易已保存",
      "smart_entry_preview_saved_many": "已保存 {count} 笔交易",
      "claims_in_progress": "您有 {count} 个请求正在进行中",
      "validation": {
        "amount_required": "金额必须大于 0",
        "wallet_required": "请选择钱包",
        "category_required": "请选择类别",
        "future_date": "无法记录未来的交易",
        "insufficient_balance": "钱包余额不足",
        "counterparty_required": "请输入贷款对象",
        "schedule_required": "请输入还款计划",
        "amount_exceeds_outstanding": "金额超过剩余余额",
        "liability_settled": "此债务已清算",
        "not_editable": "此交易无法编辑",
        "edit_window": "您只能编辑过去 30 天内的交易",
      },
      "transfer_money": "转账",
      "transfer_from": "转出钱包",
      "transfer_to": "转入钱包",
      "transfer_swap": "交换钱包",
      "transfer_saved": "转账已成功保存",
    },
    "liability": {
      "title": "负债",
      "list_title": "负债",
      "status_outstanding": "未结清",
      "status_settled": "已结清",
      "remaining_balance": "剩余",
      "principal_amount": "本金",
      "empty_state": "还没有负债",
      "empty_state_v2": "还没有负债/借贷\n点击 + 添加。",
      "history_title": "交易历史",
      "no_history": "还没有还款/收款记录",
      "delete_title": "删除负债",
      "delete_confirm_msg": "您确定要删除此负债吗？此操作无法撤销。",
      "borrow": "借入",
      "lend": "借出",
      "borrow_type_personal": "个人",
      "lend_type_personal": "个人",
      "repaid_prefix": "已还款: ",
      "borrow_prefix": "已借入: ",
      "received": "已收到",
      "to_collect": "待收款",
      "total_lend": "总借出",
    },
    "notification": {
      "channel_name": "提醒",
      "channel_description": "对账提醒、云注册和贷款到期日的通知",
      "audit_approaching_title": "对账日即将到来",
      "audit_approaching_body": "明天是您的每周对账日。别忘了对账余额！",
      "audit_due_title": "对账日到了",
      "audit_due_body": "今天是您的每周对账日。现在就对账余额！",
      "cloud_backup_title": "保护您的数据",
      "cloud_backup_body": "注册账户以将数据备份到云，避免丢失。",
      "loan_due_title": "贷款到期日即将到来",
      "loan_due_body": "贷款 '{name}' 将于 {date} 到期。",
      "budget_near_limit_body": "预算 \"{name}\" 已达到 80%。",
      "budget_over_body": "预算 \"{name}\" 超出了限额。",
    },
    "tutorial": {
      "nav_title": "您的导航栏",
      "nav_desc": "Phân 分配显示您的钱包和预算，Giao dịch 记录交易，Hồ sơ 是您的个人资料和设置。",
      "transaction_title": "记录交易",
      "transaction_desc": "在这里选择 Chi tiêu/Thu nhập/Đầu tư/Vay-Nợ，然后填写金额并保存。",
    },
    "budget": {
      "title": "预算",
      "description": "限额是您每月允许类别的最大金额 — 超过意味着超出计划支出。",
      "empty": "还没有预算。\n点击 + 添加支出限额。",
      "edit_limit": "编辑限额",
      "edit_title": "编辑预算",
      "limit_locked": "限额只能在每月的前 7 天内更改。",
      "delete_title": "删除预算",
      "delete_confirm": "删除 \"{name}\"？",
      "reset_period": "重置周期",
      "reset_title": "重置预算",
      "add_title": "添加预算",
      "name": "预算名称",
      "name_hint": "例如: A栋电力",
      "name_duplicate_error": "预算名称已存在",
      "category": "类别",
      "limit": "限额",
      "limit_hint": "例如: 1000000",
      "start_date": "开始",
      "end_date": "结束",
      "added": "已添加预算 \"{name}\"",
      "updated": "已更新预算 \"{name}\"",
      "period_started": "\"{name}\" 的新周期已开始",
      "over_limit": "您超出了限额！",
      "near_limit": "接近限额！",
      "over_limit_count": "您本月的 \"{name}\" 限额已超出了 {count} 次！",
      "over_by": "超出 {amount}",
      "remaining": "剩余 {amount}",
      "this_month": "本月预算",
      "month_indicator": "{month}",
      "see_all": "查看全部",
      "drag_reorder_hint": "长按拖动以重新排序",
      "customize_category": "自定义类别",
      "percent_used": "已使用 {percent}%",
      "spent_prefix": "已支出",
      "limit_prefix": "限额",
      "fixed_price": "固定价格",
      "fixed_price_description": "固定月度成本（最低生存成本），影响报告部分的安全指数。",
      "pacing_hint": "{name}: 剩余 {days} 天 · 建议 ≤{amount}/天",
      "penalty_warning": "{name} 已超出 {percent}%！",
      "deficit_warning": "本月支出多于收入（赤字 {amount}）",
      "debt_inflow_warning": "本月流入的 {percent}%（{amount}）来自债务，而非收入",
      "debt_outflow_warning": "本月流出的 {percent}%（{amount}）是借出或还款，而非支出",
      "anomaly_hint": "与过去 3 个月平均相比有 {count} 笔异常支出",
      "insights_title": "洞察与警告",
      "insights_action_review": "查看报告",
      "estimate_hint": "建议: {amount}（过去 3 个月平均）",
    },
    "reconciliation": {
      "title": "对账",
      "empty": "没有钱包可对账。",
      "instruction": "为每个钱包输入实际清点的余额:",
      "book_total": "账面总额",
      "actual_total": "实际总额",
      "difference": "差额",
      "balanced": "已平衡 ✓",
      "surplus": "盈余 {amount}",
      "deficit": "赤字 {amount}",
      "confirm": "确认对账",
      "success": "对账已确认",
      "success_message": "恭喜！您已成功完成对账 #{count}。",
      "history": "对账历史",
      "undo": "撤销",
      "undo_title": "撤销对账",
      "undo_confirm": "撤销最新的对账并删除调整条目？",
      "week": "第 {week}/{year} 周",
      "book": "账面",
      "actual": "实际",
      "book_balance": "账面: {amount}",
      "cycle_subtitle": "本周 · 周日到期",
      "description_line_1": "对账帮助您将实际余额与应用匹配，确保所有财务记录始终准确透明。",
      "description_line_2": "自动生成调整条目以使应用余额与现实匹配，而无需查看遗漏的交易。",
      "mismatch_warning": "{count} 个钱包不匹配，确认前请处理",
      "create_adjustment": "创建调整",
      "matched": "已匹配",
      "lech": "差额 {amount}",
      "review_transactions": "查看交易",
    },
    "report": {
      "title": "报告",
      "spending_proportion": "支出分布",
      "monthly_chart": "收入与支出",
      "this_week": "本周",
      "four_weeks_near": "过去 4 周",
      "this_month": "本月",
      "no_expense": "此期间没有支出。 \n记录任何支出/收入，然后根据需要更新",
      "weekly": "每周",
      "monthly": "每月",
      "yearly": "每年",
      "three_months": "3 个月",
      "income_expense": "收入与支出",
      "safety_index": "安全指数（跑道）",
      "runway_desc_2":
          "跑道显示您没有收入可以生存多长时间，并帮助您通过月度收入和支出图表查看您的积累，以便调整为更可持续的财务计划。",
      "runway_message": "您可以维持 {months} 个月 {days} 天",
      "runway_fixed_price_desc": "认真的财务管理生活方式",
      "runway_no_fixed_price_desc": "跑道使用您的实际支出。设置固定成本以获得更准确的估算。",
      "runway_perfect": "您的支出非常出色！",
      "runway_very_good": "非常好！您有一年以上的缓冲",
      "runway_good": "非常好！您的安全指数相当高",
      "runway_safe": "安全！您至少有 3 个月的缓冲",
      "runway_caution": "注意！您应该建立更多缓冲",
      "runway_insufficient": "开始记录支出，以便系统可以计算您的安全指数。",
      "runway_not_available": "数据不足",
      "investment_title": "投资",
      "investment_contributed": "已出资",
      "investment_returned": "已回收",
      "liability_title": "负债",
      "liability_in": "借入",
      "liability_out": "借出",
      "daily_detail": "每日详情",
      "income_short": "收入",
      "expense_short": "支出",
      "uncategorized": "未分类",
      "filtering_wallet": "筛选: {wallet}",
      "filter_by_wallet": "按钱包筛选",
      "filter_all_wallets": "所有钱包",
      "filter_by_type": "按类型筛选",
      "filter_all_types": "所有类型",
      "trend_week_label": "第 {number} 周",
      "ai_advice_title": "AI 财务建议",
      "ai_advice_empty_body": "获取本月支出的个性化审查和改进财务的建议。",
      "ai_advice_generate_cta": "生成建议",
      "ai_advice_loading": "生成建议中...",
      "ai_advice_generate_failed": "现在无法生成建议，请稍后再试。",
      "ai_advice_daily_limit_reached": "您已达到今天的 AI 建议上限。请明天再试。",
      "ai_advice_gemini_disabled": "个人资料设置中已关闭 Gemini AI。",
      "ai_advice_generated_just_now": "刚刚生成",
      "ai_advice_generated_minutes_ago": "{count} 分钟前生成",
      "ai_advice_generated_hours_ago": "{count} 小时前生成",
      "ai_advice_generated_days_ago": "{count} 天前生成",
    },
    "category": {
      "settings_title": "类别设置",
      "settings_subtitle": "管理自定义类别和组",
      "group_daily": "日常",
      "group_personal": "个人",
      "group_food_drink": "餐饮与咖啡",
      "group_transport": "交通",
      "group_utilities": "公用事业",
      "group_housing": "住房",
      "group_health": "医疗与健康",
      "group_education": "教育",
      "group_entertainment": "娱乐",
      "group_shopping": "购物",
      "group_insurance": "保险",
      "group_gifts": "礼品与慈善",
      "group_personal_care": "个人护理",
      "group_service_fees": "服务费",
      "group_family": "家庭与儿童",
      "food": "食品",
      "transport": "交通",
      "shopping": "购物",
      "health": "健康",
      "food_drink": "餐饮与咖啡",
      "coffee": "咖啡",
      "water": "水",
      "eat_out": "外出就餐",
      "taxi": "出租车",
      "gas": "汽油",
      "parking": "停车",
      "maintenance": "维护",
      "electricity": "电力",
      "internet": "互联网",
      "phone": "电话",
      "rent": "租金",
      "furniture": "家具",
      "laundry": "洗衣",
      "mortgage": "抵押贷款",
      "condo_fee": "公寓费",
      "doctor": "医生",
      "medicine": "药品",
      "health_insurance": "健康保险",
      "gym": "健身房",
      "tuition": "学费",
      "books": "书籍",
      "courses": "课程",
      "cinema": "电影院",
      "travel": "旅行",
      "gaming": "游戏",
      "events": "活动",
      "appliances": "家电",
      "electronics": "电子产品",
      "clothing": "服装",
      "cosmetics": "化妆品",
      "installment": "分期",
      "life_insurance": "人寿保险",
      "vehicle_insurance": "车辆保险",
      "home_insurance": "房屋保险",
      "gifts": "礼品",
      "charity": "慈善",
      "haircut": "理发",
      "spa": "水疗",
      "personal_care_product": "个人护理用品",
      "bank_fee": "银行手续费",
      "card_fee": "卡年费",
      "milk_formula": "婴儿配方奶粉",
      "diapers": "纸尿裤",
      "baby_toys": "婴儿玩具",
      "income_settings_title": "收入类别",
      "income_group_active": "主动收入",
      "income_group_invest": "投资收入",
      "income_group_other": "其他收入",
      "income_salary": "基本工资",
      "income_freelance": "自由职业",
      "income_allowance": "零花钱",
      "income_savings_interest": "储蓄利息",
      "income_dividends": "股息",
      "income_rental": "资产租赁",
      "income_bonus": "奖金",
      "income_gift": "礼品/礼物",
      "income_cashback": "返现",
      "debt_loan_settings_title": "债务与贷款类别",
      "debt_group_borrow": "借款",
      "debt_group_lend": "借出",
      "debt_personal_borrow": "个人贷款（朋友）",
      "debt_bank_borrow": "银行/金融贷款",
      "debt_mortgage": "抵押贷款",
      "debt_credit_card": "信用卡债务",
      "debt_installment": "分期",
      "debt_personal_lend": "个人借出",
      "debt_other": "其他",
      "debt_other_lend": "其他",
      "investment_bond": "债券",
      "investment_business": "商业",
      "investment_crypto": "加密货币",
      "investment_fund": "基金",
      "investment_gold": "黄金",
      "investment_group_default": "投资",
      "investment_linked_insurance": "投资连结保险",
      "investment_other": "其他",
      "investment_real_estate": "房地产",
      "investment_settings_title": "投资类别",
      "investment_stock": "股票",
      "investment_term_deposit": "定期存款",
      "market_supermarket": "市场与超市",
      "religious": "宗教/精神",
      "leisure": "休闲与旅行",
      "expense_settings_title": "支出类别",
    },
    "sync": {
      "offline_tooltip": "离线 — 数据仅在重新连接前保存在此设备上",
      "syncing_tooltip": "同步中 — 正在将数据备份到云…",
      "pending_tooltip": "{count} 个项目尚未备份到云 — 点击以同步",
      "synced_tooltip": "所有数据已备份到云",
      "logout_blocked_offline": "登录前请连接到互联网",
      "logout_blocked_pending": "您有尚未同步的数据。重新连接并同步后再登录。",
      "discard_title": "丢弃未同步的数据？",
      "discard_message": "某些数据无法备份，并将从此设备永久删除。此操作无法撤销。",
      "discard_confirm": "丢弃",
      "discard_done": "已丢弃未同步的数据",
    },
    "profile": {
      "guest": "访客",
      "not_logged_in": "未登录",
      "register_login": "注册 / 登录",
      "display_name_title": "编辑姓名",
      "display_name_hint": "输入您的显示名称",
      "display_name_save": "保存",
      "display_name_updated": "姓名已更新",
      "link_account_title": "关联账户",
      "link_account_subtitle": "使用电话号码或 Google 登录",
      "link_account_google": "Google",
      "link_account_phone": "电话号码",
      "link_account_linked": "已关联",
      "link_account_action": "关联",
      "link_account_success": "成功关联",
      "link_account_phone_hint": "输入电话号码",
      "link_account_send_code": "发送代码",
      "link_account_verify_code": "验证",
      "birth_year": "出生年份",
      "birth_year_subtitle": "用于建议适当的类别",
      "birth_year_hint": "选择您的实际出生年份，它会影响您的每日收入和支出计算",
      "birth_year_task_desc": "任务: 设置出生年份",
      "weekly_audit": "每周对账",
      "days_left": "剩余 {count} 天",
      "debt_loan": "债务 / 贷款",
      "unlock_at_lv": "在 LV{level} 打开",
      "unlocked": "已解锁",
      "vip": "VIP",
      "vip_subtitle": "解除投资项目 / 贷款记录的免费层级限制（本地切换，暂无实际付款）",
      "force_full_access": "解锁所有功能",
      "force_full_access_subtitle": "调试/QA 覆盖 — 立即解锁投资 + 债务/贷款（LV3），无论您的实际进度如何",
      "gemini_ai": "Gemini AI 功能",
      "gemini_ai_subtitle":
          "调试/QA — 开启: 文本、语音和收据条目首先由 Gemini 解析（本地回退）。关闭: 不会向 Gemini 发送任何内容，仅运行本地解析",
      "weekly_audit_day": "每周对账日",
      "weekly_audit_day_subtitle": "您查看每周余额的日期",
      "weekly_audit_day_hint": "选择您的每周对账日，通常在支出周期的末尾",
      "audit_shortcut": "审计",
      "reminder": "提醒",
      "reminder_subtitle": "收到记录对账的通知",
      "theme_subtitle": "在浅色和深色模式之间切换",
      "language_subtitle": "选择您的首选语言",
      "currency": "货币单位",
      "currency_subtitle": "更改您的主要货币单位",
      "currency_dong": "盾",
      "currency_vnd": "越南盾",
      "currency_usd": "美元",
      "currency_eur": "欧元",
      "currency_jpy": "日元",
      "currency_krw": "韩元",
      "currency_cny": "人民币",
      "view_tutorial": "再次查看教程",
      "view_tutorial_subtitle": "学习如何有效使用应用",
      "terms": "使用条款",
      "terms_subtitle": "阅读我们的服务条款和隐私政策",
      "about": "关于应用",
      "about_subtitle": "应用信息和开发者日志",
      "delete_account": "删除账户",
      "delete_confirm": "删除账户？",
      "delete_confirm_desc": "这将永久删除您的账户和所有相关数据。此操作无法撤销。",
      "young_children_message": "您有年幼的子女吗？如果是，我们将自动启用儿童相关类别（奶粉、纸尿裤、玩具）。",
      "experience_level_progress": "经验等级进度",
      "level_title": "等级 {level}（{title}）",
      "tap_to_return": "点击返回个人资料",
      "streak_weeks": "连续: {count} 周",
      "level_master": "大师",
      "level_intermediate": "中级",
      "level_novice": "新手",
      "progress_steps": "进度步骤",
      "reconciliation_streak_title": "{count} 周连续",
      "reconciliation_streak_desc": "对账日: {day}",
      "rate_app": "评价应用",
      "rate_app_subtitle": "帮助我们改进 So Sach Xin",
      "customer_reviews": "客户评价",
      "customer_ratings_count": "{count} 条客户评分",
      "calculate_ratings_info": "我们如何计算评分？",
      "out_of_5": "满分 5 分，得分为 {rating}",
      "star_count": "{count}星",
      "feedback_hint": "告诉我们更多（可选）",
      "feedback_send": "发送反馈",
      "feedback_required": "选择标签或写下内容",
      "feedback_sent": "感谢您的反馈",
      "feedback_praise_fast": "输入快速",
      "feedback_praise_offline": "离线也能正常使用",
      "feedback_praise_runway": "真实 Runway 计算",
      "feedback_praise_reconciliation": "对账准确",
      "feedback_praise_lending": "借贷管理清晰",
      "feedback_praise_suggestions": "资金建议精确",
      "feedback_praise_interface": "界面极简",
      "feedback_praise_scanning": "账单扫描敏锐 ✨",
      "feedback_praise_alerts": "通知准确",
      "feedback_praise_leveling": "升级有趣",
      "feedback_criticism_sync": "同步错误",
      "feedback_criticism_balance": "余额不符",
      "feedback_criticism_unlock": "解锁太慢",
      "feedback_criticism_scanning": "扫描账单不准确",
      "feedback_criticism_amount": "金额输入困难",
      "feedback_criticism_categories": "类别缺失",
      "feedback_criticism_limits": "限额编辑困难",
      "feedback_criticism_notifications": "没有通知",
      "feedback_criticism_charts": "图表难以查看",
      "feedback_criticism_speed": "应用程序缓慢",
    },
    "guideline": {
      "banner_title_completed": "恭喜！所有设置步骤已完成",
      "banner_title_in_progress": "挑战: 剩余 {remaining} 个步骤",
      "banner_desc_completed": "现在您可以开始以自律的方式管理财务。",
      "banner_desc_birth_year": "设置出生年份以接收适当的建议",
      "banner_desc_categories": "选择您的支出和收入类别",
      "banner_desc_wallet_balance": "设置钱包的当前余额",
      "banner_desc_modify_cash": "修改现金钱包的金额值",
      "banner_desc_budget_limit": "为每个类别设置支出限额",
      "banner_desc_min_living": "定义您的最低月度生活费用",
      "banner_desc_first_transaction": "记录您的第一笔支出交易",
      "banner_desc_investment": "创建您的第一笔投资以增加财富",
      "banner_desc_liability": "记录您的第一笔债务以管理债务",
      "banner_desc_lend": "记录您的第一笔借出以管理贷款",
      "banner_desc_default": "您已准备好管理财务！",
      "success_dialog_message": "恭喜！\n您已完成初始设置。",
      "reset_confirm_desc": "您已完成 {count} 个任务。重置将撤消所有进度。",
      "reset_confirm_agree": "查看教程",
      "reset_confirm_cancel": "取消",
    },
    "level_lock": {
      "unlock_at_lv": "在 LV{level} 解锁",
      "unlock_free_at_lv3": "免费在 LV3 解锁",
      "remaining_percent": "剩余 {percent}%",
      "investment_title": "跟踪投资与积累",
      "investment_desc": "直接在应用中记录股票、基金、房地产并跟踪 ROI — 通过完成支出纪律挑战解锁",
      "liability_title": "债务与贷款管理",
      "liability_desc": "跟踪债务、利率和专业还款计划 — 当达到更高的财务纪律时解锁",
      "task_setup_budget": "设置第一个预算",
      "task_record_transactions": "记录前 5 笔交易",
      "task_setup_birth_year": "设置出生年份",
      "task_reconciliation_streak": "对账纪律 {current}/{total} 周",
      "task_fixed_budgets": "设置 {current}/{total} 个固定预算",
      "task_positive_cash_flow": "本月正向现金流",
      "progress_archived": "{progress}% 经验已归档",
    },
  };

  static final Map<String, Map<String, dynamic>> mapLocales = {
    'en': _en,
    'vi': _vi,
    'ko': _ko,
    'ja': _ja,
    'zh': _zh,
  };
}

class CcLocaleKeys {
  CcLocaleKeys._();

  static const app = 'app';
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
  static const app_error = 'app.error';
  static const app_error_general = 'app.error.general';
  static const app_error_retry = 'app.error.retry';
  static const app_error_network = 'app.error.network';
  static const app_error_server = 'app.error.server';
  static const app_app_check = 'app.app_check';
  static const app_app_check_initialization_failed =
      'app.app_check.initialization_failed';
  static const app_app_check_token_refresh_failed =
      'app.app_check.token_refresh_failed';
  static const app_app_check_device_not_verified =
      'app.app_check.device_not_verified';

  static const common = 'common';
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
  static const common_sunday_short = 'common.sunday_short';
  static const common_select_date = 'common.select_date';
  static const common_income = 'common.income';
  static const common_expense = 'common.expense';
  static const common_common_weekday_names = 'common.common_weekday_names';
  static const common_weekday_names = 'common.common_weekday_names';
  static const common_press_back_again_to_exit =
      'common.press_back_again_to_exit';
  static const common_add_source = 'common.add_source';
  static const common_add = 'common.add';
  static const common_copy = 'common.copy';
  static const common_clear = 'common.clear';
  static const common_unit_billion = 'common.unit_billion';
  static const common_unit_million = 'common.unit_million';
  static const common_unit_thousand = 'common.unit_thousand';

  static const auth = 'auth';
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
  static const auth_biometric = 'auth.biometric';
  static const auth_biometric_reason = 'auth.biometric.reason';
  static const auth_biometric_fallback = 'auth.biometric.fallback';
  static const auth_biometric_not_available_log =
      'auth.biometric.not_available_log';
  static const auth_biometric_init_error = 'auth.biometric.init_error';
  static const auth_biometric_error = 'auth.biometric.error';
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
  static const auth_otp = 'auth.otp';
  static const auth_otp_invalid = 'auth.otp.invalid';
  static const auth_otp_expired = 'auth.otp.expired';
  static const auth_otp_too_many_attempts = 'auth.otp.too_many_attempts';

  static const validation = 'validation';
  static const validation_required = 'validation.required';
  static const validation_email = 'validation.email';
  static const validation_password_length = 'validation.password_length';
  static const validation_password_match = 'validation.password_match';
  static const validation_phone = 'validation.phone';
  static const validation_max_length_reached = 'validation.max_length_reached';

  static const home = 'home';
  static const home_title = 'home.title';
  static const home_welcome = 'home.welcome';
  static const home_recent_activity = 'home.recent_activity';
  static const home_view_all = 'home.view_all';
  static const home_my_wallets = 'home.my_wallets';

  static const settings = 'settings';
  static const settings_title = 'settings.title';
  static const settings_language = 'settings.language';
  static const settings_language_vietnamese = 'settings.language_vietnamese';
  static const settings_language_english = 'settings.language_english';
  static const settings_language_korean = 'settings.language_korean';
  static const settings_language_japanese = 'settings.language_japanese';
  static const settings_language_chinese = 'settings.language_chinese';
  static const settings_theme = 'settings.theme';
  static const settings_theme_static = 'settings.theme_static';
  static const settings_theme_light = 'settings.theme_light';
  static const settings_theme_dark = 'settings.theme_dark';
  static const settings_notifications = 'settings.notifications';
  static const settings_privacy = 'settings.privacy';
  static const settings_help = 'settings.help';
  static const settings_about = 'settings.about';

  static const nav = 'nav';
  static const nav_home = 'nav.home';
  static const nav_transaction = 'nav.transaction';
  static const nav_budget_allocation = 'nav.budget_allocation';
  static const nav_dashboard = 'nav.dashboard';
  static const nav_quick_test = 'nav.quick_test';
  static const nav_quick_test_page = 'nav.quick_test_page';
  static const nav_notification = 'nav.notification';
  static const nav_profile = 'nav.profile';
  static const nav_profile_info = 'nav.profile_info';
  static const nav_reconcile = 'nav.reconcile';

  static const dashboard = 'dashboard';
  static const dashboard_item_count = 'dashboard.item_count';
  static const dashboard_last_updated = 'dashboard.last_updated';
  static const dashboard_refresh_data = 'dashboard.refresh_data';
  static const dashboard_time = 'dashboard.time';
  static const dashboard_time_just_now = 'dashboard.time.just_now';
  static const dashboard_time_day = 'dashboard.time.day';
  static const dashboard_time_days = 'dashboard.time.days';
  static const dashboard_time_hour = 'dashboard.time.hour';
  static const dashboard_time_hours = 'dashboard.time.hours';
  static const dashboard_time_minute = 'dashboard.time.minute';
  static const dashboard_time_minutes = 'dashboard.time.minutes';

  static const wallet = 'wallet';
  static const wallet_my_account = 'wallet.my_account';
  static const wallet_spending_account = 'wallet.spending_account';
  static const wallet_total_assets = 'wallet.total_assets';
  static const wallet_your_wallets = 'wallet.your_wallets';
  static const wallet_see_all = 'wallet.see_all';
  static const wallet_empty = 'wallet.empty';
  static const wallet_investment_empty = 'wallet.investment_empty';
  static const wallet_investment_name = 'wallet.investment_name';
  static const wallet_investment_name_hint = 'wallet.investment_name_hint';
  static const wallet_add_title = 'wallet.add_title';
  static const wallet_edit_title = 'wallet.edit_title';
  static const wallet_investment_edit_title = 'wallet.investment_edit_title';
  static const wallet_name = 'wallet.name';
  static const wallet_name_hint = 'wallet.name_hint';
  static const wallet_name_duplicate_error = 'wallet.name_duplicate_error';
  static const wallet_initial_balance = 'wallet.initial_balance';
  static const wallet_initial_balance_hint = 'wallet.initial_balance_hint';
  static const wallet_balance_locked_hint = 'wallet.balance_locked_hint';
  static const wallet_balance_hidden = 'wallet.balance_hidden';
  static const wallet_save_info = 'wallet.save_info';
  static const wallet_bank = 'wallet.bank';
  static const wallet_cash = 'wallet.cash';
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
  static const wallet_investment_delete_title =
      'wallet.investment_delete_title';
  static const wallet_investment_delete_confirm =
      'wallet.investment_delete_confirm';
  static const wallet_delete_error_not_empty = 'wallet.delete_error_not_empty';
  static const wallet_delete_error_protected = 'wallet.delete_error_protected';
  static const wallet_liquid_assets = 'wallet.liquid_assets';
  static const wallet_liquid_assets_desc = 'wallet.liquid_assets_desc';
  static const wallet_investments = 'wallet.investments';
  static const wallet_investments_desc = 'wallet.investments_desc';
  static const wallet_liabilities = 'wallet.liabilities';
  static const wallet_liabilities_desc = 'wallet.liabilities_desc';
  static const wallet_investment_roi = 'wallet.investment_roi';
  static const wallet_investment_breakeven = 'wallet.investment_breakeven';

  static const comment = 'comment';
  static const comment_detail = 'comment.detail';
  static const comment_detail_title = 'comment.detail.title';
  static const comment_detail_content = 'comment.detail.content';
  static const comment_detail_post_id = 'comment.detail.post_id';
  static const comment_detail_id = 'comment.detail.id';

  static const transaction = 'transaction';
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
  static const transaction_delete_title = 'transaction.delete_title';
  static const transaction_delete_confirm_desc =
      'transaction.delete_confirm_desc';
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
  static const transaction_liability_direction_borrow =
      'transaction.liability_direction_borrow';
  static const transaction_liability_direction_lend =
      'transaction.liability_direction_lend';
  static const transaction_liability_name_label =
      'transaction.liability_name_label';
  static const transaction_liability_name_hint =
      'transaction.liability_name_hint';
  static const transaction_record_liability = 'transaction.record_liability';
  static const transaction_liability_amount_borrow_label =
      'transaction.liability_amount_borrow_label';
  static const transaction_liability_amount_lend_label =
      'transaction.liability_amount_lend_label';
  static const transaction_liability_wallet_borrow_label =
      'transaction.liability_wallet_borrow_label';
  static const transaction_liability_wallet_lend_label =
      'transaction.liability_wallet_lend_label';
  static const transaction_liability_saved = 'transaction.liability_saved';
  static const transaction_liability_name_duplicate_error =
      'transaction.liability_name_duplicate_error';
  static const transaction_liability_payment_saved =
      'transaction.liability_payment_saved';
  static const transaction_liability_category_borrow_label =
      'transaction.liability_category_borrow_label';
  static const transaction_liability_category_lend_label =
      'transaction.liability_category_lend_label';
  static const transaction_liability_borrower_label =
      'transaction.liability_borrower_label';
  static const transaction_liability_borrower_hint =
      'transaction.liability_borrower_hint';
  static const transaction_liability_collection_method_label =
      'transaction.liability_collection_method_label';
  static const transaction_liability_method_installment_lend =
      'transaction.liability_method_installment_lend';
  static const transaction_liability_method_lump_sum_lend =
      'transaction.liability_method_lump_sum_lend';
  static const transaction_liability_schedule_lend_label =
      'transaction.liability_schedule_lend_label';
  static const transaction_liability_reminder_once_label =
      'transaction.liability_reminder_once_label';
  static const transaction_liability_reminder_recurring_label =
      'transaction.liability_reminder_recurring_label';
  static const transaction_liability_counterparty_vip_locked =
      'transaction.liability_counterparty_vip_locked';
  static const transaction_liability_repayment_method_label =
      'transaction.liability_repayment_method_label';
  static const transaction_liability_method_installment =
      'transaction.liability_method_installment';
  static const transaction_liability_method_lump_sum =
      'transaction.liability_method_lump_sum';
  static const transaction_liability_final_due_date_label =
      'transaction.liability_final_due_date_label';
  static const transaction_liability_schedule_label =
      'transaction.liability_schedule_label';
  static const transaction_liability_add_period =
      'transaction.liability_add_period';
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
  static const transaction_bill_match_hint = 'transaction.bill_match_hint';
  static const transaction_monthly_income_match_hint =
      'transaction.monthly_income_match_hint';
  static const transaction_location_match_hint =
      'transaction.location_match_hint';
  static const transaction_quick_entry_hint = 'transaction.quick_entry_hint';
  static const transaction_quick_entry_parsed_result =
      'transaction.quick_entry_parsed_result';
  static const transaction_quick_entry_category_missing =
      'transaction.quick_entry_category_missing';
  static const transaction_quick_entry_could_not_parse =
      'transaction.quick_entry_could_not_parse';
  static const transaction_quick_entry_daily_limit_reached =
      'transaction.quick_entry_daily_limit_reached';
  static const transaction_quick_entry_mic_permission_denied =
      'transaction.quick_entry_mic_permission_denied';
  static const transaction_quick_entry_photo_permission_denied =
      'transaction.quick_entry_photo_permission_denied';
  static const transaction_quick_entry_batch_label =
      'transaction.quick_entry_batch_label';
  static const transaction_quick_entry_batch_failed =
      'transaction.quick_entry_batch_failed';
  static const transaction_quick_entry_batch_saved =
      'transaction.quick_entry_batch_saved';
  static const transaction_quick_entry_batch_save_failed =
      'transaction.quick_entry_batch_save_failed';
  static const transaction_quick_entry_batch_partial =
      'transaction.quick_entry_batch_partial';
  static const transaction_quick_entry_scan_receipt =
      'transaction.quick_entry_scan_receipt';
  static const transaction_quick_entry_take_photo =
      'transaction.quick_entry_take_photo';
  static const transaction_quick_entry_choose_gallery =
      'transaction.quick_entry_choose_gallery';
  static const transaction_quick_entry_camera_not_available =
      'transaction.quick_entry_camera_not_available';
  static const transaction_smart_entry_preview_title_one =
      'transaction.smart_entry_preview_title_one';
  static const transaction_smart_entry_preview_title_many =
      'transaction.smart_entry_preview_title_many';
  static const transaction_smart_entry_preview_subtitle =
      'transaction.smart_entry_preview_subtitle';
  static const transaction_smart_entry_preview_confirm_one =
      'transaction.smart_entry_preview_confirm_one';
  static const transaction_smart_entry_preview_confirm_many =
      'transaction.smart_entry_preview_confirm_many';
  static const transaction_smart_entry_preview_apply_form =
      'transaction.smart_entry_preview_apply_form';
  static const transaction_smart_entry_preview_pick_category =
      'transaction.smart_entry_preview_pick_category';
  static const transaction_smart_entry_preview_pick_wallet =
      'transaction.smart_entry_preview_pick_wallet';
  static const transaction_smart_entry_preview_save_failed =
      'transaction.smart_entry_preview_save_failed';
  static const transaction_smart_entry_preview_save_partial =
      'transaction.smart_entry_preview_save_partial';
  static const transaction_smart_entry_preview_saved_one =
      'transaction.smart_entry_preview_saved_one';
  static const transaction_smart_entry_preview_saved_many =
      'transaction.smart_entry_preview_saved_many';

  // Aliases for quick_entry keys (for convenience)
  static const quick_entry_hint = 'transaction.quick_entry_hint';
  static const quick_entry_parsed_result =
      'transaction.quick_entry_parsed_result';
  static const quick_entry_category_missing =
      'transaction.quick_entry_category_missing';
  static const quick_entry_could_not_parse =
      'transaction.quick_entry_could_not_parse';
  static const quick_entry_daily_limit_reached =
      'transaction.quick_entry_daily_limit_reached';
  static const quick_entry_mic_permission_denied =
      'transaction.quick_entry_mic_permission_denied';
  static const quick_entry_photo_permission_denied =
      'transaction.quick_entry_photo_permission_denied';
  static const quick_entry_batch_label = 'transaction.quick_entry_batch_label';
  static const quick_entry_batch_failed =
      'transaction.quick_entry_batch_failed';
  static const quick_entry_batch_saved = 'transaction.quick_entry_batch_saved';
  static const quick_entry_batch_save_failed =
      'transaction.quick_entry_batch_save_failed';
  static const quick_entry_batch_partial =
      'transaction.quick_entry_batch_partial';
  static const quick_entry_scan_receipt =
      'transaction.quick_entry_scan_receipt';
  static const quick_entry_take_photo = 'transaction.quick_entry_take_photo';
  static const quick_entry_choose_gallery =
      'transaction.quick_entry_choose_gallery';
  static const quick_entry_camera_not_available =
      'transaction.quick_entry_camera_not_available';
  static const smart_entry_preview_title_one =
      'transaction.smart_entry_preview_title_one';
  static const smart_entry_preview_title_many =
      'transaction.smart_entry_preview_title_many';
  static const smart_entry_preview_subtitle =
      'transaction.smart_entry_preview_subtitle';
  static const smart_entry_preview_confirm_one =
      'transaction.smart_entry_preview_confirm_one';
  static const smart_entry_preview_confirm_many =
      'transaction.smart_entry_preview_confirm_many';
  static const smart_entry_preview_apply_form =
      'transaction.smart_entry_preview_apply_form';
  static const smart_entry_preview_pick_category =
      'transaction.smart_entry_preview_pick_category';
  static const smart_entry_preview_pick_wallet =
      'transaction.smart_entry_preview_pick_wallet';
  static const smart_entry_preview_save_failed =
      'transaction.smart_entry_preview_save_failed';
  static const smart_entry_preview_save_partial =
      'transaction.smart_entry_preview_save_partial';
  static const smart_entry_preview_saved_one =
      'transaction.smart_entry_preview_saved_one';
  static const smart_entry_preview_saved_many =
      'transaction.smart_entry_preview_saved_many';
  static const transaction_claims_in_progress =
      'transaction.claims_in_progress';
  static const transaction_auto_save_countdown =
      'transaction.auto_save_countdown';
  static const transaction_validation = 'transaction.validation';
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
  static const transaction_validation_liability_settled =
      'transaction.validation.liability_settled';
  static const transaction_validation_not_editable =
      'transaction.validation.not_editable';
  static const transaction_validation_edit_window =
      'transaction.validation.edit_window';
  static const transaction_transfer_money = 'transaction.transfer_money';
  static const transaction_transfer_from = 'transaction.transfer_from';
  static const transaction_transfer_to = 'transaction.transfer_to';
  static const transaction_transfer_swap = 'transaction.transfer_swap';
  static const transaction_transfer_saved = 'transaction.transfer_saved';

  static const liability = 'liability';
  static const liability_title = 'liability.title';
  static const liability_list_title = 'liability.list_title';
  static const liability_status_outstanding = 'liability.status_outstanding';
  static const liability_status_settled = 'liability.status_settled';
  static const liability_remaining_balance = 'liability.remaining_balance';
  static const liability_principal_amount = 'liability.principal_amount';
  static const liability_empty_state = 'liability.empty_state';
  static const liability_empty_state_v2 = 'liability.empty_state_v2';
  static const liability_history_title = 'liability.history_title';
  static const liability_no_history = 'liability.no_history';
  static const liability_delete_title = 'liability.delete_title';
  static const liability_delete_confirm_msg = 'liability.delete_confirm_msg';
  static const liability_borrow = 'liability.borrow';
  static const liability_lend = 'liability.lend';
  static const liability_borrow_type_personal =
      'liability.borrow_type_personal';
  static const liability_repaid_prefix = 'liability.repaid_prefix';
  static const liability_borrow_prefix = 'liability.borrow_prefix';
  static const liability_received = 'liability.received';
  static const liability_to_collect = 'liability.to_collect';
  static const liability_total_lend = 'liability.total_lend';
  static const liability_lend_type_personal = 'liability.lend_type_personal';

  static const notification = 'notification';
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

  static const tutorial = 'tutorial';
  static const tutorial_nav_title = 'tutorial.nav_title';
  static const tutorial_nav_desc = 'tutorial.nav_desc';
  static const tutorial_transaction_title = 'tutorial.transaction_title';
  static const tutorial_transaction_desc = 'tutorial.transaction_desc';

  static const budget = 'budget';
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
  static const budget_month_indicator = 'budget.month_indicator';
  static const budget_see_all = 'budget.see_all';
  static const budget_drag_reorder_hint = 'budget.drag_reorder_hint';
  static const budget_customize_category = 'budget.customize_category';
  static const budget_percent_used = 'budget.percent_used';
  static const budget_spent_prefix = 'budget.spent_prefix';
  static const budget_limit_prefix = 'budget.limit_prefix';
  static const budget_fixed_price = 'budget.fixed_price';
  static const budget_fixed_price_description =
      'budget.fixed_price_description';
  static const budget_pacing_hint = 'budget.pacing_hint';
  static const budget_penalty_warning = 'budget.penalty_warning';
  static const budget_deficit_warning = 'budget.deficit_warning';
  static const budget_debt_inflow_warning = 'budget.debt_inflow_warning';
  static const budget_debt_outflow_warning = 'budget.debt_outflow_warning';
  static const budget_anomaly_hint = 'budget.anomaly_hint';
  static const budget_insights_title = 'budget.insights_title';
  static const budget_insights_action_review = 'budget.insights_action_review';
  static const budget_estimate_hint = 'budget.estimate_hint';

  static const reconciliation = 'reconciliation';
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

  static const report = 'report';
  static const report_title = 'report.title';
  static const report_spending_proportion = 'report.spending_proportion';
  static const report_monthly_chart = 'report.monthly_chart';
  static const report_this_week = 'report.this_week';
  static const report_four_weeks_near = 'report.four_weeks_near';
  static const report_this_month = 'report.this_month';
  static const report_no_expense = 'report.no_expense';
  static const report_weekly = 'report.weekly';
  static const report_monthly = 'report.monthly';
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
  static const report_runway_perfect = 'report.runway_perfect';
  static const report_runway_very_good = 'report.runway_very_good';
  static const report_runway_good = 'report.runway_good';
  static const report_runway_safe = 'report.runway_safe';
  static const report_runway_caution = 'report.runway_caution';
  static const report_runway_insufficient = 'report.runway_insufficient';
  static const report_runway_not_available = 'report.runway_not_available';
  static const report_investment_title = 'report.investment_title';
  static const report_investment_contributed = 'report.investment_contributed';
  static const report_investment_returned = 'report.investment_returned';
  static const report_liability_title = 'report.liability_title';
  static const report_liability_in = 'report.liability_in';
  static const report_liability_out = 'report.liability_out';
  static const report_daily_detail = 'report.daily_detail';
  static const report_income_short = 'report.income_short';
  static const report_expense_short = 'report.expense_short';
  static const report_uncategorized = 'report.uncategorized';
  static const report_filtering_wallet = 'report.filtering_wallet';
  static const report_filter_by_wallet = 'report.filter_by_wallet';
  static const report_filter_all_wallets = 'report.filter_all_wallets';
  static const report_filter_by_type = 'report.filter_by_type';
  static const report_filter_all_types = 'report.filter_all_types';
  static const report_trend_week_label = 'report.trend_week_label';
  static const report_ai_advice_title = 'report.ai_advice_title';
  static const report_ai_advice_empty_body = 'report.ai_advice_empty_body';
  static const report_ai_advice_generate_cta = 'report.ai_advice_generate_cta';
  static const report_ai_advice_loading = 'report.ai_advice_loading';
  static const report_ai_advice_generate_failed =
      'report.ai_advice_generate_failed';
  static const report_ai_advice_daily_limit_reached =
      'report.ai_advice_daily_limit_reached';
  static const report_ai_advice_gemini_disabled =
      'report.ai_advice_gemini_disabled';
  static const report_ai_advice_generated_just_now =
      'report.ai_advice_generated_just_now';
  static const report_ai_advice_generated_minutes_ago =
      'report.ai_advice_generated_minutes_ago';
  static const report_ai_advice_generated_hours_ago =
      'report.ai_advice_generated_hours_ago';
  static const report_ai_advice_generated_days_ago =
      'report.ai_advice_generated_days_ago';

  static const category = 'category';
  static const category_group_daily = 'category.group_daily';
  static const category_group_personal = 'category.group_personal';
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
  static const category_settings_title = 'category.settings_title';
  static const category_settings_subtitle = 'category.settings_subtitle';
  static const category_income_settings_title =
      'category.income_settings_title';
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
  static const category_market_supermarket = 'category.market_supermarket';
  static const category_religious = 'category.religious';
  static const category_leisure = 'category.leisure';
  static const category_expense_settings_title =
      'category.expense_settings_title';

  static const sync = 'sync';
  static const sync_offline_tooltip = 'sync.offline_tooltip';
  static const sync_syncing_tooltip = 'sync.syncing_tooltip';
  static const sync_pending_tooltip = 'sync.pending_tooltip';
  static const sync_synced_tooltip = 'sync.synced_tooltip';
  static const sync_logout_blocked_offline = 'sync.logout_blocked_offline';
  static const sync_logout_blocked_pending = 'sync.logout_blocked_pending';
  static const sync_discard_title = 'sync.discard_title';
  static const sync_discard_message = 'sync.discard_message';
  static const sync_discard_confirm = 'sync.discard_confirm';
  static const sync_discard_done = 'sync.discard_done';

  static const profile = 'profile';
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
  static const profile_audit_shortcut = 'profile.audit_shortcut';
  static const profile_days_left = 'profile.days_left';
  static const profile_debt_loan = 'profile.debt_loan';
  static const profile_unlock_at_lv = 'profile.unlock_at_lv';
  static const profile_vip = 'profile.vip';
  static const profile_vip_subtitle = 'profile.vip_subtitle';
  static const profile_force_full_access = 'profile.force_full_access';
  static const profile_force_full_access_subtitle =
      'profile.force_full_access_subtitle';
  static const profile_gemini_ai = 'profile.gemini_ai';
  static const profile_gemini_ai_subtitle = 'profile.gemini_ai_subtitle';
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
  static const profile_currency_vnd = 'profile.currency_vnd';
  static const profile_currency_usd = 'profile.currency_usd';
  static const profile_currency_eur = 'profile.currency_eur';
  static const profile_currency_jpy = 'profile.currency_jpy';
  static const profile_currency_krw = 'profile.currency_krw';
  static const profile_currency_cny = 'profile.currency_cny';
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
  static const profile_rate_app = 'profile.rate_app';
  static const profile_rate_app_subtitle = 'profile.rate_app_subtitle';
  static const profile_customer_reviews = 'profile.customer_reviews';
  static const profile_customer_ratings_count =
      'profile.customer_ratings_count';
  static const profile_calculate_ratings_info =
      'profile.calculate_ratings_info';
  static const profile_out_of_5 = 'profile.out_of_5';
  static const profile_star_count = 'profile.star_count';
  static const profile_feedback_hint = 'profile.feedback_hint';
  static const profile_feedback_send = 'profile.feedback_send';
  static const profile_feedback_required = 'profile.feedback_required';
  static const profile_feedback_sent = 'profile.feedback_sent';
  static const profile_feedback_praise_fast = 'profile.feedback_praise_fast';
  static const profile_feedback_praise_offline =
      'profile.feedback_praise_offline';
  static const profile_feedback_praise_runway =
      'profile.feedback_praise_runway';
  static const profile_feedback_praise_reconciliation =
      'profile.feedback_praise_reconciliation';
  static const profile_feedback_praise_lending =
      'profile.feedback_praise_lending';
  static const profile_feedback_praise_suggestions =
      'profile.feedback_praise_suggestions';
  static const profile_feedback_praise_interface =
      'profile.feedback_praise_interface';
  static const profile_feedback_praise_scanning =
      'profile.feedback_praise_scanning';
  static const profile_feedback_praise_alerts =
      'profile.feedback_praise_alerts';
  static const profile_feedback_praise_leveling =
      'profile.feedback_praise_leveling';
  static const profile_feedback_criticism_sync =
      'profile.feedback_criticism_sync';
  static const profile_feedback_criticism_balance =
      'profile.feedback_criticism_balance';
  static const profile_feedback_criticism_unlock =
      'profile.feedback_criticism_unlock';
  static const profile_feedback_criticism_scanning =
      'profile.feedback_criticism_scanning';
  static const profile_feedback_criticism_amount =
      'profile.feedback_criticism_amount';
  static const profile_feedback_criticism_categories =
      'profile.feedback_criticism_categories';
  static const profile_feedback_criticism_limits =
      'profile.feedback_criticism_limits';
  static const profile_feedback_criticism_notifications =
      'profile.feedback_criticism_notifications';
  static const profile_feedback_criticism_charts =
      'profile.feedback_criticism_charts';
  static const profile_feedback_criticism_speed =
      'profile.feedback_criticism_speed';
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
  static const profile_reconciliation_streak_title =
      'profile.reconciliation_streak_title';
  static const profile_reconciliation_streak_desc =
      'profile.reconciliation_streak_desc';
  static const profile_unlocked = 'profile.unlocked';

  static const guideline = 'guideline';
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
  static const guideline_banner_desc_investment =
      'guideline.banner_desc_investment';
  static const guideline_banner_desc_liability =
      'guideline.banner_desc_liability';
  static const guideline_banner_desc_lend = 'guideline.banner_desc_lend';
  static const guideline_banner_desc_default = 'guideline.banner_desc_default';
  static const guideline_success_dialog_message =
      'guideline.success_dialog_message';
  static const guideline_reset_confirm_desc = 'guideline.reset_confirm_desc';
  static const guideline_reset_confirm_agree = 'guideline.reset_confirm_agree';
  static const guideline_reset_confirm_cancel =
      'guideline.reset_confirm_cancel';

  static const level_lock = 'level_lock';
  static const level_lock_unlock_at_lv = 'level_lock.unlock_at_lv';
  static const level_lock_unlock_free_at_lv3 = 'level_lock.unlock_free_at_lv3';
  static const level_lock_remaining_percent = 'level_lock.remaining_percent';
  static const level_lock_investment_title = 'level_lock.investment_title';
  static const level_lock_investment_desc = 'level_lock.investment_desc';
  static const level_lock_liability_title = 'level_lock.liability_title';
  static const level_lock_liability_desc = 'level_lock.liability_desc';
  static const level_lock_task_setup_budget = 'level_lock.task_setup_budget';
  static const level_lock_task_record_transactions =
      'level_lock.task_record_transactions';
  static const level_lock_task_setup_birth_year =
      'level_lock.task_setup_birth_year';
  static const level_lock_task_reconciliation_streak =
      'level_lock.task_reconciliation_streak';
  static const level_lock_task_fixed_budgets = 'level_lock.task_fixed_budgets';
  static const level_lock_task_positive_cash_flow =
      'level_lock.task_positive_cash_flow';
  static const level_lock_progress_archived = 'level_lock.progress_archived';
}
