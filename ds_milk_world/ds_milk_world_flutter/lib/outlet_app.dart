import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/staff_console_screen.dart';

class OutletApp extends StatelessWidget {
  const OutletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DS Milk World — Outlet Kitchen Console',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: StaffConsoleScreen(
        staffRole: 'administrator',
        onBackToStorefront: () {},
      ),
    );
  }
}
