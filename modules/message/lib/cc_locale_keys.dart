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
      "your_wallets": "Your wallets",
      "see_all": "See all",
      "empty": "No wallets yet.\nTap + to add one.",
      "add_title": "Add New Wallet",
      "edit_title": "Edit Wallet",
      "name": "Wallet Name",
      "name_hint": "e.g. Cash, Techcombank...",
      "initial_balance": "Opening Balance",
      "initial_balance_hint": "e.g. 1000000",
      "balance_locked_hint":
          "Cannot change opening balance once the wallet has transactions",
      "save_info": "Save Information",
      "bank": "Bank",
      "credit": "Credit Card",
      "added_success": "New wallet added",
      "updated_success": "Wallet updated",
      "delete_title": "Delete Wallet",
      "delete_confirm_msg":
          "A wallet can only be deleted when its balance is 0. All transactions of the wallet will be soft-deleted. Continue?",
      "delete_error_not_empty": "Cannot delete: wallet balance must be 0",
      "delete_error_protected": "This wallet is required and cannot be deleted",
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
      "transfer_saved": "Transferred {amount} đ successfully!",
      "transfer_from": "From Wallet",
      "transfer_to": "To Wallet",
      "record_transfer": "Transfer",
      "source_income": "Source of Income",
      "reason_income": "Reason for Income",
      "recipient": "Recipient",
      "record_income": "Record Income",
      "expense_slip": "Expense",
      "income_slip": "Income",
      "category_sub": "Sub-category",
      "today": "Today",
      "yesterday": "Yesterday",
      "note": "Note",
      "note_hint": "Note (optional)",
      "more_details": "More details",
      "validation": {
        "amount_required": "Amount must be greater than 0",
        "wallet_required": "Please select a wallet",
        "category_required": "Please select a category",
        "future_date": "Cannot record a future transaction",
        "insufficient_balance": "Insufficient wallet balance",
        "same_wallet_transfer": "Cannot transfer to the same wallet",
      },
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
      "over_by": "Over by {amount}",
      "remaining": "Remaining {amount}",
      "this_month": "This month's budgets",
      "see_all": "See all",
      "drag_reorder_hint": "Hold and drag to reorder",
      "customize_category": "Customize category",
      "percent_used": "{percent}% used",
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
      "runway_message": "You can sustain for {months} months {days} days.",
      "runway_perfect": "Your spending is excellent!",
      "runway_very_good": "Excellent! You have over a year of buffer.",
      "runway_good": "Very good! Your safety index is quite high.",
      "runway_safe": "Safe! You have at least 3 months of buffer.",
      "runway_caution": "Caution! You should build more buffer.",
      "runway_insufficient":
          "Start recording expenses so the system can calculate your safety index.",
      "runway_not_available": "Insufficient data",
      "daily_detail": "Daily Detail",
      "income_short": "Inc",
      "expense_short": "Exp",
      "uncategorized": "Uncategorized",
    },
    "category": {
      "group_daily": "Daily",
      "group_personal": "Personal",
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
      "loan_interest": "Loan Interest",
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
      "expense_settings_title": "Expense Categories",
    },
    "profile": {
      "guest": "Guest",
      "not_logged_in": "Not logged in",
      "register_login": "Register / Login",
      "birth_year": "Birth year",
      "birth_year_hint":
          "Choose your actual birth year, it affects your daily income and expense calculations",
      "weekly_audit": "Weekly audit",
      "weekly_audit_day_hint":
          "Select your weekly audit day, usually at the end of your spending cycle",
      "days_left": "{count} days left",
      "debt_loan": "Debt / Loan",
      "unlock_at_lv": "Opens at LV{level}",
      "weekly_audit_day": "Weekly audit day",
      "reminder": "Reminders",
      "currency": "Currency unit",
      "currency_dong": "Dong",
      "view_tutorial": "View tutorial again",
      "terms": "Terms of use",
      "about": "About app",
      "delete_account": "Delete account",
      "young_children_message":
          "Do you have young children? If yes, we'll automatically enable kid-related categories (milk, diapers, toys).",
    },
  };
  static const Map<String, dynamic> _vi = {
    "app": {
      "name": "Ứng dụng mẫu",
      "version": "Phiên bản {version}",
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
      "your_wallets": "Ví của bạn",
      "see_all": "Xem tất cả",
      "empty": "Chưa có ví nào.\nNhấn + để thêm ví.",
      "add_title": "Thêm ví mới",
      "edit_title": "Sửa ví",
      "name": "Tên ví",
      "name_hint": "Ví dụ: Tiền mặt, Techcombank...",
      "initial_balance": "Số dư đầu kỳ",
      "initial_balance_hint": "Ví dụ: 1000000",
      "balance_locked_hint":
          "Không thể sửa số dư đầu kỳ khi ví đã có giao dịch",
      "save_info": "Lưu thông tin",
      "bank": "Ngân hàng",
      "credit": "Thẻ tín dụng",
      "added_success": "Đã thêm ví mới",
      "updated_success": "Đã cập nhật ví",
      "delete_title": "Xóa ví",
      "delete_confirm_msg":
          "Chỉ có thể xóa ví khi số dư bằng 0. Mọi giao dịch của ví sẽ được xóa (soft-delete). Tiếp tục?",
      "delete_error_not_empty": "Không thể xóa: số dư của ví phải bằng 0",
      "delete_error_protected": "Ví này là bắt buộc và không thể xóa",
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
      "transfer_saved": "Đã chuyển {amount} đ thành công!",
      "transfer_from": "Từ ví",
      "transfer_to": "Đến ví",
      "record_transfer": "Chuyển khoản",
      "source_income": "Nguồn thu nhập",
      "reason_income": "Lý do thu nhập",
      "recipient": "Người nhận",
      "record_income": "Ghi chép thu nhập",
      "expense_slip": "Chi tiêu",
      "income_slip": "Thu nhập",
      "category_sub": "Danh mục con",
      "today": "Hôm nay",
      "yesterday": "Hôm qua",
      "note": "Ghi chú",
      "note_hint": "Ghi chú (không bắt buộc)",
      "more_details": "Thêm chi tiết",
      "validation": {
        "amount_required": "Số tiền phải lớn hơn 0!",
        "wallet_required": "Vui lòng chọn ví!",
        "category_required": "Vui lòng chọn hạng mục!",
        "future_date": "Không thể ghi giao dịch ở tương lai!",
        "insufficient_balance": "Số dư ví không đủ!",
        "same_wallet_transfer": "Không thể chuyển vào cùng một ví!",
      },
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
      "over_by": "Vượt {amount}",
      "remaining": "Còn {amount}",
      "this_month": "Ngân sách tháng này",
      "see_all": "Xem tất cả",
      "drag_reorder_hint": "Giữ và kéo để đổi thứ tự",
      "customize_category": "Tuỳ chỉnh danh mục",
      "percent_used": "{percent}% đã dùng",
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
      "runway_message": "Bạn có thể duy trì {months} tháng {days} ngày.",
      "runway_perfect": "Bạn đang chi tiêu rất tuyệt vời!",
      "runway_very_good": "Tuyệt vời! Bạn có đủ tiền dự phòng cho hơn 1 năm.",
      "runway_good": "Rất tốt! Bạn có chỉ số an toàn tài chính khá cao.",
      "runway_safe": "An toàn! Bạn có đủ tiền dự phòng cho ít nhất 3 tháng.",
      "runway_caution": "Hãy cẩn trọng! Bạn nên tích lũy thêm quỹ dự phòng.",
      "runway_insufficient":
          "Hãy bắt đầu ghi chép chi tiêu để hệ thống tính toán chỉ số an toàn cho bạn.",
      "runway_not_available": "Chưa đủ dữ liệu",
      "daily_detail": "Chi tiết theo ngày",
      "income_short": "Thu",
      "expense_short": "Chi",
      "uncategorized": "Chưa phân loại",
    },
    "category": {
      "group_daily": "Hàng ngày",
      "group_personal": "Cá nhân",
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
      "loan_interest": "Lãi vay",
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
      "expense_settings_title": "Hạng mục chi tiêu",
    },
    "profile": {
      "guest": "Khách",
      "not_logged_in": "Chưa đăng nhập",
      "register_login": "Đăng ký / Đăng nhập",
      "birth_year": "Năm sinh",
      "birth_year_hint":
          "Chọn năm sinh đúng thực tế, có ảnh hưởng đến số tiền thu nhập, chi tiêu hằng ngày của bạn",
      "weekly_audit": "Kiểm toán tuần",
      "weekly_audit_day_hint":
          "Chọn ngày kiểm toán hàng tuần của bạn, thường là ngày cuối cùng trong chu kỳ chi tiêu",
      "days_left": "Còn {count} ngày",
      "debt_loan": "Nợ/Vay",
      "unlock_at_lv": "Mở ở LV{level}",
      "weekly_audit_day": "Ngày kiểm toán hàng tuần",
      "reminder": "Nhắc nhở",
      "currency": "Đơn vị tiền tệ",
      "currency_dong": "Đồng",
      "view_tutorial": "Xem hướng dẫn lại",
      "terms": "Điều khoản sử dụng",
      "about": "Về ứng dụng",
      "delete_account": "Xoá tài khoản",
      "young_children_message":
          "Bạn có con nhỏ không? Nếu có, chúng tôi sẽ tự động bật các danh mục dành cho con (sữa, bỉm, đồ chơi trẻ em).",
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
  static const wallet_add_title = 'wallet.add_title';
  static const wallet_edit_title = 'wallet.edit_title';
  static const wallet_name = 'wallet.name';
  static const wallet_name_hint = 'wallet.name_hint';
  static const wallet_initial_balance = 'wallet.initial_balance';
  static const wallet_balance_locked_hint = 'wallet.balance_locked_hint';
  static const wallet_save_info = 'wallet.save_info';
  static const wallet_bank = 'wallet.bank';
  static const wallet_credit = 'wallet.credit';
  static const wallet_added_success = 'wallet.added_success';
  static const wallet_updated_success = 'wallet.updated_success';
  static const wallet_delete_title = 'wallet.delete_title';
  static const wallet_delete_confirm_msg = 'wallet.delete_confirm_msg';
  static const wallet_delete_error_not_empty = 'wallet.delete_error_not_empty';
  static const wallet_delete_error_protected = 'wallet.delete_error_protected';

  static const transaction_title = 'transaction.title';
  static const transaction_wallet = 'transaction.wallet';
  static const transaction_emergency = 'transaction.emergency';
  static const transaction_investment = 'transaction.investment';
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
  static const transaction_transfer_saved = 'transaction.transfer_saved';
  static const transaction_transfer_from = 'transaction.transfer_from';
  static const transaction_transfer_to = 'transaction.transfer_to';
  static const transaction_record_transfer = 'transaction.record_transfer';
  static const transaction_source_income = 'transaction.source_income';
  static const transaction_reason_income = 'transaction.reason_income';
  static const transaction_recipient = 'transaction.recipient';
  static const transaction_record_income = 'transaction.record_income';
  static const transaction_expense_slip = 'transaction.expense_slip';
  static const transaction_income_slip = 'transaction.income_slip';
  static const transaction_category_sub = 'transaction.category_sub';
  static const transaction_today = 'transaction.today';
  static const transaction_yesterday = 'transaction.yesterday';
  static const transaction_note = 'transaction.note';
  static const transaction_note_hint = 'transaction.note_hint';
  static const transaction_more_details = 'transaction.more_details';
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
  static const transaction_validation_same_wallet_transfer =
      'transaction.validation.same_wallet_transfer';

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
  static const budget_over_by = 'budget.over_by';
  static const budget_remaining = 'budget.remaining';
  static const budget_this_month = 'budget.this_month';
  static const budget_see_all = 'budget.see_all';
  static const budget_drag_reorder_hint = 'budget.drag_reorder_hint';
  static const budget_customize_category = 'budget.customize_category';
  static const budget_percent_used = 'budget.percent_used';

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
  static const report_runway_message = 'report.runway_message';
  static const report_runway_very_good = 'report.runway_very_good';
  static const report_runway_good = 'report.runway_good';
  static const report_runway_safe = 'report.runway_safe';
  static const report_runway_caution = 'report.runway_caution';
  static const report_runway_insufficient = 'report.runway_insufficient';
  static const report_runway_not_available = 'report.runway_not_available';
  static const report_daily_detail = 'report.daily_detail';
  static const report_income_short = 'report.income_short';
  static const report_expense_short = 'report.expense_short';
  static const report_uncategorized = 'report.uncategorized';

  static const category_settings_title = 'category.settings_title';
  static const category_settings_subtitle = 'category.settings_subtitle';
  static const category_settings_save = 'category.settings_save';
  static const category_settings_saved = 'category.settings_saved';
  static const category_expense_settings_title =
      'category.expense_settings_title';
  static const category_income_settings_title =
      'category.income_settings_title';
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
  static const category_loan_interest = 'category.loan_interest';
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

  static const comment_detail_title = 'comment.detail.title';
  static const comment_detail_content = 'comment.detail.content';
  static const comment_detail_post_id = 'comment.detail.post_id';
  static const comment_detail_id = 'comment.detail.id';

  static const profile_guest = 'profile.guest';
  static const profile_not_logged_in = 'profile.not_logged_in';
  static const profile_register_login = 'profile.register_login';
  static const profile_birth_year = 'profile.birth_year';
  static const profile_birth_year_hint = 'profile.birth_year_hint';
  static const profile_weekly_audit = 'profile.weekly_audit';
  static const profile_weekly_audit_day_hint = 'profile.weekly_audit_day_hint';
  static const profile_days_left = 'profile.days_left';
  static const profile_debt_loan = 'profile.debt_loan';
  static const profile_unlock_at_lv = 'profile.unlock_at_lv';
  static const profile_weekly_audit_day = 'profile.weekly_audit_day';
  static const profile_reminder = 'profile.reminder';
  static const profile_currency = 'profile.currency';
  static const profile_currency_dong = 'profile.currency_dong';
  static const profile_view_tutorial = 'profile.view_tutorial';
  static const profile_terms = 'profile.terms';
  static const profile_about = 'profile.about';
  static const profile_delete_account = 'profile.delete_account';
  static const profile_young_children_message =
      'profile.young_children_message';
}
