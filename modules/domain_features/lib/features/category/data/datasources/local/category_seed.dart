import 'package:flutter/material.dart';
import 'package:message/cc_locale_keys.dart';
import 'package:theme/export_theme.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/category_group_entity.dart';
import '../../models/category_model.dart';

/// Life stage derived from the user's birth year.
enum AgeGroup { youngAdult, adult, mature }

/// Default categories + groups seeded into Hive on first launch.
class CategorySeed {
  CategorySeed._();

  /// Pseudo-group id kept for backwards-compat (no longer used in seed).
  static const String incomeGroupId = 'income';

  static const String incomeActiveGroupId = 'income_active';
  static const String incomeInvestGroupId = 'income_invest';
  static const String incomeOtherGroupId = 'income_other';

  static const String debtLoanGroupId = 'debt_loan';

  static const String investmentDefaultGroupId = 'investment_default';

  static const List<CategoryGroupEntity> investmentGroups = [
    CategoryGroupEntity(
      id: investmentDefaultGroupId,
      nameKey: CcLocaleKeys.category_investment_group_default,
    ),
  ];

  static const List<CategoryGroupEntity> debtLoanGroups = [
    CategoryGroupEntity(
      id: debtLoanGroupId,
      nameKey: CcLocaleKeys.category_debt_loan_settings_title,
    ),
  ];

  static const List<CategoryGroupEntity> incomeGroups = [
    CategoryGroupEntity(
      id: incomeActiveGroupId,
      nameKey: CcLocaleKeys.category_income_group_active,
    ),
    CategoryGroupEntity(
      id: incomeInvestGroupId,
      nameKey: CcLocaleKeys.category_income_group_invest,
    ),
    CategoryGroupEntity(
      id: incomeOtherGroupId,
      nameKey: CcLocaleKeys.category_income_group_other,
    ),
  ];

  static const List<CategoryGroupEntity> groups = [
    CategoryGroupEntity(id: '1', nameKey: 'Ăn uống & Cà phê'),
    CategoryGroupEntity(id: '2', nameKey: 'Di chuyển'),
    CategoryGroupEntity(id: '3', nameKey: 'Tiện ích'),
    CategoryGroupEntity(id: '4', nameKey: 'Nhà ở'),
    CategoryGroupEntity(id: '5', nameKey: 'Y tế & Sức khỏe'),
    CategoryGroupEntity(id: '6', nameKey: 'Giáo dục'),
    CategoryGroupEntity(id: '7', nameKey: 'Giải trí'),
    CategoryGroupEntity(id: '8', nameKey: 'Mua sắm'),
    // Group 9 (Trả nợ & Vay) removed - debt payments now properly classified as Debt/Loan type
    CategoryGroupEntity(id: '10', nameKey: 'Bảo hiểm'),
    CategoryGroupEntity(id: '11', nameKey: 'Quà tặng & Từ thiện'),
    CategoryGroupEntity(id: '12', nameKey: 'Chăm sóc cá nhân'),
    CategoryGroupEntity(id: '13', nameKey: 'Phí dịch vụ'),
    CategoryGroupEntity(id: '14', nameKey: 'Gia đình & Con cái'),
  ];

