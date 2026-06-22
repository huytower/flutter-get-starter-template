import 'package:features/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';

class QuickTestTabContent extends StatefulWidget {
  static const String routeName = 'QUICK_TEST';

  const QuickTestTabContent({super.key});

  @override
  State<QuickTestTabContent> createState() => _QuickTestTabContentState();
}

class _QuickTestTabContentState extends State<QuickTestTabContent> {
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}
