import 'package:flutter/material.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/category_group_entity.dart';
import '../../models/category_model.dart';

/// Default categories + groups seeded into Hive on first launch.
class CategorySeed {
  CategorySeed._();

  /// Pseudo-group id kept for backwards-compat (no longer used in seed).
  static const String incomeGroupId = 'income';

  static const String incomeActiveGroupId = 'income_active';
  static const String incomeInvestGroupId = 'income_invest';
  static const String incomeOtherGroupId = 'income_other';

  static const List<CategoryGroupEntity> incomeGroups = [
    CategoryGroupEntity(id: incomeActiveGroupId, nameKey: CcLocaleKeys.category_income_group_active),
    CategoryGroupEntity(id: incomeInvestGroupId, nameKey: CcLocaleKeys.category_income_group_invest),
    CategoryGroupEntity(id: incomeOtherGroupId, nameKey: CcLocaleKeys.category_income_group_other),
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
    CategoryGroupEntity(id: '9', nameKey: 'Trả nợ & Vay'),
    CategoryGroupEntity(id: '10', nameKey: 'Bảo hiểm'),
    CategoryGroupEntity(id: '11', nameKey: 'Quà tặng & Từ thiện'),
    CategoryGroupEntity(id: '12', nameKey: 'Chăm sóc cá nhân'),
    CategoryGroupEntity(id: '13', nameKey: 'Phí dịch vụ'),
    CategoryGroupEntity(id: '14', nameKey: 'Gia đình & Con cái'),
  ];

