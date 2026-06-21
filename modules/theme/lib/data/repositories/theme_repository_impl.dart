import 'package:flutter/material.dart';

import '../../../domain/repository/theme_repository.dart';
import '../../core/config/cc_themes.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  @override
  ThemeData getLightTheme() => CcThemes.lightTheme;

  @override
  ThemeData getDarkTheme() => CcThemes.darkTheme;
}