  static final List<CategoryModel> categories = [
    // Group 1: Ăn uống & Cà phê (reordered by usage frequency)
    CategoryModel(
      id: 'c1',
      nameKey: CcLocaleKeys.category_food_drink,
      iconCode: Icons.restaurant.codePoint,
      groupId: '1',
      colorValue: PrjColors.categoryFoodDrink.value,
    ),
    CategoryModel(
      id: 'c4',
      nameKey: CcLocaleKeys.category_eat_out,
      iconCode: Icons.dinner_dining.codePoint,
      groupId: '1',
      colorValue: PrjColors.categoryEatOut.value,
    ),
    CategoryModel(
      id: 'c2',
      nameKey: CcLocaleKeys.category_coffee,
      iconCode: Icons.local_cafe.codePoint,
      groupId: '1',
      colorValue: PrjColors.categoryCoffee.value,
    ),
    CategoryModel(
      id: 'c3',
      nameKey: CcLocaleKeys.category_water,
      iconCode: Icons.local_drink.codePoint,
      groupId: '1',
      colorValue: PrjColors.categoryWater.value,
    ),

    // Group 2: Di chuyển (reordered by usage frequency)
    CategoryModel(
      id: 'c6',
      nameKey: CcLocaleKeys.category_gas,
      iconCode: Icons.local_gas_station.codePoint,
      groupId: '2',
      colorValue: PrjColors.categoryGas.value,
    ),
    CategoryModel(
      id: 'c5',
      nameKey: CcLocaleKeys.category_taxi,
      iconCode: Icons.local_taxi.codePoint,
      groupId: '2',
      colorValue: PrjColors.categoryTaxi.value,
    ),
    CategoryModel(
      id: 'c7',
      nameKey: CcLocaleKeys.category_parking,
      iconCode: Icons.local_parking.codePoint,
      groupId: '2',
      colorValue: PrjColors.categoryParking.value,
    ),
    CategoryModel(
      id: 'c8',
      nameKey: CcLocaleKeys.category_maintenance,
      iconCode: Icons.car_repair.codePoint,
      groupId: '2',
      colorValue: PrjColors.categoryMaintenance.value,
    ),

    // Group 3: Tiện ích (reordered by usage frequency)
    CategoryModel(
      id: 'c11',
      nameKey: CcLocaleKeys.category_phone,
      iconCode: Icons.smartphone.codePoint,
      groupId: '3',
      colorValue: PrjColors.categoryPhone.value,
    ),
    CategoryModel(
      id: 'c9',
      nameKey: CcLocaleKeys.category_electricity,
      iconCode: Icons.bolt.codePoint,
      groupId: '3',
      colorValue: PrjColors.categoryElectricity.value,
    ),
    CategoryModel(
      id: 'c10',
      nameKey: CcLocaleKeys.category_internet,
      iconCode: Icons.wifi.codePoint,
      groupId: '3',
      colorValue: PrjColors.categoryInternet.value,
    ),

    // Group 4: Nhà ở (reordered by usage frequency)
    CategoryModel(
      id: 'c12',
      nameKey: CcLocaleKeys.category_rent,
      iconCode: Icons.house.codePoint,
      groupId: '4',
      colorValue: PrjColors.categoryRent.value,
    ),
    CategoryModel(
      id: 'c16',
      nameKey: CcLocaleKeys.category_condo_fee,
      iconCode: Icons.apartment.codePoint,
      groupId: '4',
      colorValue: PrjColors.categoryCondoFee.value,
    ),
    CategoryModel(
      id: 'c14',
      nameKey: CcLocaleKeys.category_laundry,
      iconCode: Icons.local_laundry_service.codePoint,
      groupId: '4',
      colorValue: PrjColors.categoryLaundry.value,
    ),
    CategoryModel(
      id: 'c13',
      nameKey: CcLocaleKeys.category_furniture,
      iconCode: Icons.chair.codePoint,
      groupId: '4',
      colorValue: PrjColors.categoryFurniture.value,
    ),
    // Mortgage moved to Debt/Loan type - it's a debt obligation, not housing expense

    // Group 5: Y tế & Sức khỏe (reordered by usage frequency)
    CategoryModel(
      id: 'c18',
      nameKey: CcLocaleKeys.category_medicine,
      iconCode: Icons.medication.codePoint,
      groupId: '5',
      colorValue: PrjColors.categoryMedicine.value,
    ),
    CategoryModel(
      id: 'c17',
      nameKey: CcLocaleKeys.category_doctor,
      iconCode: Icons.local_hospital.codePoint,
      groupId: '5',
      colorValue: PrjColors.categoryDoctor.value,
    ),
    CategoryModel(
      id: 'c20',
      nameKey: CcLocaleKeys.category_gym,
      iconCode: Icons.fitness_center.codePoint,
      groupId: '5',
      colorValue: PrjColors.categoryGym.value,
    ),
    CategoryModel(
      id: 'c19',
      nameKey: CcLocaleKeys.category_health_insurance,
      iconCode: Icons.health_and_safety.codePoint,
      groupId: '5',
      colorValue: PrjColors.categoryHealthInsurance.value,
    ),

    // Group 6: Giáo dục (reordered by usage frequency)
    CategoryModel(
      id: 'c21',
      nameKey: CcLocaleKeys.category_tuition,
      iconCode: Icons.school.codePoint,
      groupId: '6',
      colorValue: PrjColors.categoryTuition.value,
    ),
    CategoryModel(
      id: 'c23',
      nameKey: CcLocaleKeys.category_courses,
      iconCode: Icons.cast_for_education.codePoint,
      groupId: '6',
      colorValue: PrjColors.categoryCourses.value,
    ),
    CategoryModel(
      id: 'c22',
      nameKey: CcLocaleKeys.category_books,
      iconCode: Icons.menu_book.codePoint,
      groupId: '6',
      colorValue: PrjColors.categoryBooks.value,
    ),

    // Group 7: Giải trí (reordered by usage frequency)
    CategoryModel(
      id: 'c26',
      nameKey: CcLocaleKeys.category_gaming,
      iconCode: Icons.sports_esports.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryGaming.value,
    ),
    CategoryModel(
      id: 'c24',
      nameKey: CcLocaleKeys.category_cinema,
      iconCode: Icons.movie.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryCinema.value,
    ),
    CategoryModel(
      id: 'c27',
      nameKey: CcLocaleKeys.category_events,
      iconCode: Icons.event.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryEvents.value,
    ),
    CategoryModel(
      id: 'c25',
      nameKey: CcLocaleKeys.category_travel,
      iconCode: Icons.flight.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryTravel.value,
    ),

    // Group 8: Mua sắm (reordered by usage frequency)
    CategoryModel(
      id: 'c30',
      nameKey: CcLocaleKeys.category_clothing,
      iconCode: Icons.checkroom.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryClothing.value,
    ),
    CategoryModel(
      id: 'c29',
      nameKey: CcLocaleKeys.category_electronics,
      iconCode: Icons.devices.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryElectronics.value,
    ),
    CategoryModel(
      id: 'c31',
      nameKey: CcLocaleKeys.category_cosmetics,
      iconCode: Icons.face_retouching_natural.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryCosmetics.value,
    ),
    CategoryModel(
      id: 'c28',
      nameKey: CcLocaleKeys.category_appliances,
      iconCode: Icons.kitchen.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryAppliances.value,
    ),

    // Group 9: Trả nợ & Vay - MOVED to Debt/Loan type for proper financial classification

    // Group 10: Bảo hiểm
    CategoryModel(
      id: 'c34',
      nameKey: CcLocaleKeys.category_life_insurance,
      iconCode: Icons.favorite.codePoint,
      groupId: '10',
      colorValue: PrjColors.categoryLifeInsurance.value,
    ),
    CategoryModel(
      id: 'c35',
      nameKey: CcLocaleKeys.category_vehicle_insurance,
      iconCode: Icons.directions_car.codePoint,
      groupId: '10',
      colorValue: PrjColors.categoryVehicleInsurance.value,
    ),
    CategoryModel(
      id: 'c36',
      nameKey: CcLocaleKeys.category_home_insurance,
      iconCode: Icons.home.codePoint,
      groupId: '10',
      colorValue: PrjColors.categoryHomeInsurance.value,
    ),

    // Group 11: Quà tặng & Từ thiện
    CategoryModel(
      id: 'c37',
      nameKey: CcLocaleKeys.category_gifts,
      iconCode: Icons.card_giftcard.codePoint,
      groupId: '11',
      colorValue: PrjColors.categoryGifts.value,
    ),
    CategoryModel(
      id: 'c38',
      nameKey: CcLocaleKeys.category_charity,
      iconCode: Icons.volunteer_activism.codePoint,
      groupId: '11',
      colorValue: PrjColors.categoryCharity.value,
    ),

    // Group 12: Chăm sóc cá nhân (reordered by usage frequency)
    CategoryModel(
      id: 'c41',
      nameKey: CcLocaleKeys.category_personal_care_product,
      iconCode: Icons.soap.codePoint,
      groupId: '12',
      colorValue: PrjColors.categoryPersonalCareProduct.value,
    ),
    CategoryModel(
      id: 'c39',
      nameKey: CcLocaleKeys.category_haircut,
      iconCode: Icons.content_cut.codePoint,
      groupId: '12',
      colorValue: PrjColors.categoryHaircut.value,
    ),
    CategoryModel(
      id: 'c40',
      nameKey: CcLocaleKeys.category_spa,
      iconCode: Icons.spa.codePoint,
      groupId: '12',
      colorValue: PrjColors.categorySpa.value,
    ),

    // Group 13: Phí dịch vụ
    CategoryModel(
      id: 'c42',
      nameKey: CcLocaleKeys.category_bank_fee,
      iconCode: Icons.account_balance.codePoint,
      groupId: '13',
      colorValue: PrjColors.categoryBankFee.value,
    ),
    CategoryModel(
      id: 'c43',
      nameKey: CcLocaleKeys.category_card_fee,
      iconCode: Icons.credit_score.codePoint,
      groupId: '13',
      colorValue: PrjColors.categoryCardFee.value,
    ),

    // Group 14: Gia đình & Con cái — disabled by default
    CategoryModel(
      id: 'c44',
      nameKey: CcLocaleKeys.category_milk_formula,
      iconCode: Icons.baby_changing_station.codePoint,
      groupId: '14',
      isEnabled: false,
      colorValue: PrjColors.categoryMilkFormula.value,
    ),
    CategoryModel(
      id: 'c45',
      nameKey: CcLocaleKeys.category_diapers,
      iconCode: Icons.child_care.codePoint,
      groupId: '14',
      isEnabled: false,
      colorValue: PrjColors.categoryDiapers.value,
    ),
    CategoryModel(
      id: 'c46',
      nameKey: CcLocaleKeys.category_baby_toys,
      iconCode: Icons.toys.codePoint,
      groupId: '14',
      isEnabled: false,
      colorValue: PrjColors.categoryBabyToys.value,
    ),

    // Income — Thu nhập chủ động (reordered by importance/frequency)
    CategoryModel(
      id: 'i1',
      nameKey: CcLocaleKeys.category_income_salary,
      iconCode: Icons.business_center.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeSalary.value,
    ),
    CategoryModel(
      id: 'i2',
      nameKey: CcLocaleKeys.category_income_freelance,
      iconCode: Icons.laptop_mac.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeFreelance.value,
    ),
    CategoryModel(
      id: 'i3',
      nameKey: CcLocaleKeys.category_income_allowance,
      iconCode: Icons.volunteer_activism.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeAllowance.value,
    ),

    // Income — Thu nhập đầu tư (reordered by market popularity)
    CategoryModel(
      id: 'i4',
      nameKey: CcLocaleKeys.category_income_savings_interest,
      iconCode: Icons.account_balance.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeSavingsInterest.value,
    ),
    CategoryModel(
      id: 'i5',
      nameKey: CcLocaleKeys.category_income_dividends,
      iconCode: Icons.pie_chart.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeDividends.value,
    ),
    CategoryModel(
      id: 'i6',
      nameKey: CcLocaleKeys.category_income_rental,
      iconCode: Icons.home.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeRental.value,
    ),

    // Income — Thu nhập khác (reordered by usage frequency)
    CategoryModel(
      id: 'i9',
      nameKey: CcLocaleKeys.category_income_cashback,
      iconCode: Icons.replay.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeCashback.value,
    ),
    CategoryModel(
      id: 'i7',
      nameKey: CcLocaleKeys.category_income_bonus,
      iconCode: Icons.card_giftcard.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeBonus.value,
    ),
    CategoryModel(
      id: 'i8',
      nameKey: CcLocaleKeys.category_income_gift,
      iconCode: Icons.favorite.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeGift.value,
    ),

    // Debt & Loan - Borrowing (Debt) - reordered by importance
    CategoryModel(
      id: 'd3',
      nameKey: CcLocaleKeys.category_debt_mortgage,
      iconCode: Icons.home.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      id: 'd4',
      nameKey: CcLocaleKeys.category_debt_credit_card,
      iconCode: Icons.credit_card.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      id: 'd2',
      nameKey: CcLocaleKeys.category_debt_bank_borrow,
      iconCode: Icons.account_balance.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      id: 'd1',
      nameKey: CcLocaleKeys.category_debt_personal_borrow,
      iconCode: Icons.person_outline.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      id: 'd5',
      nameKey: CcLocaleKeys.category_debt_installment,
      iconCode: Icons.shopping_cart_checkout.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.categoryInstallment.value,
    ),

    // Debt & Loan - Debt Payments (moved from Expense Group 9) - reordered by importance
    CategoryModel(
      id: 'c15',
      nameKey: CcLocaleKeys.category_mortgage,
      iconCode: Icons.account_balance.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.categoryMortgage.value,
    ),
    CategoryModel(
      id: 'c33',
      nameKey: CcLocaleKeys.category_loan_interest,
      iconCode: Icons.account_balance_wallet.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.categoryLoanInterest.value,
    ),
    CategoryModel(
      id: 'c32',
      nameKey: CcLocaleKeys.category_installment,
      iconCode: Icons.credit_card.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.categoryInstallment.value,
    ),

    // Debt & Loan — Cho vay
    CategoryModel(
      id: 'd6',
      nameKey: CcLocaleKeys.category_debt_personal_lend,
      iconCode: Icons.handshake.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.secondary.value,
    ),
    CategoryModel(
      id: 'd7',
      nameKey: CcLocaleKeys.category_debt_other,
      iconCode: Icons.more_horiz.codePoint,
      groupId: debtLoanGroupId,
      type: CategoryType.debtLoan,
      colorValue: PrjColors.mediumEmphasis.value,
    ),

    // Investment - reordered by market popularity
    CategoryModel(
      id: 'inv1',
      nameKey: CcLocaleKeys.category_investment_stock,
      iconCode: Icons.show_chart.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv2',
      nameKey: CcLocaleKeys.category_investment_fund,
      iconCode: Icons.pie_chart_outline.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv4',
      nameKey: CcLocaleKeys.category_investment_term_deposit,
      iconCode: Icons.lock_clock.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv6',
      nameKey: CcLocaleKeys.category_investment_real_estate,
      iconCode: Icons.domain.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv5',
      nameKey: CcLocaleKeys.category_investment_gold,
      iconCode: Icons.savings.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv7',
      nameKey: CcLocaleKeys.category_investment_crypto,
      iconCode: Icons.currency_bitcoin.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv3',
      nameKey: CcLocaleKeys.category_investment_bond,
      iconCode: Icons.description.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv8',
      nameKey: CcLocaleKeys.category_investment_business,
      iconCode: Icons.storefront.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv9',
      nameKey: CcLocaleKeys.category_investment_linked_insurance,
      iconCode: Icons.health_and_safety.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv10',
      nameKey: CcLocaleKeys.category_investment_other,
      iconCode: Icons.more_horiz.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
  ];

  /// Computes the life stage from [birthYear]:
  /// - [youngAdult]: under 25 (single, no children)
  /// - [adult]: 25–39 (transitional)
  /// - [mature]: 40+ (settled family / career)
  static AgeGroup? ageGroup(int? birthYear) {
    if (birthYear == null) return null;
    final age = DateTime.now().year - birthYear;
    if (age < 25) return AgeGroup.youngAdult;
    if (age < 40) return AgeGroup.adult;
    return AgeGroup.mature;
  }

  /// Whether [birthYear] indicates the user is under 25 years old.
  static bool isYoungAdult(int? birthYear) =>
      ageGroup(birthYear) == AgeGroup.youngAdult;

  /// Default-on expense category `nameKey`s per life stage. Categories outside
  /// these sets are left untouched.
  static const Map<AgeGroup, List<String>> defaultExpenseCategoryKeys = {
    AgeGroup.youngAdult: [
      CcLocaleKeys.category_food_drink,
      CcLocaleKeys.category_coffee,
      CcLocaleKeys.category_water,
      CcLocaleKeys.category_eat_out,
      CcLocaleKeys.category_taxi,
      CcLocaleKeys.category_gas,
      CcLocaleKeys.category_parking,
      CcLocaleKeys.category_maintenance,
      CcLocaleKeys.category_electricity,
      CcLocaleKeys.category_internet,
      CcLocaleKeys.category_phone,
      CcLocaleKeys.category_rent,
      CcLocaleKeys.category_furniture,
      CcLocaleKeys.category_laundry,
      CcLocaleKeys.category_gym,
      CcLocaleKeys.category_doctor,
      CcLocaleKeys.category_medicine,
      CcLocaleKeys.category_tuition,
      CcLocaleKeys.category_courses,
      CcLocaleKeys.category_cinema,
      CcLocaleKeys.category_travel,
      CcLocaleKeys.category_gaming,
      CcLocaleKeys.category_events,
      CcLocaleKeys.category_electronics,
      CcLocaleKeys.category_clothing,
      CcLocaleKeys.category_cosmetics,
      // category_installment removed - now classified as Debt/Loan type
      CcLocaleKeys.category_vehicle_insurance,
      CcLocaleKeys.category_gifts,
      CcLocaleKeys.category_haircut,
      CcLocaleKeys.category_spa,
      CcLocaleKeys.category_personal_care_product,
      CcLocaleKeys.category_bank_fee,
      CcLocaleKeys.category_card_fee,
    ],
    AgeGroup.adult: [
      CcLocaleKeys.category_food_drink,
      CcLocaleKeys.category_coffee,
      CcLocaleKeys.category_water,
      CcLocaleKeys.category_eat_out,
      CcLocaleKeys.category_taxi,
      CcLocaleKeys.category_gas,
      CcLocaleKeys.category_parking,
      CcLocaleKeys.category_maintenance,
      CcLocaleKeys.category_electricity,
      CcLocaleKeys.category_internet,
      CcLocaleKeys.category_phone,
      CcLocaleKeys.category_rent,
      // category_mortgage removed - now classified as Debt/Loan type
      CcLocaleKeys.category_furniture,
      CcLocaleKeys.category_laundry,
      CcLocaleKeys.category_condo_fee,
      CcLocaleKeys.category_doctor,
      CcLocaleKeys.category_medicine,
      CcLocaleKeys.category_health_insurance,
      CcLocaleKeys.category_gym,
      CcLocaleKeys.category_courses,
      CcLocaleKeys.category_cinema,
      CcLocaleKeys.category_travel,
      CcLocaleKeys.category_events,
      CcLocaleKeys.category_appliances,
      CcLocaleKeys.category_electronics,
      CcLocaleKeys.category_clothing,
      CcLocaleKeys.category_cosmetics,
      // category_installment removed - now classified as Debt/Loan type
      // category_loan_interest removed - now classified as Debt/Loan type
      CcLocaleKeys.category_vehicle_insurance,
      CcLocaleKeys.category_life_insurance,
      CcLocaleKeys.category_gifts,
      CcLocaleKeys.category_haircut,
      CcLocaleKeys.category_spa,
      CcLocaleKeys.category_personal_care_product,
      CcLocaleKeys.category_bank_fee,
      CcLocaleKeys.category_card_fee,
    ],
    AgeGroup.mature: [
      CcLocaleKeys.category_food_drink,
      CcLocaleKeys.category_water,
      CcLocaleKeys.category_eat_out,
      CcLocaleKeys.category_gas,
      CcLocaleKeys.category_maintenance,
      CcLocaleKeys.category_parking,
      CcLocaleKeys.category_electricity,
      CcLocaleKeys.category_internet,
      CcLocaleKeys.category_phone,
      CcLocaleKeys.category_rent,
      // category_mortgage removed - now classified as Debt/Loan type
      CcLocaleKeys.category_furniture,
      CcLocaleKeys.category_laundry,
      CcLocaleKeys.category_condo_fee,
      CcLocaleKeys.category_doctor,
      CcLocaleKeys.category_medicine,
      CcLocaleKeys.category_health_insurance,
      CcLocaleKeys.category_gym,
      CcLocaleKeys.category_tuition,
      CcLocaleKeys.category_books,
      CcLocaleKeys.category_courses,
      CcLocaleKeys.category_travel,
      CcLocaleKeys.category_appliances,
      CcLocaleKeys.category_electronics,
      CcLocaleKeys.category_clothing,
      // category_installment removed - now classified as Debt/Loan type
      // category_loan_interest removed - now classified as Debt/Loan type
      CcLocaleKeys.category_vehicle_insurance,
      CcLocaleKeys.category_life_insurance,
      CcLocaleKeys.category_home_insurance,
      CcLocaleKeys.category_gifts,
      CcLocaleKeys.category_charity,
      CcLocaleKeys.category_haircut,
      CcLocaleKeys.category_spa,
      CcLocaleKeys.category_personal_care_product,
      CcLocaleKeys.category_bank_fee,
      CcLocaleKeys.category_card_fee,
    ],
  };

  /// Default-on income category `nameKey`s per life stage.
  static const Map<AgeGroup, List<String>> defaultIncomeCategoryKeys = {
    AgeGroup.youngAdult: [
      CcLocaleKeys.category_income_salary,
      CcLocaleKeys.category_income_freelance,
      CcLocaleKeys.category_income_allowance,
      CcLocaleKeys.category_income_bonus,
      CcLocaleKeys.category_income_cashback,
    ],
    AgeGroup.adult: [
      CcLocaleKeys.category_income_salary,
      CcLocaleKeys.category_income_freelance,
      CcLocaleKeys.category_income_allowance,
      CcLocaleKeys.category_income_savings_interest,
      CcLocaleKeys.category_income_dividends,
      CcLocaleKeys.category_income_rental,
      CcLocaleKeys.category_income_bonus,
      CcLocaleKeys.category_income_gift,
      CcLocaleKeys.category_income_cashback,
    ],
    AgeGroup.mature: [
      CcLocaleKeys.category_income_salary,
      CcLocaleKeys.category_income_allowance,
      CcLocaleKeys.category_income_savings_interest,
      CcLocaleKeys.category_income_dividends,
      CcLocaleKeys.category_income_rental,
      CcLocaleKeys.category_income_bonus,
      CcLocaleKeys.category_income_gift,
    ],
  };
}
