import 'package:cc_sdk_ui/core/config/tokens/cc_base_colors.dart';
import 'package:flutter/material.dart';

/// PrjColors: The Single Source of Truth (SSOT) for the application's look and feel.
///
/// This file maps generic "Palette Primitives" from the SDK to specific
/// "Semantic Roles" for this application.
///
/// ## Principles
/// - **Role Ownership**: This is the ONLY place to define what a color "means" for this app.
/// - **Primitive Mapping**: Map names to `CcBaseColors` primitives.
/// - **Zero Redundancy**: If you change the primary color, change it HERE.
abstract final class PrjColors {
  PrjColors._();

  // ===========================================================================
  // BRAND & PRIMARY
  // ===========================================================================
  static const Color primary = CcBaseColors.teal600;
  static const Color onPrimary = CcBaseColors.white100;
  static const Color primaryContainer = CcBaseColors.emerald500;
  static const Color darkPrimaryContainer = CcBaseColors.gray800;
  static const Color onPrimaryContainer = CcBaseColors.neutral100;
  static const Color primaryPressed = CcBaseColors.brand600;
  static const Color primaryGradientEnd = CcBaseColors.brand900;

  // ===========================================================================
  // BRAND GRADIENT BACKGROUND (semantic tokens for BgGradientWidget)
  // ===========================================================================
  // Light mode: faint primary tint fading into the light surface.
  static const Color gradientTop = CcBaseColors.teal600;
  static const Color gradientBottom = CcBaseColors.white100;

  // Dark mode: faint primary tint fading into the dark background.
  static const Color darkGradientTop = CcBaseColors.teal600;
  static const Color darkGradientBottom = CcBaseColors.gray950;

  // ===========================================================================
  // SECONDARY
  // ===========================================================================
  static const Color secondary = CcBaseColors.blue500;
  static const Color onSecondary = CcBaseColors.white100;
  static const Color secondaryContainer = CcBaseColors.blue700;
  static const Color onSecondaryContainer = CcBaseColors.white100;

  // ===========================================================================
  // STATUS & FEEDBACK
  // ===========================================================================
  static const Color success = CcBaseColors.successGreen;
  static const Color onSuccess = CcBaseColors.white100;

  static const Color warning = CcBaseColors.warningAmber;
  static const Color onWarning = CcBaseColors.neutral100;

  static const Color error = CcBaseColors.errorRed;
  static const Color onError = CcBaseColors.white100;

  static const Color info = CcBaseColors.infoBlue;
  static const Color onInfo = CcBaseColors.white100;

  static const Color investment = CcBaseColors.yellow600;
  static const Color debtLoan = CcBaseColors.violet600;

  // ===========================================================================
  // SURFACES & BACKGROUNDS
  // ===========================================================================

  // -- Light Mode
  static const Color background = CcBaseColors.white100;
  static const Color onBackground = CcBaseColors.gray900;

  static const Color surface = CcBaseColors.white100;
  static const Color onSurface = CcBaseColors.gray900;
  static const Color surfaceVariant = CcBaseColors.gray100;
  static const Color onSurfaceVariant = CcBaseColors.gray700;
  static const Color surfaceOverlay = CcBaseColors.gray200;

  // -- Dark Mode Specifics
  static const Color darkBackground = CcBaseColors.gray950;
  static const Color darkOnBackground = CcBaseColors.white100;
  static const Color darkSurface = CcBaseColors.gray900;
  static const Color darkOnSurface = CcBaseColors.white100;
  static const Color darkSurfaceVariant = CcBaseColors.gray800;
  static const Color darkOnSurfaceVariant = CcBaseColors.gray300;
  static const Color darkDivider = CcBaseColors.gray50;

  // ===========================================================================
  // CONTENT & UTILS
  // ===========================================================================
  static const Color highEmphasis = CcBaseColors.gray900;
  static const Color mediumEmphasis = CcBaseColors.gray700;
  static const Color body = CcBaseColors.gray700;
  static const Color disabled = CcBaseColors.gray400;
  static const Color hint = CcBaseColors.gray400;

  static const Color outline = CcBaseColors.gray300;
  static const Color outlineVariant = CcBaseColors.gray200;
  static const Color divider = CcBaseColors.gray100;

  // Legacy/Common Aliases
  static const Color blue = CcBaseColors.blue500;
  static const Color pink = CcBaseColors.brand500;
  static const Color transparent = CcBaseColors.transparent;

  // ===========================================================================
  // CATEGORY COLORS
  // ===========================================================================
  // ===========================================================================
  // CATEGORY COLORS — 1 màu / nhóm cha
  // ===========================================================================

