import 'package:flutter/material.dart';

import 'app_rating_sheet_content.dart';
import '../../../../core/helper/adaptive_bottom_sheet.dart';

class AppRatingSheet extends StatelessWidget {
  const AppRatingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAdaptiveBottomSheet<void>(
      context: context,
      backgroundColor: null,
      builder: (_) => const AppRatingSheetContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppRatingSheetContent();
  }
}
