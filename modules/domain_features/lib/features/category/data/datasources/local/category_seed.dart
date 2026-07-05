import 'package:flutter/material.dart';
import 'package:message/cc_locale_keys.dart';

import '../../../domain/entities/category_group_entity.dart';
import '../../models/category_model.dart';

/// Default categories + groups seeded into Hive on first launch.
///
/// Migrated from the previously hard-coded list in
/// `transaction/presentation/widgets/category_selection_section.dart` so there
/// is a single source of truth once the UI reads from the repository.
class CategorySeed {
  CategorySeed._();

  /// Group display names reuse the original strings; `easy_localization`
  /// returns the key unchanged when no translation is registered.
  static const List<CategoryGroupEntity> groups = [
    CategoryGroupEntity(id: '1', nameKey: 'Ăn uống & Cà phê'),
    CategoryGroupEntity(id: '2', nameKey: 'Di chuyển'),
    CategoryGroupEntity(id: '3', nameKey: 'Tiện ích'),
    CategoryGroupEntity(id: '4', nameKey: 'Nhà cửa'),
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

    // Group 4: Nhà cửa
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
  ];
}