  static final List<CategoryModel> categories = [
    // Group 1: Ăn uống & Cà phê
    CategoryModel(
      id: 'c1',
      nameKey: CcLocaleKeys.category_food_drink,
      iconCode: Icons.restaurant.codePoint,
      groupId: '1',
    ),
    CategoryModel(
      id: 'c2',
      nameKey: CcLocaleKeys.category_coffee,
      iconCode: Icons.local_cafe.codePoint,
      groupId: '1',
    ),
    CategoryModel(
      id: 'c3',
      nameKey: CcLocaleKeys.category_water,
      iconCode: Icons.local_drink.codePoint,
      groupId: '1',
    ),
    CategoryModel(
      id: 'c4',
      nameKey: CcLocaleKeys.category_eat_out,
      iconCode: Icons.dinner_dining.codePoint,
      groupId: '1',
    ),

    // Group 2: Di chuyển
    CategoryModel(
      id: 'c5',
      nameKey: CcLocaleKeys.category_taxi,
      iconCode: Icons.local_taxi.codePoint,
      groupId: '2',
    ),
    CategoryModel(
      id: 'c6',
      nameKey: CcLocaleKeys.category_gas,
      iconCode: Icons.local_gas_station.codePoint,
      groupId: '2',
    ),
    CategoryModel(
      id: 'c7',
      nameKey: CcLocaleKeys.category_parking,
      iconCode: Icons.local_parking.codePoint,
      groupId: '2',
    ),
    CategoryModel(
      id: 'c8',
      nameKey: CcLocaleKeys.category_maintenance,
      iconCode: Icons.car_repair.codePoint,
      groupId: '2',
    ),

    // Group 3: Tiện ích
    CategoryModel(
      id: 'c9',
      nameKey: CcLocaleKeys.category_electricity,
      iconCode: Icons.bolt.codePoint,
      groupId: '3',
    ),
    CategoryModel(
      id: 'c10',
      nameKey: CcLocaleKeys.category_internet,
      iconCode: Icons.wifi.codePoint,
      groupId: '3',
    ),
    CategoryModel(
      id: 'c11',
      nameKey: CcLocaleKeys.category_phone,
      iconCode: Icons.smartphone.codePoint,
      groupId: '3',
    ),

    // Group 4: Nhà ở
    CategoryModel(
      id: 'c12',
      nameKey: CcLocaleKeys.category_rent,
      iconCode: Icons.house.codePoint,
      groupId: '4',
    ),
    CategoryModel(
      id: 'c13',
      nameKey: CcLocaleKeys.category_furniture,
      iconCode: Icons.chair.codePoint,
      groupId: '4',
    ),
    CategoryModel(
      id: 'c14',
      nameKey: CcLocaleKeys.category_laundry,
      iconCode: Icons.local_laundry_service.codePoint,
      groupId: '4',
    ),
    CategoryModel(
      id: 'c15',
      nameKey: CcLocaleKeys.category_mortgage,
      iconCode: Icons.account_balance.codePoint,
      groupId: '4',
    ),
    CategoryModel(
      id: 'c16',
      nameKey: CcLocaleKeys.category_condo_fee,
      iconCode: Icons.apartment.codePoint,
      groupId: '4',
    ),

    // Group 5: Y tế & Sức khỏe
    CategoryModel(
      id: 'c17',
      nameKey: CcLocaleKeys.category_doctor,
      iconCode: Icons.local_hospital.codePoint,
      groupId: '5',
    ),
    CategoryModel(
      id: 'c18',
      nameKey: CcLocaleKeys.category_medicine,
      iconCode: Icons.medication.codePoint,
      groupId: '5',
    ),
    CategoryModel(
      id: 'c19',
      nameKey: CcLocaleKeys.category_health_insurance,
      iconCode: Icons.health_and_safety.codePoint,
      groupId: '5',
    ),
    CategoryModel(
      id: 'c20',
      nameKey: CcLocaleKeys.category_gym,
      iconCode: Icons.fitness_center.codePoint,
      groupId: '5',
    ),

    // Group 6: Giáo dục
    CategoryModel(
      id: 'c21',
      nameKey: CcLocaleKeys.category_tuition,
      iconCode: Icons.school.codePoint,
      groupId: '6',
    ),
    CategoryModel(
      id: 'c22',
      nameKey: CcLocaleKeys.category_books,
      iconCode: Icons.menu_book.codePoint,
      groupId: '6',
    ),
    CategoryModel(
      id: 'c23',
      nameKey: CcLocaleKeys.category_courses,
      iconCode: Icons.cast_for_education.codePoint,
      groupId: '6',
    ),

    // Group 7: Giải trí
    CategoryModel(
      id: 'c24',
      nameKey: CcLocaleKeys.category_cinema,
      iconCode: Icons.movie.codePoint,
      groupId: '7',
    ),
    CategoryModel(
      id: 'c25',
      nameKey: CcLocaleKeys.category_travel,
      iconCode: Icons.flight.codePoint,
      groupId: '7',
    ),
    CategoryModel(
      id: 'c26',
      nameKey: CcLocaleKeys.category_gaming,
      iconCode: Icons.sports_esports.codePoint,
      groupId: '7',
    ),
    CategoryModel(
      id: 'c27',
      nameKey: CcLocaleKeys.category_events,
      iconCode: Icons.event.codePoint,
      groupId: '7',
    ),

    // Group 8: Mua sắm
    CategoryModel(
      id: 'c28',
      nameKey: CcLocaleKeys.category_appliances,
      iconCode: Icons.kitchen.codePoint,
      groupId: '8',
    ),
    CategoryModel(
      id: 'c29',
      nameKey: CcLocaleKeys.category_electronics,
      iconCode: Icons.devices.codePoint,
      groupId: '8',
    ),
    CategoryModel(
      id: 'c30',
      nameKey: CcLocaleKeys.category_clothing,
      iconCode: Icons.checkroom.codePoint,
      groupId: '8',
    ),
    CategoryModel(
      id: 'c31',
      nameKey: CcLocaleKeys.category_cosmetics,
      iconCode: Icons.face_retouching_natural.codePoint,
      groupId: '8',
    ),

    // Group 9: Trả nợ & Vay
    CategoryModel(
      id: 'c32',
      nameKey: CcLocaleKeys.category_installment,
      iconCode: Icons.credit_card.codePoint,
      groupId: '9',
    ),
    CategoryModel(
      id: 'c33',
      nameKey: CcLocaleKeys.category_loan_interest,
      iconCode: Icons.account_balance_wallet.codePoint,
      groupId: '9',
    ),

    // Group 10: Bảo hiểm
    CategoryModel(
      id: 'c34',
      nameKey: CcLocaleKeys.category_life_insurance,
      iconCode: Icons.favorite.codePoint,
      groupId: '10',
    ),
    CategoryModel(
      id: 'c35',
      nameKey: CcLocaleKeys.category_vehicle_insurance,
      iconCode: Icons.directions_car.codePoint,
      groupId: '10',
    ),
    CategoryModel(
      id: 'c36',
      nameKey: CcLocaleKeys.category_home_insurance,
      iconCode: Icons.home.codePoint,
      groupId: '10',
    ),

    // Group 11: Quà tặng & Từ thiện
    CategoryModel(
      id: 'c37',
      nameKey: CcLocaleKeys.category_gifts,
      iconCode: Icons.card_giftcard.codePoint,
      groupId: '11',
    ),
    CategoryModel(
      id: 'c38',
      nameKey: CcLocaleKeys.category_charity,
      iconCode: Icons.volunteer_activism.codePoint,
      groupId: '11',
    ),

    // Group 12: Chăm sóc cá nhân
    CategoryModel(
      id: 'c39',
      nameKey: CcLocaleKeys.category_haircut,
      iconCode: Icons.content_cut.codePoint,
      groupId: '12',
    ),
    CategoryModel(
      id: 'c40',
      nameKey: CcLocaleKeys.category_spa,
      iconCode: Icons.spa.codePoint,
      groupId: '12',
    ),
    CategoryModel(
      id: 'c41',
      nameKey: CcLocaleKeys.category_personal_care_product,
      iconCode: Icons.soap.codePoint,
      groupId: '12',
    ),

    // Group 13: Phí dịch vụ
    CategoryModel(
      id: 'c42',
      nameKey: CcLocaleKeys.category_bank_fee,
      iconCode: Icons.account_balance.codePoint,
      groupId: '13',
    ),
    CategoryModel(
      id: 'c43',
      nameKey: CcLocaleKeys.category_card_fee,
      iconCode: Icons.credit_score.codePoint,
      groupId: '13',
    ),

    // Group 14: Gia đình & Con cái — disabled by default
    CategoryModel(
      id: 'c44',
      nameKey: CcLocaleKeys.category_milk_formula,
      iconCode: Icons.baby_changing_station.codePoint,
      groupId: '14',
      isEnabled: false,
    ),
    CategoryModel(
      id: 'c45',
      nameKey: CcLocaleKeys.category_diapers,
      iconCode: Icons.child_care.codePoint,
      groupId: '14',
      isEnabled: false,
    ),
    CategoryModel(
      id: 'c46',
      nameKey: CcLocaleKeys.category_baby_toys,
      iconCode: Icons.toys.codePoint,
      groupId: '14',
      isEnabled: false,
    ),

    // Income — Thu nhập chủ động
    CategoryModel(
      id: 'i1',
      nameKey: CcLocaleKeys.category_income_salary,
      iconCode: Icons.business_center.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
    ),
    CategoryModel(
      id: 'i2',
      nameKey: CcLocaleKeys.category_income_freelance,
      iconCode: Icons.laptop_mac.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
    ),
    CategoryModel(
      id: 'i3',
      nameKey: CcLocaleKeys.category_income_allowance,
      iconCode: Icons.volunteer_activism.codePoint,
      groupId: incomeActiveGroupId,
      type: CategoryType.income,
    ),

    // Income — Thu nhập đầu tư
    CategoryModel(
      id: 'i4',
      nameKey: CcLocaleKeys.category_income_savings_interest,
      iconCode: Icons.account_balance.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
    ),
    CategoryModel(
      id: 'i5',
      nameKey: CcLocaleKeys.category_income_dividends,
      iconCode: Icons.pie_chart.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
    ),
    CategoryModel(
      id: 'i6',
      nameKey: CcLocaleKeys.category_income_rental,
      iconCode: Icons.home.codePoint,
      groupId: incomeInvestGroupId,
      type: CategoryType.income,
    ),

    // Income — Thu nhập khác
    CategoryModel(
      id: 'i7',
      nameKey: CcLocaleKeys.category_income_bonus,
      iconCode: Icons.card_giftcard.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
    ),
    CategoryModel(
      id: 'i8',
      nameKey: CcLocaleKeys.category_income_gift,
      iconCode: Icons.favorite.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
    ),
    CategoryModel(
      id: 'i9',
      nameKey: CcLocaleKeys.category_income_cashback,
      iconCode: Icons.replay.codePoint,
      groupId: incomeOtherGroupId,
      type: CategoryType.income,
    ),
  ];
}
