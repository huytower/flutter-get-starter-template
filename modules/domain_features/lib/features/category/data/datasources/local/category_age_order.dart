import 'package:message/prj_locale_keys.dart';

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
      PrjLocaleKeys.category_food_drink,
      PrjLocaleKeys.category_taxi,
      PrjLocaleKeys.category_market_supermarket,
      PrjLocaleKeys.category_clothing,
      PrjLocaleKeys.category_courses,
      PrjLocaleKeys.category_tuition,
      PrjLocaleKeys.category_phone,
      PrjLocaleKeys.category_internet,
      PrjLocaleKeys.category_laundry,
      PrjLocaleKeys.category_rent,
      PrjLocaleKeys.category_electricity,
      PrjLocaleKeys.category_water,
      PrjLocaleKeys.category_doctor,
      PrjLocaleKeys.category_medicine,
      PrjLocaleKeys.category_bank_fee,
      PrjLocaleKeys.category_card_fee,
    ],
    // 23-30: young professionals.
    AgeGroup.adult: [
      PrjLocaleKeys.category_food_drink,
      PrjLocaleKeys.category_market_supermarket,
      PrjLocaleKeys.category_milk_formula,
      PrjLocaleKeys.category_diapers,
      PrjLocaleKeys.category_clothing,
      PrjLocaleKeys.category_cinema,
      PrjLocaleKeys.category_electricity,
      PrjLocaleKeys.category_water,
      PrjLocaleKeys.category_phone,
      PrjLocaleKeys.category_internet,
      PrjLocaleKeys.category_taxi,
      PrjLocaleKeys.category_gas,
      PrjLocaleKeys.category_rent,
      PrjLocaleKeys.category_gym,
      PrjLocaleKeys.category_travel,
      PrjLocaleKeys.category_cosmetics,
      PrjLocaleKeys.category_haircut,
      PrjLocaleKeys.category_doctor,
      PrjLocaleKeys.category_medicine,
      PrjLocaleKeys.category_courses,
      PrjLocaleKeys.category_gifts,
      PrjLocaleKeys.category_events,
      PrjLocaleKeys.category_leisure,
      PrjLocaleKeys.category_baby_toys,
      PrjLocaleKeys.category_electronics,
      PrjLocaleKeys.category_parking,
      PrjLocaleKeys.category_maintenance,
      PrjLocaleKeys.category_furniture,
      PrjLocaleKeys.category_laundry,
      PrjLocaleKeys.category_condo_fee,
      PrjLocaleKeys.category_health_insurance,
      PrjLocaleKeys.category_spa,
      PrjLocaleKeys.category_personal_care_product,
      PrjLocaleKeys.category_religious,
      PrjLocaleKeys.category_bank_fee,
      PrjLocaleKeys.category_card_fee,
    ],
    // 31-45: households with children.
    AgeGroup.midLife: [
      PrjLocaleKeys.category_food_drink,
      PrjLocaleKeys.category_market_supermarket,
      PrjLocaleKeys.category_milk_formula,
      PrjLocaleKeys.category_diapers,
      PrjLocaleKeys.category_gas,
      PrjLocaleKeys.category_taxi,
      PrjLocaleKeys.category_electricity,
      PrjLocaleKeys.category_water,
      PrjLocaleKeys.category_internet,
      PrjLocaleKeys.category_phone,
      PrjLocaleKeys.category_rent,
      PrjLocaleKeys.category_condo_fee,
      PrjLocaleKeys.category_doctor,
      PrjLocaleKeys.category_medicine,
      PrjLocaleKeys.category_health_insurance,
      PrjLocaleKeys.category_clothing,
      PrjLocaleKeys.category_baby_toys,
      PrjLocaleKeys.category_travel,
      PrjLocaleKeys.category_leisure,
      PrjLocaleKeys.category_courses,
      PrjLocaleKeys.category_gym,
      PrjLocaleKeys.category_cinema,
      PrjLocaleKeys.category_gifts,
      PrjLocaleKeys.category_events,
      PrjLocaleKeys.category_parking,
      PrjLocaleKeys.category_maintenance,
      PrjLocaleKeys.category_furniture,
      PrjLocaleKeys.category_appliances,
      PrjLocaleKeys.category_electronics,
      PrjLocaleKeys.category_laundry,
      PrjLocaleKeys.category_cosmetics,
      PrjLocaleKeys.category_haircut,
      PrjLocaleKeys.category_spa,
      PrjLocaleKeys.category_personal_care_product,
      PrjLocaleKeys.category_religious,
      PrjLocaleKeys.category_charity,
      PrjLocaleKeys.category_bank_fee,
      PrjLocaleKeys.category_card_fee,
    ],
    // Over 45.
    AgeGroup.mature: [
      PrjLocaleKeys.category_food_drink,
      PrjLocaleKeys.category_market_supermarket,
      PrjLocaleKeys.category_doctor,
      PrjLocaleKeys.category_medicine,
      PrjLocaleKeys.category_health_insurance,
      PrjLocaleKeys.category_gas,
      PrjLocaleKeys.category_electricity,
      PrjLocaleKeys.category_water,
      PrjLocaleKeys.category_internet,
      PrjLocaleKeys.category_phone,
      PrjLocaleKeys.category_rent,
      PrjLocaleKeys.category_travel,
      PrjLocaleKeys.category_gifts,
      PrjLocaleKeys.category_charity,
      PrjLocaleKeys.category_religious,
      PrjLocaleKeys.category_clothing,
      PrjLocaleKeys.category_leisure,
      PrjLocaleKeys.category_maintenance,
      PrjLocaleKeys.category_parking,
      PrjLocaleKeys.category_furniture,
      PrjLocaleKeys.category_appliances,
      PrjLocaleKeys.category_electronics,
      PrjLocaleKeys.category_laundry,
      PrjLocaleKeys.category_condo_fee,
      PrjLocaleKeys.category_books,
      PrjLocaleKeys.category_courses,
      PrjLocaleKeys.category_gym,
      PrjLocaleKeys.category_haircut,
      PrjLocaleKeys.category_spa,
      PrjLocaleKeys.category_personal_care_product,
      PrjLocaleKeys.category_bank_fee,
      PrjLocaleKeys.category_card_fee,
    ],
  };
}
