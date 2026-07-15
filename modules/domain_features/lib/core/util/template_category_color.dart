import 'package:flutter/material.dart';

/// Color palette for category groups & children.
/// One base hue per parent group; children vary by shade (dark → light)
/// within that same hue, following common fintech/e-commerce color
/// conventions (F&B = red/orange, transport = blue, shopping = orange,
/// income = green, etc.) rather than a single formal color study.
class CategoryColors {
  CategoryColors._();

  // ---------------------------------------------------------------------
  // Group 1 — Ăn uống & Cà phê · hue: Đỏ – Cam (đói bụng, kích thích vị giác)
  // ---------------------------------------------------------------------
  static const Color c1AnUong = Color(0xFFDC2626); // đỏ đậm
  static const Color c2CaPhe = Color(0xFF7C2D12); // nâu-đỏ cà phê
  static const Color c3Nuoc = Color(0xFFFCA5A5); // đỏ nhạt, tươi mát
  static const Color c4AnNgoai = Color(0xFFEA580C); // cam-đỏ

  // ---------------------------------------------------------------------
  // Group 2 — Di chuyển · hue: Xanh dương (Grab, Google Maps)
  // ---------------------------------------------------------------------
  static const Color c5Taxi = Color(0xFF2563EB);
  static const Color c6Xang = Color(0xFF1D4ED8); // đậm hơn — chi phí lớn hơn
  static const Color c7DoXe = Color(0xFF60A5FA); // nhạt — chi phí nhỏ
  static const Color c8BaoDuong = Color(
    0xFF1E3A8A,
  ); // đậm nhất — ít gặp, quan trọng

  // ---------------------------------------------------------------------
  // Group 3 — Tiện ích · hue: Vàng hổ phách (biểu tượng điện/ánh sáng)
  // ---------------------------------------------------------------------
  static const Color c9Dien = Color(0xFFF59E0B);
  static const Color c10Internet = Color(0xFFFBBF24);
  static const Color c11DienThoai = Color(0xFFD97706);

  // ---------------------------------------------------------------------
  // Group 4 — Nhà ở · hue: Xanh lá đất (ổn định, an cư)
  // ---------------------------------------------------------------------
  static const Color c12ThueNha = Color(0xFF16A34A);
  static const Color c13NoiThat = Color(0xFF4D7C0F);
  static const Color c14GiatUi = Color(0xFF86EFAC);
  static const Color c15TraGopNha = Color(
    0xFF14532D,
  ); // đậm nhất — cam kết dài hạn
  static const Color c16PhiChungCu = Color(0xFF65A30D);

  // ---------------------------------------------------------------------
  // Group 5 — Y tế & Sức khỏe · hue: Xanh ngọc (y tế hiện đại)
  // ---------------------------------------------------------------------
  static const Color c17BacSi = Color(0xFF0D9488);
  static const Color c18Thuoc = Color(0xFF14B8A6);
  static const Color c19BHYT = Color(0xFF115E59); // đậm — tính chất bảo hiểm
  static const Color c20Gym = Color(0xFF5EEAD4); // nhạt, năng động

  // ---------------------------------------------------------------------
  // Group 6 — Giáo dục · hue: Tím indigo (tri thức, tập trung)
  // ---------------------------------------------------------------------
  static const Color c21HocPhi = Color(0xFF4F46E5);
  static const Color c22Sach = Color(0xFF818CF8);
  static const Color c23KhoaHoc = Color(0xFF6D28D9);

  // ---------------------------------------------------------------------
  // Group 7 — Giải trí · hue: Hồng magenta (sôi động)
  // ---------------------------------------------------------------------
  static const Color c24RapPhim = Color(0xFFDB2777);
  static const Color c25DuLich = Color(0xFFF472B6);
  static const Color c26Gaming = Color(0xFF9D174D);
  static const Color c27SuKien = Color(0xFFEC4899);

  // ---------------------------------------------------------------------
  // Group 8 — Mua sắm · hue: Cam (Shopee, Lazada)
  // ---------------------------------------------------------------------
  static const Color c28DoGiaDung = Color(0xFFC2410C);
  static const Color c29DienTu = Color(0xFFEA580C);
  static const Color c30QuanAo = Color(0xFFFB923C);
  static const Color c31MyPham = Color(0xFFFDBA74);

  // ---------------------------------------------------------------------
  // Group 9 — Trả nợ & Vay · hue: Đỏ mận (cảnh báo tài chính)
  // ---------------------------------------------------------------------
  static const Color c32TraGop = Color(0xFF991B1B);
  static const Color c33LaiVay = Color(
    0xFF7F1D1D,
  ); // đậm nhất — rủi ro cao nhất

  // ---------------------------------------------------------------------
  // Group 10 — Bảo hiểm · hue: Xanh navy (tin cậy, an toàn)
  // ---------------------------------------------------------------------
  static const Color c34NhanTho = Color(0xFF1E3A8A);
  static const Color c35BaoHiemXe = Color(0xFF1D4ED8);
  static const Color c36BaoHiemNha = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------
  // Group 11 — Quà tặng & Từ thiện · hue: Hồng rose (ấm áp, sẻ chia)
  // ---------------------------------------------------------------------
  static const Color c37QuaTang = Color(0xFFE11D48);
  static const Color c38TuThien = Color(0xFFFB7185);

