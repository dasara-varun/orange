import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/storefront_screen.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DS Milk World — Customer Storefront',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const StorefrontScreen(),
      routes: {
        '/store': (_) => const StorefrontScreen(),
      },
    );
  }
}
