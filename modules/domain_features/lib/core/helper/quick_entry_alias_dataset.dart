/// keywords for the local quick-entry parser.
/// Supports multiple languages (Vietnamese, English) and informal shorthands.
class QuickEntryAliasDataset {
  QuickEntryAliasDataset._();

  /// Multipliers for Vietnamese and English money units.
  static const Map<String, int> amountUnitMultipliers = {
    'k': 1000,
    'nghin': 1000,
    'tr': 1000000,
    'trieu': 1000000,
    'trieudong': 1000000,
    'ty': 1000000000,
    'b': 1000000000,
    'd': 1,
    'vnd': 1,
    'dong': 1,
  };

  /// Common Vietnamese bill filler/stop words to ignore during line-item extraction.
  static const Set<String> billStopWords = {
    'tong',
    't tien',
    'thanh tien',
    'tien hang',
    'giam',
    'chiet khau',
    'thue',
    'vat',
    'phi',
    'phu phi',
    'thanh toan',
    'khach tra',
    'tra lai',
  };

  /// Filler words that should be stripped from the final transaction note.
  static const Set<String> noteFillerWords = {
    'ngay',
    'thang',
    'nay',
    'mua',
    'chi',
  };

  /// Minimum plausible amount in VND (ignore anything smaller).
  static const int minPlausibleAmount = 1000;

  /// Maximum plausible amount for a single item on a receipt.
  static const int maxLineItemAmount = 10000000;

  /// Maximum plausible total amount for local parsing (escalate to cloud if higher).
  static const int maxLocalTotalAmount = 1000000000;

  /// Field-label prefixes marking the transfer message.
  static const List<String> noteFieldLabels = [
    'noi dung chuyen khoan',
    'noi dung ck',
    'noi dung',
    'loi nhan',
    'tin nhan',
    'dien giai',
    'ghi chu',
    'description',
    'message',
    'memo',
    'note',
  ];

  /// Field-label prefixes marking an e-wallet's own suggested category.
  static const List<String> categoryFieldLabels = [
    'danh muc giao dich',
    'danh muc',
    'phan loai',
    'loai giao dich',
    'category',
  ];

