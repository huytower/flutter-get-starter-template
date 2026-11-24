import 'package:domain_features/core/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';
import 'package:message/prj_locale_keys.dart';
import 'package:theme/export_theme.dart';

import '../../../domain/entities/category_group_entity.dart';
import '../../models/category_model.dart';

/// Life stage derived from the user's birth year.
enum AgeGroup { youngAdult, adult, midLife, mature }

/// Default categories + groups seeded into Hive on first launch.
class CategorySeed {
  CategorySeed._();

  /// Pseudo-group id kept for backwards-compat (no longer used in seed).
  static const String incomeGroupId = 'income';

  static const String incomeActiveGroupId = 'income_active';
  static const String incomeInvestGroupId = 'income_invest';
  static const String incomeOtherGroupId = 'income_other';

  static const String liabilityBorrowGroupId = 'debt_loan_borrow';
  static const String debtLoanLendGroupId = 'debt_loan_lend';

  static const String investmentDefaultGroupId = 'investment_default';

  static const List<CategoryGroupEntity> investmentGroups = [
    CategoryGroupEntity(
      id: investmentDefaultGroupId,
      nameKey: PrjLocaleKeys.category_investment_group_default,
    ),
  ];

  static const List<CategoryGroupEntity> liabilityGroups = [
    CategoryGroupEntity(
      id: liabilityBorrowGroupId,
      nameKey: PrjLocaleKeys.category_debt_group_borrow,
    ),
    CategoryGroupEntity(
      id: debtLoanLendGroupId,
      nameKey: PrjLocaleKeys.category_debt_group_lend,
    ),
  ];

  static const List<CategoryGroupEntity> incomeGroups = [
    CategoryGroupEntity(
      id: incomeActiveGroupId,
      nameKey: PrjLocaleKeys.category_income_group_active,
    ),
    CategoryGroupEntity(
      id: incomeInvestGroupId,
      nameKey: PrjLocaleKeys.category_income_group_invest,
    ),
    CategoryGroupEntity(
      id: incomeOtherGroupId,
      nameKey: PrjLocaleKeys.category_income_group_other,
    ),
  ];

  static const List<CategoryGroupEntity> groups = [
    CategoryGroupEntity(
      id: '1',
      nameKey: PrjLocaleKeys.category_group_food_drink,
    ),
    CategoryGroupEntity(
      id: '2',
      nameKey: PrjLocaleKeys.category_group_transport,
    ),
    CategoryGroupEntity(
      id: '3',
      nameKey: PrjLocaleKeys.category_group_utilities,
    ),
    CategoryGroupEntity(id: '8', nameKey: PrjLocaleKeys.category_group_shopping),
    CategoryGroupEntity(id: '4', nameKey: PrjLocaleKeys.category_group_housing),
    CategoryGroupEntity(id: '5', nameKey: PrjLocaleKeys.category_group_health),
    CategoryGroupEntity(
      id: '12',
      nameKey: PrjLocaleKeys.category_group_personal_care,
    ),
    CategoryGroupEntity(
      id: '7',
      nameKey: PrjLocaleKeys.category_group_entertainment,
    ),
    CategoryGroupEntity(id: '11', nameKey: PrjLocaleKeys.category_group_gifts),
    CategoryGroupEntity(
      id: '6',
      nameKey: PrjLocaleKeys.category_group_education,
    ),
    CategoryGroupEntity(
      id: '10',
      nameKey: PrjLocaleKeys.category_group_insurance,
    ),
    CategoryGroupEntity(
      id: '13',
      nameKey: PrjLocaleKeys.category_group_service_fees,
    ),
    CategoryGroupEntity(id: '14', nameKey: PrjLocaleKeys.category_group_family),
  ];