  // Nhóm 1: Ăn uống & Cà phê — đỏ
  static const Color categoryFoodDrink = Color(0xFFDC2626);
  static const Color categoryCoffee = Color(0xFFDC2626);
  static const Color categoryWater = Color(0xFFDC2626);
  static const Color categoryEatOut = Color(0xFFDC2626);

  // Nhóm 2: Di chuyển — xanh dương
  static const Color categoryTaxi = Color(0xFF2563EB);
  static const Color categoryGas = Color(0xFF2563EB);
  static const Color categoryParking = Color(0xFF2563EB);
  static const Color categoryMaintenance = Color(0xFF2563EB);

  // Nhóm 3: Tiện ích — vàng hổ phách
  static const Color categoryElectricity = Color(0xFFF59E0B);
  static const Color categoryInternet = Color(0xFFF59E0B);
  static const Color categoryPhone = Color(0xFFF59E0B);

  // Nhóm 4: Nhà ở — xanh lá
  static const Color categoryRent = Color(0xFF16A34A);
  static const Color categoryFurniture = Color(0xFF16A34A);
  static const Color categoryLaundry = Color(0xFF16A34A);
  static const Color categoryMortgage = Color(0xFF16A34A);
  static const Color categoryCondoFee = Color(0xFF16A34A);

  // Nhóm 5: Y tế & Sức khỏe — xanh ngọc
  static const Color categoryDoctor = Color(0xFF0D9488);
  static const Color categoryMedicine = Color(0xFF0D9488);
  static const Color categoryHealthInsurance = Color(0xFF0D9488);
  static const Color categoryGym = Color(0xFF0D9488);

  // Nhóm 6: Giáo dục — tím indigo
  static const Color categoryTuition = Color(0xFF4F46E5);
  static const Color categoryBooks = Color(0xFF4F46E5);
  static const Color categoryCourses = Color(0xFF4F46E5);

  // Nhóm 7: Giải trí — hồng magenta
  static const Color categoryCinema = Color(0xFFDB2777);
  static const Color categoryTravel = Color(0xFFDB2777);
  static const Color categoryGaming = Color(0xFFDB2777);
  static const Color categoryEvents = Color(0xFFDB2777);

  // Nhóm 8: Mua sắm — cam
  static const Color categoryAppliances = Color(0xFFEA580C);
  static const Color categoryElectronics = Color(0xFFEA580C);
  static const Color categoryClothing = Color(0xFFEA580C);
  static const Color categoryCosmetics = Color(0xFFEA580C);

  // Nhóm 9: Trả nợ & Vay — đỏ mận
  static const Color categoryInstallment = Color(0xFF991B1B);
  static const Color categoryLoanInterest = Color(0xFF991B1B);

  // Nhóm 10: Bảo hiểm — navy
  static const Color categoryLifeInsurance = Color(0xFF1E3A8A);
  static const Color categoryVehicleInsurance = Color(0xFF1E3A8A);
  static const Color categoryHomeInsurance = Color(0xFF1E3A8A);

  // Nhóm 11: Quà tặng & Từ thiện — hồng rose
  static const Color categoryGifts = Color(0xFFE11D48);
  static const Color categoryCharity = Color(0xFFE11D48);

  // Nhóm 12: Chăm sóc cá nhân — hồng phấn
  static const Color categoryHaircut = Color(0xFFEC4899);
  static const Color categorySpa = Color(0xFFEC4899);
  static const Color categoryPersonalCareProduct = Color(0xFFEC4899);

  // Nhóm 13: Phí dịch vụ — xám xanh
  static const Color categoryBankFee = Color(0xFF475569);
  static const Color categoryCardFee = Color(0xFF475569);

  // Nhóm 14: Gia đình & Con cái — xanh trời pastel
  static const Color categoryMilkFormula = Color(0xFF38BDF8);
  static const Color categoryDiapers = Color(0xFF38BDF8);
  static const Color categoryBabyToys = Color(0xFF38BDF8);

  // Thu nhập chủ động — xanh lá tươi
  static const Color categoryIncomeSalary = Color(0xFF22C55E);
  static const Color categoryIncomeFreelance = Color(0xFF22C55E);
  static const Color categoryIncomeAllowance = Color(0xFF22C55E);

  // Thu nhập đầu tư — emerald
  static const Color categoryIncomeSavingsInterest = Color(0xFF059669);
  static const Color categoryIncomeDividends = Color(0xFF059669);
  static const Color categoryIncomeRental = Color(0xFF059669);
  static const Color categoryInvestment = Color(0xFF059669);

  // Thu nhập khác — vàng gold
  static const Color categoryIncomeBonus = Color(0xFFCA8A04);
  static const Color categoryIncomeGift = Color(0xFFCA8A04);
  static const Color categoryIncomeCashback = Color(0xFFCA8A04);
}