  /// Map of informal keywords to their seed category IDs.
  static const Map<String, String> categoryKeywords = {
    // ===== EXPENSE — Ăn uống & Cà phê (c1) =====
    'cf': 'c1',
    'cafe': 'c1',
    'coffee': 'c1',
    'ca phe': 'c1',
    'caphe': 'c1',
    'tra sua': 'c1',
    'trasua': 'c1',
    'sinh to': 'c1',
    'sinhto': 'c1',
    'nuoc ep': 'c1',
    'nuocep': 'c1',
    'nuoc ngot': 'c1',
    'nuocngot': 'c1',
    'com trua': 'c1',
    'comtrua': 'c1',
    'an trua': 'c1',
    'antrua': 'c1',
    'an toi': 'c1',
    'antoi': 'c1',
    'com': 'c1',
    'pho': 'c1',
    'bun': 'c1',
    'com van phong': 'c1',
    'comvanphong': 'c1',
    'quan nhau': 'c1',
    'quannhau': 'c1',
    'nha hang': 'c1',
    'nhahang': 'c1',
    'an ngoai': 'c1',
    'anngoai': 'c1',
    'an sang': 'c1',
    'ansang': 'c1',
    'an vat': 'c1',
    'anvat': 'c1',
    'nuoc': 'c1',
    'nuoc suoi': 'c1',
    'nuocsuoi': 'c1',
    'sting': 'c1',
    'bo huc': 'c1',
    'bohuc': 'c1',
    'coca': 'c1',
    'pepsi': 'c1',

    // ===== EXPENSE — Di chuyển (c5, c6, c7, c8) =====
    'xang': 'c6',
    'do xang': 'c6',
    'doxang': 'c6',
    'taxi': 'c5',
    'xanhsm': 'c5',
    'greensm': 'c5',
    'grab': 'c5',
    'be': 'c5',
    'gojek': 'c5',
    'xe om': 'c5',
    'xeom': 'c5',
    'gui xe': 'c7',
    'guixe': 'c7',
    'sua xe': 'c8',
    'suaxe': 'c8',
    've xe bus': 'c5',
    'vexebus': 'c5',
    've may bay': 'c25', // Du lịch
    'vemaybay': 'c25',
    // ===== EXPENSE — Hoá đơn tiện ích (c9, c10, c11) =====
    'dien': 'c9',
    'tien dien': 'c9',
    'tiendien': 'c9',
    'hoa don dien': 'c9',
    'evn': 'c9',
    'wifi': 'c10',
    'internet': 'c10',
    'mang': 'c10',
    'phone': 'c11',
    'dien thoai': 'c11',
    'dienthoai': 'c11',
    'dt': 'c11',
    'nap the': 'c11',
    'napthe': 'c11',
    'sim': 'c11',
    '4g': 'c11',
    'nap tien dt': 'c11',
    'tien nuoc': 'c9',

    // ===== EXPENSE — Nhà ở (c12, c13, c14, c16) =====
    'thue nha': 'c12',
    'thuenha': 'c12',
    'tien nha': 'c12',
    'tiennha': 'c12',
    'phi quan ly': 'c16',
    'phiquanly': 'c16',
    'sua nha': 'c13',
    'suanha': 'c13',
    'tra gop nha': 'd3', // Vay thế chấp
    // ===== EXPENSE — Y tế (c17, v18, c19, c20) =====
    'bac si': 'c17',
    'bacsi': 'c17',
    'kham benh': 'c17',
    'khambenh': 'c17',
    'vien phi': 'c17',
    'vienphi': 'c17',
    'benh vien': 'c17',
    'benhvien': 'c17',
    'kham suc khoe': 'c17',
    'khamsuckhoe': 'c17',
    'thuoc': 'c18',
    'thuoc tay': 'c18',
    'thuoctay': 'c18',
    'nha thuoc': 'c18',
    'nhathuoc': 'c18',
    'nha khoa': 'c17',
    'nhakhoa': 'c17',

    // ===== EXPENSE — Giáo dục (c21, c22, c23) =====
    'hoc phi': 'c21',
    'sach vo': 'c22',
    'khoa hoc': 'c23',
    'hoc them': 'c23',

    // ===== EXPENSE — Giải trí (c24, c25, c26, c27) =====
    'xem phim': 'c24',
    'phim': 'c24',
    'cgv': 'c24',
    'lotte': 'c24',
    'du lich': 'c25',
    'khach san': 'c25',
    'homestay': 'c25',
    'vui choi': 'c49',
    'khu vui choi': 'c49',
    'playground': 'c49',
    'khu du lich': 'c49',
    'game': 'c26',
    'nap game': 'c26',

    // ===== EXPENSE — Mua sắm (c28, c29, c30, c31, c47) =====
    'quan ao': 'c30',
    'quanao': 'c30',
    'giay dep': 'c30',
    'giaydep': 'c30',
    'mua sam': 'c30',
    'muasam': 'c30',
    'shopping': 'c30',
    'shopee': 'c30',
    'lazada': 'c30',
    'tiki': 'c30',
    'cho': 'c47',
    'sieu thi': 'c47',
    'sieuthi': 'c47',
    'market': 'c47',
    'supermarket': 'c47',
    'winmart': 'c47',
    'coopmart': 'c47',
    'bach hoa xanh': 'c47',
    'bachhoaxanh': 'c47',
    'do gia dung': 'c28',
    'dogiadung': 'c28',
    'dien tu': 'c29',
    'dientu': 'c29',

    // ===== EXPENSE — Bảo hiểm (c34, c35, c36) =====
    'bao hiem': 'c34',
    'bao hiem xe': 'c35',
    'bao hiem nha': 'c36',
    'bao hiem y te': 'c19',
    'bao hiem nhan tho': 'c34',

    // ===== EXPENSE — Quà tặng / Từ thiện (c37, c38, c48) =====
    'qua tang': 'c37',
    'tu thien': 'c38',
    'ung ho': 'c38',
    'mung cuoi': 'c37',
    'li xi': 'c37',
    'lixi': 'c37',
    'le chua': 'c48',
    'nha tho': 'c48',
    'pagoda': 'c48',
    'church': 'c48',
    'di chua': 'c48',
    'di le': 'c48',
    'cong duc': 'c48',

    // ===== EXPENSE — Chăm sóc cá nhân (c39, c40, c41) =====
    'cat toc': 'c39',
    'spa': 'c40',
    'lam dep': 'c40',
    'my pham': 'c31',
    'mat na': 'c31',

    // ===== EXPENSE — Phí dịch vụ/Ngân hàng (c42, c43) =====
    'phi chuyen khoan': 'c42',
    'phi ngan hang': 'c42',
    'phi thuong nien': 'c43',
    'phi rut tien': 'c42',

    // ===== EXPENSE — Gia đình/Con cái (c44, c45, c46) =====
    'bim': 'c45',
    'sua bot': 'c44',
    'do choi': 'c46',

    // ===== EXPENSE — Thể thao (c20) =====
    'gym': 'c20',
    'yoga': 'c20',
    'phong tap': 'c20',
    'ho boi': 'c20',

    // ===== INCOME — Thu nhập (i1 - i9) =====
    'luong': 'i1',
    'luongchinh': 'i1',
    'thuong': 'i7',
    'phu cap': 'i3',
    'phucap': 'i3',
    'freelance': 'i2',
    'lam them': 'i2',
    'lamthem': 'i2',
    'nhan tien': 'i8',
    'duoc tang': 'i8',
    'nhan tien li xi': 'i8',
    'lai tiet kiem': 'i4',
    'hoan tien': 'i9',
    'cashback': 'i9',
    'ban do cu': 'i9',
    'trung thuong': 'i9',
    've so': 'i9',

    // ===== INVEST — Đầu tư (inv1 - inv10) =====
    'cp': 'inv1',
    'chung khoan': 'inv1',
    'co phieu': 'inv1',
    'quy mo': 'inv2',
    'etf': 'inv2',
    'chung chi quy': 'inv2',
    'trai phieu': 'inv3',
    'gui tiet kiem': 'inv4',
    'so tiet kiem': 'inv4',
    'vang': 'inv5',
    'vang mieng': 'inv5',
    'vang nhan': 'inv5',
    'dat': 'inv6',
    'nha dat': 'inv6',
    'can ho': 'inv6',
    'bitcoin': 'inv7',
    'btc': 'inv7',
    'eth': 'inv7',
    'crypto': 'inv7',
    'kinh doanh': 'inv8',
    'gop von': 'inv8',

    // ===== LIABLE — Vay & Trả nợ (d1 - d5, d9) =====
    'vay ban be': 'd1',
    'vay ban': 'd1',
    'muon ban': 'd1',
    'muon tien': 'd1',
    'vay ngan hang': 'd2',
    'vay tin chap': 'd2',
    'vay the chap': 'd3',
    'vay mua nha': 'd3',
    'no the': 'd4',
    'the tin dung': 'd4',
    'quet the': 'd4',
    'tra gop': 'd5',
    'tra no': 'd9',
    'dong lai': 'd9',
    'thanh toan no': 'd9',

    // ===== LEND — Cho vay & Thu nợ (d6, d8) =====
    'thu hoi': 'd6',
    'thu hoi no': 'd6',
    'thu hồi': 'd6',
    'thu hồi nợ': 'd6',
    'thuhoi': 'd6',
    'doi no': 'd6',
    'lay no': 'd6',
    'ban be': 'd6',
    'ban': 'd6',
    'nguoi quen': 'd6',
    'ca nhan': 'd6',
    'dong nghiep': 'd6',
    'nguoi than': 'd6',
    'khac': 'd8',
    'ngoai': 'd8',
  };

  /// Aliases for relative dates.
  static const Map<String, int> dateRelativeOffsets = {
    'hom qua': 1,
    'ngay hom qua': 1,
    'yesterday': 1,
    'hom kia': 2,
    'ngay hom kia': 2,
    'the day before yesterday': 2,
    'hom nay': 0,
    'ngay hom nay': 0,
    'today': 0,
  };

  /// Map of wallet types/names to their seed keywords.
  static const Map<String, List<String>> walletKeywords = {
    'cash': ['tien mat', 'cash', 'vi'],
    'bank': ['ngan hang', 'bank', 'atm', 'the', 'card', 'ck', 'chuyen khoan'],
    'ewallet': ['momo', 'vnpay', 'zalopay', 'shopeepay'],
  };
}
