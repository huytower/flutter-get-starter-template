import 'package:flutter/material.dart';

import 'app_rating_sheet_content.dart';

class AppRatingSheet extends StatelessWidget {
  const AppRatingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AppRatingSheetContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppRatingSheetContent();
  }
}
