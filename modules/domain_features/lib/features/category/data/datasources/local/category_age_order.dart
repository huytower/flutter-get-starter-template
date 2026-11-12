import 'package:message/cc_locale_keys.dart';

import 'category_seed.dart';

/// Default DISPLAY order of expense categories, per life stage.
///
/// Used by the Expense form to order categories for someone with no spending
/// history yet. The seed order is a fixed, age-blind list that put vehicle items
/// (Gas, Taxi, Parking) right after Food for everyone, so a 25-year-old's first
/// screen was not what they actually log. Here every group is ordered by how
/// often that kind of person records the entry: everyday spending first, monthly
/// bills next, occasional items last.
///
/// Once the user records expenses, recently used categories move to the front
/// (see `ExpenseFormController`); this order only decides everything else.
///
/// To tune the order for a group, just reorder its list. A category missing
/// from a list falls back to seed order after the listed ones.
class CategoryAgeOrder {
  CategoryAgeOrder._();

  /// Order used when the birth year is unknown — the most common group.
  static const AgeGroup defaultGroup = AgeGroup.adult;

  /// Ordered `nameKey`s for [birthYear]'s life stage.
  static List<String> expenseOrder(int? birthYear) {
    final group = CategorySeed.ageGroup(birthYear) ?? defaultGroup;
    return _expenseOrder[group] ?? const <String>[];
  }

  /// Ordered income `nameKey`s for [birthYear]'s life stage.
  ///
  /// Reuses the product-defined income list of that stage
  /// ([CategorySeed.defaultIncomeCategoryKeys]) as the order, so there is a
  /// single place to maintain it: e.g. a student sees Allowance first, a working
  /// adult sees Salary first. Income categories not in that list fall back to
  /// seed order after the listed ones.
  static List<String> incomeOrder(int? birthYear) {
    final group = CategorySeed.ageGroup(birthYear) ?? defaultGroup;
    return CategorySeed.defaultIncomeCategoryKeys[group] ?? const <String>[];
  }

