import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import 'theme/app_theme.dart';
import 'screens/storefront_screen.dart';

late Client client;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl = serverUrlFromEnv.isEmpty ? 'http://$localhost:8080/' : serverUrlFromEnv;

  client = Client(serverUrl)..connectivityMonitor = FlutterConnectivityMonitor();

  runApp(const DsMilkWorldApp());
}

class DsMilkWorldApp extends StatelessWidget {
  const DsMilkWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DS Milk World — Direct Ordering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const StorefrontScreen(),
    );
  }
}