  // ---------------------------------------------------------------------
  // Group 12 — Chăm sóc cá nhân · hue: Hồng phấn (làm đẹp)
  // ---------------------------------------------------------------------
  static const Color c39CatToc = Color(0xFFF43F5E);
  static const Color c40Spa = Color(0xFFFDA4AF);
  static const Color c41SanPhamCSCN = Color(0xFFBE123C);

  // ---------------------------------------------------------------------
  // Group 13 — Phí dịch vụ · hue: Xám xanh (trung tính, phí phụ)
  // ---------------------------------------------------------------------
  static const Color c42PhiNganHang = Color(0xFF475569);
  static const Color c43PhiThe = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------
  // Group 14 — Gia đình & Con cái · hue: Xanh trời pastel (dịu nhẹ, trẻ nhỏ)
  // ---------------------------------------------------------------------
  static const Color c44Sua = Color(0xFFBAE6FD);
  static const Color c45Bim = Color(0xFF7DD3FC);
  static const Color c46DoChoi = Color(0xFF38BDF8);

  // =======================================================================
  // THU NHẬP
  // =======================================================================

  // Thu nhập chủ động · hue: Xanh lá (tích cực, chủ động)
  static const Color i1LuongChinh = Color(0xFF16A34A);
  static const Color i2Freelance = Color(0xFF4ADE80);
  static const Color i3PhuCap = Color(0xFF15803D);

  // Thu nhập đầu tư · hue: Xanh ngọc lục bảo (tăng trưởng, tích luỹ)
  static const Color i4LaiTietKiem = Color(0xFF059669);
  static const Color i5CoTuc = Color(0xFF34D399);
  static const Color i6ChoThueTaiSan = Color(0xFF047857);

  // Thu nhập khác · hue: Vàng gold (thưởng, quà, cashback)
  static const Color i7Thuong = Color(0xFFF59E0B);
  static const Color i8DuocTang = Color(0xFFFCD34D);
  static const Color i9Cashback = Color(0xFFB45309);

  /// Lookup map keyed by category id (khớp id trong CategorySeed) — tiện
  /// dùng trực tiếp: `CategoryColors.byId['c9']` thay vì gọi từng hằng số.
  static const Map<String, Color> byId = {
    'c1': c1AnUong,
    'c2': c2CaPhe,
    'c3': c3Nuoc,
    'c4': c4AnNgoai,
    'c5': c5Taxi,
    'c6': c6Xang,
    'c7': c7DoXe,
    'c8': c8BaoDuong,
    'c9': c9Dien,
    'c10': c10Internet,
    'c11': c11DienThoai,
    'c12': c12ThueNha,
    'c13': c13NoiThat,
    'c14': c14GiatUi,
    'c15': c15TraGopNha,
    'c16': c16PhiChungCu,
    'c17': c17BacSi,
    'c18': c18Thuoc,
    'c19': c19BHYT,
    'c20': c20Gym,
    'c21': c21HocPhi,
    'c22': c22Sach,
    'c23': c23KhoaHoc,
    'c24': c24RapPhim,
    'c25': c25DuLich,
    'c26': c26Gaming,
    'c27': c27SuKien,
    'c28': c28DoGiaDung,
    'c29': c29DienTu,
    'c30': c30QuanAo,
    'c31': c31MyPham,
    'c32': c32TraGop,
    'c33': c33LaiVay,
    'c34': c34NhanTho,
    'c35': c35BaoHiemXe,
    'c36': c36BaoHiemNha,
    'c37': c37QuaTang,
    'c38': c38TuThien,
    'c39': c39CatToc,
    'c40': c40Spa,
    'c41': c41SanPhamCSCN,
    'c42': c42PhiNganHang,
    'c43': c43PhiThe,
    'c44': c44Sua,
    'c45': c45Bim,
    'c46': c46DoChoi,
    'i1': i1LuongChinh,
    'i2': i2Freelance,
    'i3': i3PhuCap,
    'i4': i4LaiTietKiem,
    'i5': i5CoTuc,
    'i6': i6ChoThueTaiSan,
    'i7': i7Thuong,
    'i8': i8DuocTang,
    'i9': i9Cashback,
  };

  /// Base hue for each parent group id — dùng cho icon nhóm cha, tab
  /// chọn nhóm, hoặc khi chưa xác định category con cụ thể.
  static const Map<String, Color> groupBase = {
    '1': c1AnUong, // Ăn uống & Cà phê
    '2': c5Taxi, // Di chuyển
    '3': c9Dien, // Tiện ích
    '4': c12ThueNha, // Nhà ở
    '5': c17BacSi, // Y tế & Sức khỏe
    '6': c21HocPhi, // Giáo dục
    '7': c24RapPhim, // Giải trí
    '8': c29DienTu, // Mua sắm
    '9': c32TraGop, // Trả nợ & Vay
    '10': c35BaoHiemXe, // Bảo hiểm
    '11': c37QuaTang, // Quà tặng & Từ thiện
    '12': c39CatToc, // Chăm sóc cá nhân
    '13': c42PhiNganHang, // Phí dịch vụ
    '14': c46DoChoi, // Gia đình & Con cái
    'income_active': i1LuongChinh,
    'income_invest': i4LaiTietKiem,
    'income_other': i7Thuong,
  };
}