  static const Map<AgeGroup, List<String>> _expenseOrder = {
    // Under 23: students and first jobs.
    AgeGroup.youngAdult: [
      CcLocaleKeys.category_food_drink,
      CcLocaleKeys.category_taxi,
      CcLocaleKeys.category_market_supermarket,
      CcLocaleKeys.category_clothing,
      CcLocaleKeys.category_courses,
      CcLocaleKeys.category_tuition,
      CcLocaleKeys.category_phone,
      CcLocaleKeys.category_internet,
      CcLocaleKeys.category_laundry,
      CcLocaleKeys.category_rent,
      CcLocaleKeys.category_electricity,
      CcLocaleKeys.category_water,
      CcLocaleKeys.category_doctor,
      CcLocaleKeys.category_medicine,
      CcLocaleKeys.category_bank_fee,
      CcLocaleKeys.category_card_fee,
    ],
    // 23-30: young professionals.
    AgeGroup.adult: [
      CcLocaleKeys.category_food_drink,
      CcLocaleKeys.category_market_supermarket,
      CcLocaleKeys.category_milk_formula,
      CcLocaleKeys.category_diapers,
      CcLocaleKeys.category_clothing,
      CcLocaleKeys.category_cinema,
      CcLocaleKeys.category_electricity,
      CcLocaleKeys.category_water,
      CcLocaleKeys.category_phone,
      CcLocaleKeys.category_internet,
      CcLocaleKeys.category_taxi,
      CcLocaleKeys.category_gas,
      CcLocaleKeys.category_rent,
      CcLocaleKeys.category_gym,
      CcLocaleKeys.category_travel,
      CcLocaleKeys.category_cosmetics,
      CcLocaleKeys.category_haircut,
      CcLocaleKeys.category_doctor,
      CcLocaleKeys.category_medicine,
      CcLocaleKeys.category_courses,
      CcLocaleKeys.category_gifts,
      CcLocaleKeys.category_events,
      CcLocaleKeys.category_leisure,
      CcLocaleKeys.category_baby_toys,
      CcLocaleKeys.category_electronics,
      CcLocaleKeys.category_parking,
      CcLocaleKeys.category_maintenance,
      CcLocaleKeys.category_furniture,
      CcLocaleKeys.category_laundry,
      CcLocaleKeys.category_condo_fee,
      CcLocaleKeys.category_health_insurance,
      CcLocaleKeys.category_spa,
      CcLocaleKeys.category_personal_care_product,
      CcLocaleKeys.category_religious,
      CcLocaleKeys.category_bank_fee,
      CcLocaleKeys.category_card_fee,
    ],
    // 31-45: households with children.
    AgeGroup.midLife: [
      CcLocaleKeys.category_food_drink,
      CcLocaleKeys.category_market_supermarket,
      CcLocaleKeys.category_milk_formula,
      CcLocaleKeys.category_diapers,
      CcLocaleKeys.category_gas,
      CcLocaleKeys.category_taxi,
      CcLocaleKeys.category_electricity,
      CcLocaleKeys.category_water,
      CcLocaleKeys.category_internet,
      CcLocaleKeys.category_phone,
      CcLocaleKeys.category_rent,
      CcLocaleKeys.category_condo_fee,
      CcLocaleKeys.category_doctor,
      CcLocaleKeys.category_medicine,
      CcLocaleKeys.category_health_insurance,
      CcLocaleKeys.category_clothing,
      CcLocaleKeys.category_baby_toys,
      CcLocaleKeys.category_travel,
      CcLocaleKeys.category_leisure,
      CcLocaleKeys.category_courses,
      CcLocaleKeys.category_gym,
      CcLocaleKeys.category_cinema,
      CcLocaleKeys.category_gifts,
      CcLocaleKeys.category_events,
      CcLocaleKeys.category_parking,
      CcLocaleKeys.category_maintenance,
      CcLocaleKeys.category_furniture,
      CcLocaleKeys.category_appliances,
      CcLocaleKeys.category_electronics,
      CcLocaleKeys.category_laundry,
      CcLocaleKeys.category_cosmetics,
      CcLocaleKeys.category_haircut,
      CcLocaleKeys.category_spa,
      CcLocaleKeys.category_personal_care_product,
      CcLocaleKeys.category_religious,
      CcLocaleKeys.category_charity,
      CcLocaleKeys.category_bank_fee,
      CcLocaleKeys.category_card_fee,
    ],
    // Over 45.
    AgeGroup.mature: [
      CcLocaleKeys.category_food_drink,
      CcLocaleKeys.category_market_supermarket,
      CcLocaleKeys.category_doctor,
      CcLocaleKeys.category_medicine,
      CcLocaleKeys.category_health_insurance,
      CcLocaleKeys.category_gas,
      CcLocaleKeys.category_electricity,
      CcLocaleKeys.category_water,
      CcLocaleKeys.category_internet,
      CcLocaleKeys.category_phone,
      CcLocaleKeys.category_rent,
      CcLocaleKeys.category_travel,
      CcLocaleKeys.category_gifts,
      CcLocaleKeys.category_charity,
      CcLocaleKeys.category_religious,
      CcLocaleKeys.category_clothing,
      CcLocaleKeys.category_leisure,
      CcLocaleKeys.category_maintenance,
      CcLocaleKeys.category_parking,
      CcLocaleKeys.category_furniture,
      CcLocaleKeys.category_appliances,
      CcLocaleKeys.category_electronics,
      CcLocaleKeys.category_laundry,
      CcLocaleKeys.category_condo_fee,
      CcLocaleKeys.category_books,
      CcLocaleKeys.category_courses,
      CcLocaleKeys.category_gym,
      CcLocaleKeys.category_haircut,
      CcLocaleKeys.category_spa,
      CcLocaleKeys.category_personal_care_product,
      CcLocaleKeys.category_bank_fee,
      CcLocaleKeys.category_card_fee,
    ],
  };
}
