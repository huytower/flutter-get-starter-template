// Translations owned by cc_micro_features. Every key lives under the top-level
// `mf` group so it never collides with an app's own keys. The app merges
// [CcMfTranslations.mapLocales] into its easy_localization loader (see
// `CcLocalization.wrapWithLocalization(packageTranslations: ...)` in the
// `message` module); an app may override any value by defining the same key.
//
// Adding a string: add the constant to [CcMfLocaleKeys] and the value to every
// locale map below (a missing locale falls back to `en`).

// ignore_for_file: prefer_single_quotes, constant_identifier_names

abstract final class CcMfTranslations {
  static const Map<String, dynamic> _en = {
    "mf": {
      "app_update": {
        "current_version": "Current version: {version}",
        "message": "This version is no longer supported. Please update to version {version} or later to keep using the app.",
        "open_store_failed": "Couldn't open the store. Please update the app from the App Store or Google Play.",
        "title": "Update required",
        "update_now": "Update now",
      },
      "auth": {
        "agree_prefix": "I agree with ",
        "apple_verify_failed": "Couldn't verify your Apple ID. Please check your Apple ID in iPhone Settings and try again.",
        "didnt_receive_code": "Didn't receive code?",
        "enter_phone_number": "Log in with \n Phone Number",
        "enter_security_code": "Enter the security code we sent to",
        "link_account": "Link Account",
        "link_phone": "Link Phone Number",
        "login": "Login",
        "login_apple": "Login with Apple",
        "login_google": "Login with Google",
        "login_phone": "Login with Phone Number",
        "phone_number": "Phone Number",
        "phone_number_hint": "Enter phone number",
        "recent_login_required": "For security, please log in again before deleting your account.",
        "resend": "Resend after",
        "security_warning_bullet_ai": "AI-Generated Content",
        "security_warning_bullet_sms": "SMS/OTP Verification",
        "security_warning_other_login": "Other Sign In Methods",
        "security_warning_title": "For genuine devices only:",
        "terms_and_privacy": "By continuing, you agree to our Terms of Service and Privacy Policy",
        "terms_of_service": "Terms of Service",
        "verify": "Verify",
        "we_just_sent_sms": "We just sent an SMS",
        "terms": "Terms of use",
      },
      "common": {
        "continue": "Continue",
        "or": "OR",
      },
      "validation": {
        "phone": "Invalid phone number format",
      },
    },
  };

  static const Map<String, dynamic> _vi = {
    "mf": {
      "app_update": {
        "current_version": "Phiên bản hiện tại: {version}",
        "message": "Phiên bản này không còn được hỗ trợ. Vui lòng cập nhật lên phiên bản {version} trở lên để tiếp tục sử dụng.",
        "open_store_failed": "Không mở được cửa hàng ứng dụng. Vui lòng cập nhật ứng dụng từ App Store hoặc Google Play.",
        "title": "Cần cập nhật ứng dụng",
        "update_now": "Cập nhật ngay",
      },
      "auth": {
        "agree_prefix": "Tôi đồng ý với ",
        "apple_verify_failed": "Không thể xác thực Apple ID. Vui lòng kiểm tra tài khoản Apple ID trong Cài đặt iPhone của bạn và thử lại.",
        "didnt_receive_code": "Không nhận được mã?",
        "enter_phone_number": "Nhập số điện thoại của bạn",
        "enter_security_code": "Nhập mã bảo mật chúng tôi đã gửi tới",
        "link_account": "Liên kết tài khoản",
        "link_phone": "Liên kết số điện thoại",
        "login": "Đăng nhập",
        "login_apple": "Đăng nhập với Apple",
        "login_google": "Đăng nhập với Google",
        "login_phone": "Đăng nhập với số điện thoại",
        "phone_number": "Số điện thoại",
        "phone_number_hint": "Nhập số điện thoại",
        "recent_login_required": "Vì lý do bảo mật, vui lòng đăng nhập lại trước khi xóa tài khoản.",
        "resend": "Gửi lại sau",
        "security_warning_bullet_ai": "Nội dung tạo bởi AI",
        "security_warning_bullet_sms": "Xác minh SMS/OTP",
        "security_warning_other_login": "Đăng nhập khác",
        "security_warning_title": "Chỉ dành cho thiết bị chính hãng:",
        "terms_and_privacy": "Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của chúng tôi",
        "terms_of_service": "Điều khoản dịch vụ",
        "verify": "Xác minh",
        "we_just_sent_sms": "Chúng tôi vừa gửi một bản tin nhắn SMS",
        "terms": "Điều khoản sử dụng",
      },
      "common": {
        "continue": "Tiếp tục",
        "or": "HOẶC",
      },
      "validation": {
        "phone": "Số điện thoại không hợp lệ",
      },
    },
  };

