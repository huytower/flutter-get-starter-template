import 'package:easy_localization/easy_localization.dart' as el;

class CategoryNameUtil {
  CategoryNameUtil._();

  /// Returns a localized name if the given [name] matches a known default
  /// category name in either English or Vietnamese. Otherwise returns [name].
  static String getLocalizedName(String name, String? categoryNameKey) {
    if (categoryNameKey != null) {
      final localized = el.tr(categoryNameKey);
      if (isDefaultName(name, categoryNameKey)) {
        return localized;
      }
    }
    return name;
  }

  static bool isDefaultName(String name, String key) {
    // Exact match with current translation is always "default"
    if (name == el.tr(key)) return true;

    // Check against English values from en.json
    final enDefaults = {
      'category.food_drink': 'Dining & Coffee',
      'category.gas': 'Gas',
      'category.taxi': 'Taxi',
      'category.parking': 'Parking',
      'category.maintenance': 'Maintenance',
      'category.phone': 'Phone',
      'category.electricity': 'Electricity',
      'category.internet': 'Internet',
      'category.rent': 'Rent',
      'category.condo_fee': 'Condo Fee',
      'category.laundry': 'Laundry',
      'category.furniture': 'Furniture',
      'category.medicine': 'Medicine',
      'category.doctor': 'Doctor',
      'category.gym': 'Gym',
      'category.health_insurance': 'Health Insurance',
      'category.tuition': 'Tuition',
      'category.courses': 'Courses',
      'category.books': 'Books',
      'category.gaming': 'Gaming',
      'category.cinema': 'Cinema',
      'category.events': 'Events',
      'category.travel': 'Travel',
      'category.market_supermarket': 'Market & Supermarket',
      'category.clothing': 'Clothing',
      'category.electronics': 'Electronics',
      'category.cosmetics': 'Cosmetics',
      'category.appliances': 'Appliances',
      'category.gifts': 'Gifts',
      'category.charity': 'Charity',
      'category.religious': 'Religious/Spirituality',
      'category.leisure': 'Leisure & Travel',
      'category.haircut': 'Haircut',
      'category.spa': 'Spa',
      'category.personal_care_product': 'Personal Care',
      'category.bank_fee': 'Bank Fee',
      'category.card_fee': 'Card Annual Fee',
      'category.milk_formula': 'Milk Formula',
      'category.diapers': 'Diapers',
      'category.baby_toys': 'Baby Toys',
      // Income
      'category.income_salary': 'Main Salary',
      'category.income_freelance': 'Freelance',
      'category.income_allowance': 'Allowance',
      'category.income_savings_interest': 'Savings Interest',
      'category.income_dividends': 'Dividends',
      'category.income_rental': 'Asset Rental',
      'category.income_bonus': 'Bonus',
      'category.income_gift': 'Gifts/Presents',
      'category.income_cashback': 'Cashback',
      // Debt & Loan
      'category.debt_personal_borrow': 'Personal Loan (Friends/Family)',
      'category.debt_bank_borrow': 'Bank/Financial Institution Loan',
      'category.debt_mortgage': 'Mortgage',
      'category.debt_credit_card': 'Credit Card Debt',
      'category.debt_installment': 'Installment',
      'category.debt_personal_lend': 'Personal Lending',
      'category.debt_other': 'Other',
      'category.debt_other_lend': 'Other',
      // Investment
      'category.investment_bond': 'Bond',
      'category.investment_business': 'Business',
      'category.investment_crypto': 'Crypto',
      'category.investment_fund': 'Fund',
      'category.investment_gold': 'Gold',
      'category.investment_stock': 'Stock',
      'category.investment_term_deposit': 'Term Deposit',
      'category.investment_real_estate': 'Real Estate',
      'category.investment_linked_insurance': 'Investment-linked Insurance',
      'category.investment_other': 'Other',
    };

    return enDefaults[key] == name;
  }
}