  static final List<CategoryModel> categories = [
    // Group 1: Ăn uống & Cà phê
    CategoryModel(
      id: 'c1',
      nameKey: PrjLocaleKeys.category_food_drink,
      iconCode: Icons.restaurant.codePoint,
      groupId: '1',
      colorValue: PrjColors.categoryFoodDrink.value,
    ),

    // Group 2: Di chuyển
    CategoryModel(
      id: 'c6',
      nameKey: PrjLocaleKeys.category_gas,
      iconCode: Icons.local_gas_station.codePoint,
      groupId: '2',
      colorValue: PrjColors.categoryGas.value,
    ),
    CategoryModel(
      id: 'c5',
      nameKey: PrjLocaleKeys.category_taxi,
      iconCode: Icons.local_taxi.codePoint,
      groupId: '2',
      colorValue: PrjColors.categoryTaxi.value,
    ),
    CategoryModel(
      id: 'c7',
      nameKey: PrjLocaleKeys.category_parking,
      iconCode: Icons.local_parking.codePoint,
      groupId: '2',
      colorValue: PrjColors.categoryParking.value,
    ),
    CategoryModel(
      id: 'c8',
      nameKey: PrjLocaleKeys.category_maintenance,
      iconCode: Icons.car_repair.codePoint,
      groupId: '2',
      colorValue: PrjColors.categoryMaintenance.value,
    ),

    // Group 3: Tiện ích
    CategoryModel(
      id: 'c11',
      nameKey: PrjLocaleKeys.category_phone,
      iconCode: Icons.smartphone.codePoint,
      groupId: '3',
      colorValue: PrjColors.categoryPhone.value,
    ),
    CategoryModel(
      id: 'c9',
      nameKey: PrjLocaleKeys.category_electricity,
      iconCode: Icons.bolt.codePoint,
      groupId: '3',
      colorValue: PrjColors.categoryElectricity.value,
    ),
    CategoryModel(
      id: 'c50',
      nameKey: PrjLocaleKeys.category_water,
      iconCode: Icons.water_drop.codePoint,
      groupId: '3',
      colorValue: PrjColors.categoryElectricity.value,
    ),
    CategoryModel(
      id: 'c10',
      nameKey: PrjLocaleKeys.category_internet,
      iconCode: Icons.wifi.codePoint,
      groupId: '3',
      colorValue: PrjColors.categoryInternet.value,
    ),

    // Group 8: Mua sắm (Moved up because of high frequency)
    CategoryModel(
      id: 'c47',
      nameKey: PrjLocaleKeys.category_market_supermarket,
      iconCode: Icons.storefront.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryAppliances.value,
    ),
    CategoryModel(
      id: 'c30',
      nameKey: PrjLocaleKeys.category_clothing,
      iconCode: Icons.checkroom.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryClothing.value,
    ),
    CategoryModel(
      id: 'c29',
      nameKey: PrjLocaleKeys.category_electronics,
      iconCode: Icons.devices.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryElectronics.value,
    ),
    CategoryModel(
      id: 'c31',
      nameKey: PrjLocaleKeys.category_cosmetics,
      iconCode: Icons.face_retouching_natural.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryCosmetics.value,
    ),
    CategoryModel(
      id: 'c28',
      nameKey: PrjLocaleKeys.category_appliances,
      iconCode: Icons.kitchen.codePoint,
      groupId: '8',
      colorValue: PrjColors.categoryAppliances.value,
    ),

    // Group 4: Nhà ở
    CategoryModel(
      id: 'c12',
      nameKey: PrjLocaleKeys.category_rent,
      iconCode: Icons.house.codePoint,
      groupId: '4',
      colorValue: PrjColors.categoryRent.value,
    ),
    CategoryModel(
      id: 'c16',
      nameKey: PrjLocaleKeys.category_condo_fee,
      iconCode: Icons.apartment.codePoint,
      groupId: '4',
      colorValue: PrjColors.categoryCondoFee.value,
    ),
    CategoryModel(
      id: 'c14',
      nameKey: PrjLocaleKeys.category_laundry,
      iconCode: Icons.local_laundry_service.codePoint,
      groupId: '4',
      colorValue: PrjColors.categoryLaundry.value,
    ),
    CategoryModel(
      id: 'c13',
      nameKey: PrjLocaleKeys.category_furniture,
      iconCode: Icons.chair.codePoint,
      groupId: '4',
      colorValue: PrjColors.categoryFurniture.value,
    ),

    // Group 5: Y tế & Sức khỏe
    CategoryModel(
      id: 'c18',
      nameKey: PrjLocaleKeys.category_medicine,
      iconCode: Icons.medication.codePoint,
      groupId: '5',
      colorValue: PrjColors.categoryMedicine.value,
    ),
    CategoryModel(
      id: 'c17',
      nameKey: PrjLocaleKeys.category_doctor,
      iconCode: Icons.local_hospital.codePoint,
      groupId: '5',
      colorValue: PrjColors.categoryDoctor.value,
    ),
    CategoryModel(
      id: 'c20',
      nameKey: PrjLocaleKeys.category_gym,
      iconCode: Icons.fitness_center.codePoint,
      groupId: '5',
      colorValue: PrjColors.categoryGym.value,
    ),
    CategoryModel(
      id: 'c19',
      nameKey: PrjLocaleKeys.category_health_insurance,
      iconCode: Icons.health_and_safety.codePoint,
      groupId: '5',
      colorValue: PrjColors.categoryHealthInsurance.value,
    ),

    // Group 12: Chăm sóc cá nhân
    CategoryModel(
      id: 'c41',
      nameKey: PrjLocaleKeys.category_personal_care_product,
      iconCode: Icons.soap.codePoint,
      groupId: '12',
      colorValue: PrjColors.categoryPersonalCareProduct.value,
    ),
    CategoryModel(
      id: 'c39',
      nameKey: PrjLocaleKeys.category_haircut,
      iconCode: Icons.content_cut.codePoint,
      groupId: '12',
      colorValue: PrjColors.categoryHaircut.value,
    ),
    CategoryModel(
      id: 'c40',
      nameKey: PrjLocaleKeys.category_spa,
      iconCode: Icons.spa.codePoint,
      groupId: '12',
      colorValue: PrjColors.categorySpa.value,
    ),

    // Group 7: Giải trí
    CategoryModel(
      id: 'c26',
      nameKey: PrjLocaleKeys.category_gaming,
      iconCode: Icons.sports_esports.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryGaming.value,
    ),
    CategoryModel(
      id: 'c24',
      nameKey: PrjLocaleKeys.category_cinema,
      iconCode: Icons.movie.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryCinema.value,
    ),
    CategoryModel(
      id: 'c27',
      nameKey: PrjLocaleKeys.category_events,
      iconCode: Icons.event.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryEvents.value,
    ),
    CategoryModel(
      id: 'c25',
      nameKey: PrjLocaleKeys.category_travel,
      iconCode: Icons.flight.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryTravel.value,
    ),
    CategoryModel(
      id: 'c49',
      nameKey: PrjLocaleKeys.category_leisure,
      iconCode: Icons.fort_rounded.codePoint,
      groupId: '7',
      colorValue: PrjColors.categoryTravel.value,
    ),

    // Group 11: Quà tặng & Từ thiện
    CategoryModel(
      id: 'c37',
      nameKey: PrjLocaleKeys.category_gifts,
      iconCode: Icons.card_giftcard.codePoint,
      groupId: '11',
      colorValue: PrjColors.categoryGifts.value,
    ),
    CategoryModel(
      id: 'c38',
      nameKey: PrjLocaleKeys.category_charity,
      iconCode: Icons.volunteer_activism.codePoint,
      groupId: '11',
      colorValue: PrjColors.categoryCharity.value,
    ),
    CategoryModel(
      id: 'c48',
      nameKey: PrjLocaleKeys.category_religious,
      iconCode: Icons.church.codePoint,
      groupId: '11',
      colorValue: PrjColors.categoryCharity.value,
    ),

    // Group 6: Giáo dục
    CategoryModel(
      id: 'c21',
      nameKey: PrjLocaleKeys.category_tuition,
      iconCode: Icons.school.codePoint,
      groupId: '6',
      colorValue: PrjColors.categoryTuition.value,
    ),
    CategoryModel(
      id: 'c23',
      nameKey: PrjLocaleKeys.category_courses,
      iconCode: Icons.cast_for_education.codePoint,
      groupId: '6',
      colorValue: PrjColors.categoryCourses.value,
    ),
    CategoryModel(
      id: 'c22',
      nameKey: PrjLocaleKeys.category_books,
      iconCode: Icons.menu_book.codePoint,
      groupId: '6',
      colorValue: PrjColors.categoryBooks.value,
    ),

    // Group 10: Bảo hiểm
    CategoryModel(
      id: 'c34',
      nameKey: PrjLocaleKeys.category_life_insurance,
      iconCode: Icons.favorite.codePoint,
      groupId: '10',
      colorValue: PrjColors.categoryLifeInsurance.value,
    ),
    CategoryModel(
      id: 'c35',
      nameKey: PrjLocaleKeys.category_vehicle_insurance,
      iconCode: Icons.directions_car.codePoint,
      groupId: '10',
      colorValue: PrjColors.categoryVehicleInsurance.value,
    ),
    CategoryModel(
      id: 'c36',
      nameKey: PrjLocaleKeys.category_home_insurance,
      iconCode: Icons.home.codePoint,
      groupId: '10',
      colorValue: PrjColors.categoryHomeInsurance.value,
    ),

    // Group 13: Phí dịch vụ
    CategoryModel(
      id: 'c42',
      nameKey: PrjLocaleKeys.category_bank_fee,
      iconCode: Icons.account_balance.codePoint,
      groupId: '13',
      colorValue: PrjColors.categoryBankFee.value,
    ),
    CategoryModel(
      id: 'c43',
      nameKey: PrjLocaleKeys.category_card_fee,
      iconCode: Icons.credit_score.codePoint,
      groupId: '13',
      colorValue: PrjColors.categoryCardFee.value,
    ),

    // Group 14: Gia đình & Con cái
    CategoryModel(
      id: 'c44',
      nameKey: PrjLocaleKeys.category_milk_formula,
      iconCode: Icons.baby_changing_station.codePoint,
      groupId: '14',
      hasEnabled: false,
      colorValue: PrjColors.categoryMilkFormula.value,
    ),
    CategoryModel(
      id: 'c45',
      nameKey: PrjLocaleKeys.category_diapers,
      iconCode: Icons.child_care.codePoint,
      groupId: '14',
      hasEnabled: false,
      colorValue: PrjColors.categoryDiapers.value,
    ),
    CategoryModel(
      id: 'c46',
      nameKey: PrjLocaleKeys.category_baby_toys,
      iconCode: Icons.toys.codePoint,
      groupId: '14',
      hasEnabled: false,
      colorValue: PrjColors.categoryBabyToys.value,
    ),

    // Income — Thu nhập chủ động (reordered by importance/frequency)
    CategoryModel(
      id: 'i1',
      nameKey: PrjLocaleKeys.category_income_salary,
      iconCode: Icons.business_center.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeSalary.value,
    ),
    CategoryModel(
      id: 'i2',
      nameKey: PrjLocaleKeys.category_income_freelance,
      iconCode: Icons.laptop_mac.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeFreelance.value,
    ),
    CategoryModel(
      id: 'i3',
      nameKey: PrjLocaleKeys.category_income_allowance,
      iconCode: Icons.volunteer_activism.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeAllowance.value,
    ),

    // Income — Thu nhập đầu tư (reordered by market popularity)
    CategoryModel(
      id: 'i4',
      nameKey: PrjLocaleKeys.category_income_savings_interest,
      iconCode: Icons.account_balance.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeSavingsInterest.value,
    ),
    CategoryModel(
      id: 'i5',
      nameKey: PrjLocaleKeys.category_income_dividends,
      iconCode: Icons.pie_chart.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeDividends.value,
    ),
    CategoryModel(
      id: 'i6',
      nameKey: PrjLocaleKeys.category_income_rental,
      iconCode: Icons.home.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeRental.value,
    ),

    // Income — Thu nhập khác (reordered by usage frequency)
    CategoryModel(
      id: 'i9',
      nameKey: PrjLocaleKeys.category_income_cashback,
      iconCode: Icons.replay.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeCashback.value,
    ),
    CategoryModel(
      id: 'i7',
      nameKey: PrjLocaleKeys.category_income_bonus,
      iconCode: Icons.card_giftcard.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeBonus.value,
    ),
    CategoryModel(
      id: 'i8',
      nameKey: PrjLocaleKeys.category_income_gift,
      iconCode: Icons.favorite.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
      colorValue: PrjColors.categoryIncomeGift.value,
    ),

    // Debt & Loan — Đi vay (Borrowing)
    CategoryModel(
      id: 'd1',
      nameKey: PrjLocaleKeys.category_debt_personal_borrow,
      iconCode: Icons.person_outline.codePoint,
      groupId: liabilityBorrowGroupId,
      type: CategoryType.liability,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      id: 'd2',
      nameKey: PrjLocaleKeys.category_debt_bank_borrow,
      iconCode: Icons.account_balance.codePoint,
      groupId: liabilityBorrowGroupId,
      type: CategoryType.liability,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      id: 'd3',
      nameKey: PrjLocaleKeys.category_debt_mortgage,
      iconCode: Icons.home.codePoint,
      groupId: liabilityBorrowGroupId,
      type: CategoryType.liability,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      id: 'd4',
      nameKey: PrjLocaleKeys.category_debt_credit_card,
      iconCode: Icons.credit_card.codePoint,
      groupId: liabilityBorrowGroupId,
      type: CategoryType.liability,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      id: 'd5',
      nameKey: PrjLocaleKeys.category_debt_installment,
      iconCode: Icons.shopping_cart_checkout.codePoint,
      groupId: liabilityBorrowGroupId,
      type: CategoryType.liability,
      colorValue: PrjColors.categoryInstallment.value,
    ),
    CategoryModel(
      // NOTE: intentionally not 'd7' — before the borrow/lend group split,
      // 'd7' was a single generic "Debt Other" shared by both borrow and
      // lend transactions. Reusing it here for the borrow-only "Other"
      // would let CategoryLocalDataSource's id-matched seed sync silently
      // reclassify existing users' lend-side 'd7' transactions as borrow.
      // 'd7' is retired via staleIds cleanup below instead.
      id: 'd9',
      nameKey: PrjLocaleKeys.category_debt_other,
      iconCode: Icons.more_horiz.codePoint,
      groupId: liabilityBorrowGroupId,
      type: CategoryType.liability,
      colorValue: PrjColors.mediumEmphasis.value,
    ),

    // Debt & Loan — Cho vay (Lending)
    CategoryModel(
      id: 'd6',
      nameKey: PrjLocaleKeys.category_debt_personal_lend,
      iconCode: Icons.handshake.codePoint,
      groupId: debtLoanLendGroupId,
      type: CategoryType.liability,
      colorValue: PrjColors.secondary.value,
    ),
    CategoryModel(
      id: 'd8',
      nameKey: PrjLocaleKeys.category_debt_other_lend,
      iconCode: Icons.more_horiz.codePoint,
      groupId: debtLoanLendGroupId,
      type: CategoryType.liability,
      colorValue: PrjColors.mediumEmphasis.value,
    ),

    // Investment - reordered by market popularity
    CategoryModel(
      id: 'inv1',
      nameKey: PrjLocaleKeys.category_investment_stock,
      iconCode: Icons.show_chart.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv2',
      nameKey: PrjLocaleKeys.category_investment_fund,
      iconCode: Icons.pie_chart_outline.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv4',
      nameKey: PrjLocaleKeys.category_investment_term_deposit,
      iconCode: Icons.lock_clock.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv6',
      nameKey: PrjLocaleKeys.category_investment_real_estate,
      iconCode: Icons.domain.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv5',
      nameKey: PrjLocaleKeys.category_investment_gold,
      iconCode: Icons.savings.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv7',
      nameKey: PrjLocaleKeys.category_investment_crypto,
      iconCode: Icons.currency_bitcoin.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv3',
      nameKey: PrjLocaleKeys.category_investment_bond,
      iconCode: Icons.description.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv8',
      nameKey: PrjLocaleKeys.category_investment_business,
      iconCode: Icons.storefront.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv9',
      nameKey: PrjLocaleKeys.category_investment_linked_insurance,
      iconCode: Icons.health_and_safety.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
    CategoryModel(
      id: 'inv10',
      nameKey: PrjLocaleKeys.category_investment_other,
      iconCode: Icons.more_horiz.codePoint,
      groupId: investmentDefaultGroupId,
      type: CategoryType.investment,
      colorValue: PrjColors.categoryInvestment.value,
    ),
  ];

  /// Computes the life stage from [birthYear]:
  /// - [youngAdult]: under 23
  /// - [adult]: 23–30
  /// - [midLife]: 31–45
  /// - [mature]: 45+
  static AgeGroup? ageGroup(int? birthYear) {
    if (birthYear == null) return null;
    final age = DateTime.now().year - birthYear;
    if (age < 23) return AgeGroup.youngAdult;
    if (age <= 30) return AgeGroup.adult;
    if (age <= 45) return AgeGroup.midLife;
    return AgeGroup.mature;
  }

  /// Whether [birthYear] indicates the user is under 23 years old.
  static bool isYoungAdult(int? birthYear) =>
      ageGroup(birthYear) == AgeGroup.youngAdult;

  /// Whether [birthYear] indicates the user is 30+ years old. Per product
  /// requirement, Family/Children defaults apply by age alone regardless of
  /// whether the user actually has children.
  static bool qualifiesForFamilyDefaults(int? birthYear) {
    if (birthYear == null) return false;
    return DateTime.now().year - birthYear >= 30;
  }

  /// Group 14 (Gia đình & Con cái) `nameKey`s, default-on for 30+ users.
  static const List<String> familyCategoryKeys = [
    PrjLocaleKeys.category_milk_formula,
    PrjLocaleKeys.category_diapers,
    PrjLocaleKeys.category_baby_toys,
  ];

  /// Default-on expense category `nameKey`s per life stage. Categories outside
  /// these sets are left untouched.
  static const Map<AgeGroup, List<String>> defaultExpenseCategoryKeys = {
    AgeGroup.youngAdult: [
      PrjLocaleKeys.category_food_drink,
      PrjLocaleKeys.category_market_supermarket,
      PrjLocaleKeys.category_taxi,
      PrjLocaleKeys.category_electricity,
      PrjLocaleKeys.category_water,
      PrjLocaleKeys.category_internet,
      PrjLocaleKeys.category_phone,
      PrjLocaleKeys.category_rent,
      PrjLocaleKeys.category_laundry,
      PrjLocaleKeys.category_doctor,
      PrjLocaleKeys.category_medicine,
      PrjLocaleKeys.category_tuition,
      PrjLocaleKeys.category_courses,
      PrjLocaleKeys.category_clothing,
      PrjLocaleKeys.category_bank_fee,
      PrjLocaleKeys.category_card_fee,
    ],
    AgeGroup.adult: [
      PrjLocaleKeys.category_food_drink,
      PrjLocaleKeys.category_market_supermarket,
      PrjLocaleKeys.category_taxi,
      PrjLocaleKeys.category_gas,
      PrjLocaleKeys.category_parking,
      PrjLocaleKeys.category_maintenance,
      PrjLocaleKeys.category_electricity,
      PrjLocaleKeys.category_water,
      PrjLocaleKeys.category_internet,
      PrjLocaleKeys.category_phone,
      PrjLocaleKeys.category_rent,
      PrjLocaleKeys.category_furniture,
      PrjLocaleKeys.category_laundry,
      PrjLocaleKeys.category_condo_fee,
      PrjLocaleKeys.category_doctor,
      PrjLocaleKeys.category_medicine,
      PrjLocaleKeys.category_health_insurance,
      PrjLocaleKeys.category_gym,
      PrjLocaleKeys.category_courses,
      PrjLocaleKeys.category_cinema,
      PrjLocaleKeys.category_travel,
      PrjLocaleKeys.category_leisure,
      PrjLocaleKeys.category_events,
      PrjLocaleKeys.category_electronics,
      PrjLocaleKeys.category_clothing,
      PrjLocaleKeys.category_cosmetics,
      PrjLocaleKeys.category_gifts,
      PrjLocaleKeys.category_religious,
      PrjLocaleKeys.category_haircut,
      PrjLocaleKeys.category_spa,
      PrjLocaleKeys.category_personal_care_product,
      PrjLocaleKeys.category_bank_fee,
      PrjLocaleKeys.category_card_fee,
    ],
    AgeGroup.midLife: [
      PrjLocaleKeys.category_food_drink,
      PrjLocaleKeys.category_market_supermarket,
      PrjLocaleKeys.category_taxi,
      PrjLocaleKeys.category_gas,
      PrjLocaleKeys.category_parking,
      PrjLocaleKeys.category_maintenance,
      PrjLocaleKeys.category_electricity,
      PrjLocaleKeys.category_water,
      PrjLocaleKeys.category_internet,
      PrjLocaleKeys.category_phone,
      PrjLocaleKeys.category_rent,
      PrjLocaleKeys.category_furniture,
      PrjLocaleKeys.category_laundry,
      PrjLocaleKeys.category_condo_fee,
      PrjLocaleKeys.category_doctor,
      PrjLocaleKeys.category_medicine,
      PrjLocaleKeys.category_health_insurance,
      PrjLocaleKeys.category_gym,
      PrjLocaleKeys.category_courses,
      PrjLocaleKeys.category_cinema,
      PrjLocaleKeys.category_travel,
      PrjLocaleKeys.category_leisure,
      PrjLocaleKeys.category_events,
      PrjLocaleKeys.category_appliances,
      PrjLocaleKeys.category_electronics,
      PrjLocaleKeys.category_clothing,
      PrjLocaleKeys.category_cosmetics,
      PrjLocaleKeys.category_gifts,
      PrjLocaleKeys.category_charity,
      PrjLocaleKeys.category_religious,
      PrjLocaleKeys.category_haircut,
      PrjLocaleKeys.category_spa,
      PrjLocaleKeys.category_personal_care_product,
      PrjLocaleKeys.category_bank_fee,
      PrjLocaleKeys.category_card_fee,
    ],
    AgeGroup.mature: [
      PrjLocaleKeys.category_food_drink,
      PrjLocaleKeys.category_market_supermarket,
      PrjLocaleKeys.category_gas,
      PrjLocaleKeys.category_maintenance,
      PrjLocaleKeys.category_parking,
      PrjLocaleKeys.category_electricity,
      PrjLocaleKeys.category_water,
      PrjLocaleKeys.category_internet,
      PrjLocaleKeys.category_phone,
      PrjLocaleKeys.category_rent,
      PrjLocaleKeys.category_furniture,
      PrjLocaleKeys.category_laundry,
      PrjLocaleKeys.category_condo_fee,
      PrjLocaleKeys.category_doctor,
      PrjLocaleKeys.category_medicine,
      PrjLocaleKeys.category_health_insurance,
      PrjLocaleKeys.category_gym,
      PrjLocaleKeys.category_books,
      PrjLocaleKeys.category_courses,
      PrjLocaleKeys.category_travel,
      PrjLocaleKeys.category_leisure,
      PrjLocaleKeys.category_appliances,
      PrjLocaleKeys.category_electronics,
      PrjLocaleKeys.category_clothing,
      PrjLocaleKeys.category_gifts,
      PrjLocaleKeys.category_charity,
      PrjLocaleKeys.category_religious,
      PrjLocaleKeys.category_haircut,
      PrjLocaleKeys.category_spa,
      PrjLocaleKeys.category_personal_care_product,
      PrjLocaleKeys.category_bank_fee,
      PrjLocaleKeys.category_card_fee,
    ],
  };

  /// Default-on income category `nameKey`s per life stage.
  static const Map<AgeGroup, List<String>> defaultIncomeCategoryKeys = {
    AgeGroup.youngAdult: [
      PrjLocaleKeys.category_income_allowance,
      PrjLocaleKeys.category_income_salary,
      PrjLocaleKeys.category_income_freelance,
      PrjLocaleKeys.category_income_gift,
    ],
    AgeGroup.adult: [
      PrjLocaleKeys.category_income_salary,
      PrjLocaleKeys.category_income_freelance,
      PrjLocaleKeys.category_income_allowance,
      PrjLocaleKeys.category_income_bonus,
      PrjLocaleKeys.category_income_cashback,
      PrjLocaleKeys.category_income_gift,
      PrjLocaleKeys.category_income_savings_interest,
    ],
    AgeGroup.midLife: [
      PrjLocaleKeys.category_income_salary,
      PrjLocaleKeys.category_income_freelance,
      PrjLocaleKeys.category_income_allowance,
      PrjLocaleKeys.category_income_savings_interest,
      PrjLocaleKeys.category_income_dividends,
      PrjLocaleKeys.category_income_rental,
      PrjLocaleKeys.category_income_bonus,
      PrjLocaleKeys.category_income_gift,
      PrjLocaleKeys.category_income_cashback,
    ],
    AgeGroup.mature: [
      PrjLocaleKeys.category_income_salary,
      PrjLocaleKeys.category_income_allowance,
      PrjLocaleKeys.category_income_savings_interest,
      PrjLocaleKeys.category_income_dividends,
      PrjLocaleKeys.category_income_rental,
      PrjLocaleKeys.category_income_gift,
      PrjLocaleKeys.category_income_bonus,
    ],
  };

  /// Default-on liability category `nameKey`s per life stage.
  static const Map<AgeGroup, List<String>> defaultLiabilityCategoryKeys = {
    AgeGroup.youngAdult: [
      PrjLocaleKeys.category_debt_personal_borrow,
      PrjLocaleKeys.category_debt_credit_card,
      PrjLocaleKeys.category_debt_installment,
      PrjLocaleKeys.category_debt_other,
    ],
    AgeGroup.adult: [
      PrjLocaleKeys.category_debt_personal_borrow,
      PrjLocaleKeys.category_debt_bank_borrow,
      PrjLocaleKeys.category_debt_credit_card,
      PrjLocaleKeys.category_debt_installment,
      PrjLocaleKeys.category_debt_other,
      PrjLocaleKeys.category_debt_personal_lend,
    ],
    AgeGroup.midLife: [
      PrjLocaleKeys.category_debt_personal_borrow,
      PrjLocaleKeys.category_debt_bank_borrow,
      PrjLocaleKeys.category_debt_mortgage,
      PrjLocaleKeys.category_debt_credit_card,
      PrjLocaleKeys.category_debt_installment,
      PrjLocaleKeys.category_debt_other,
      PrjLocaleKeys.category_debt_personal_lend,
      PrjLocaleKeys.category_debt_other_lend,
    ],
    AgeGroup.mature: [
      PrjLocaleKeys.category_debt_personal_borrow,
      PrjLocaleKeys.category_debt_bank_borrow,
      PrjLocaleKeys.category_debt_mortgage,
      PrjLocaleKeys.category_debt_credit_card,
      PrjLocaleKeys.category_debt_installment,
      PrjLocaleKeys.category_debt_other,
      PrjLocaleKeys.category_debt_personal_lend,
    ],
  };

  /// Default-on investment category `nameKey`s per life stage.
  static const Map<AgeGroup, List<String>> defaultInvestmentCategoryKeys = {
    AgeGroup.youngAdult: [
      PrjLocaleKeys.category_investment_term_deposit,
      PrjLocaleKeys.category_investment_gold,
      PrjLocaleKeys.category_investment_crypto,
    ],
    AgeGroup.adult: [
      PrjLocaleKeys.category_investment_stock,
      PrjLocaleKeys.category_investment_fund,
      PrjLocaleKeys.category_investment_term_deposit,
      PrjLocaleKeys.category_investment_gold,
      PrjLocaleKeys.category_investment_crypto,
      PrjLocaleKeys.category_investment_other,
    ],
    AgeGroup.midLife: [
      PrjLocaleKeys.category_investment_stock,
      PrjLocaleKeys.category_investment_fund,
      PrjLocaleKeys.category_investment_term_deposit,
      PrjLocaleKeys.category_investment_real_estate,
      PrjLocaleKeys.category_investment_gold,
      PrjLocaleKeys.category_investment_crypto,
      PrjLocaleKeys.category_investment_bond,
      PrjLocaleKeys.category_investment_business,
      PrjLocaleKeys.category_investment_other,
    ],
    AgeGroup.mature: [
      PrjLocaleKeys.category_investment_stock,
      PrjLocaleKeys.category_investment_fund,
      PrjLocaleKeys.category_investment_term_deposit,
      PrjLocaleKeys.category_investment_real_estate,
      PrjLocaleKeys.category_investment_gold,
      PrjLocaleKeys.category_investment_bond,
      PrjLocaleKeys.category_investment_linked_insurance,
      PrjLocaleKeys.category_investment_other,
    ],
  };
}