  static const Map<String, dynamic> _ko = {
    "mf": {
      "app_update": {
        "current_version": "현재 버전: {version}",
        "message": "이 버전은 더 이상 지원되지 않습니다. 앱을 계속 사용하려면 {version} 이상 버전으로 업데이트해 주세요.",
        "open_store_failed": "스토어를 열 수 없습니다. App Store 또는 Google Play에서 앱을 업데이트해 주세요.",
        "title": "업데이트 필요",
        "update_now": "지금 업데이트",
      },
      "auth": {
        "agree_prefix": "동의합니다 ",
        "apple_verify_failed": "Apple ID를 확인할 수 없습니다. iPhone 설정에서 Apple ID를 확인한 후 다시 시도해 주세요.",
        "didnt_receive_code": "코드를 받지 못하셨나요?",
        "enter_phone_number": "전화번호로\n로그인",
        "enter_security_code": "보낸 보안 코드를 입력하세요",
        "link_account": "계정 연동",
        "link_phone": "휴대폰 번호 연동",
        "login": "로그인",
        "login_apple": "Apple로 로그인",
        "login_google": "Google로 로그인",
        "login_phone": "전화번호로 로그인",
        "phone_number": "전화번호",
        "phone_number_hint": "전화번호 입력",
        "recent_login_required": "보안을 위해 계정을 삭제하기 전에 다시 로그인해 주세요.",
        "resend": "후에 재전송",
        "security_warning_bullet_ai": "AI 생성 콘텐츠",
        "security_warning_bullet_sms": "SMS/OTP 인증",
        "security_warning_other_login": "다른 로그인 방법",
        "security_warning_title": "정품 보안이 통합되어 정품 기기만 사용할 수 있습니다:",
        "terms_and_privacy": "계속하면 서비스 약관 및 개인정보 보호정책에 동의합니다",
        "terms_of_service": "서비스 이용약관",
        "verify": "확인",
        "we_just_sent_sms": "SMS를 보냈습니다",
        "terms": "이용 약관",
      },
      "common": {
        "continue": "계속",
        "or": "또는",
      },
      "validation": {
        "phone": "잘못된 전화번호 형식",
      },
    },
  };

  static const Map<String, dynamic> _ja = {
    "mf": {
      "app_update": {
        "current_version": "現在のバージョン: {version}",
        "message": "このバージョンはサポートが終了しました。引き続きご利用いただくには、バージョン {version} 以降にアップデートしてください。",
        "open_store_failed": "ストアを開けませんでした。App Store または Google Play からアプリをアップデートしてください。",
        "title": "アップデートが必要です",
        "update_now": "今すぐアップデート",
      },
      "auth": {
        "agree_prefix": "同意する ",
        "apple_verify_failed": "Apple IDを確認できませんでした。iPhoneの設定でApple IDを確認して、もう一度お試しください。",
        "didnt_receive_code": "コードを受け取りませんでしたか？",
        "enter_phone_number": "電話番号で\nログイン",
        "enter_security_code": "送信したセキュリティコードを入力してください",
        "link_account": "アカウント連携",
        "link_phone": "電話番号連携",
        "login": "ログイン",
        "login_apple": "Appleでログイン",
        "login_google": "Googleでログイン",
        "login_phone": "電話番号でログイン",
        "phone_number": "電話番号",
        "phone_number_hint": "電話番号を入力",
        "recent_login_required": "セキュリティのため、アカウントを削除する前に再度ログインしてください。",
        "resend": "後で再送信",
        "security_warning_bullet_ai": "AI生成コンテンツ",
        "security_warning_bullet_sms": "SMS/OTP認証",
        "security_warning_other_login": "その他のログイン方法",
        "security_warning_title": "正規品のセキュリティが統合されています。正規のデバイスのみ使用可能です：",
        "terms_and_privacy": "続行することで、利用規約とプライバシーポリシーに同意します",
        "terms_of_service": "利用規約",
        "verify": "確認",
        "we_just_sent_sms": "SMSを送信しました",
        "terms": "利用規約",
      },
      "common": {
        "continue": "続行",
        "or": "または",
      },
      "validation": {
        "phone": "無効な電話番号形式",
      },
    },
  };

  static const Map<String, dynamic> _zh = {
    "mf": {
      "app_update": {
        "current_version": "当前版本：{version}",
        "message": "此版本已不再受支持。请更新到 {version} 或更高版本以继续使用。",
        "open_store_failed": "无法打开应用商店。请从 App Store 或 Google Play 更新应用。",
        "title": "需要更新",
        "update_now": "立即更新",
      },
      "auth": {
        "agree_prefix": "我同意 ",
        "apple_verify_failed": "无法验证 Apple ID。请在 iPhone 设置中检查您的 Apple ID 后重试。",
        "didnt_receive_code": "没有收到代码？",
        "enter_phone_number": "使用手机号码\n登录",
        "enter_security_code": "输入我们发送给您的安全代码",
        "link_account": "关联账号",
        "link_phone": "关联手机号码",
        "login": "登录",
        "login_apple": "使用 Apple 登录",
        "login_google": "使用 Google 登录",
        "login_phone": "使用手机号码登录",
        "phone_number": "手机号码",
        "phone_number_hint": "输入手机号码",
        "recent_login_required": "出于安全考虑，请在删除账户前重新登录。",
        "resend": "后重发",
        "security_warning_bullet_ai": "AI 生成内容",
        "security_warning_bullet_sms": "SMS/OTP 验证",
        "security_warning_other_login": "其他登录方式",
        "security_warning_title": "已集成正品安全防护，仅正品设备可以使用：",
        "terms_and_privacy": "继续即表示您同意我们的服务条款和隐私政策",
        "terms_of_service": "服务条款",
        "verify": "验证",
        "we_just_sent_sms": "我们刚刚发送了一条短信",
        "terms": "使用条款",
      },
      "common": {
        "continue": "继续",
        "or": "或",
      },
      "validation": {
        "phone": "无效的手机号码格式",
      },
    },
  };

  /// Locale code -> translations, in the same shape as the app's maps.
  static const Map<String, Map<String, dynamic>> mapLocales = {
    'en': _en,
    'vi': _vi,
    'ko': _ko,
    'ja': _ja,
    'zh': _zh,
  };
}
