import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import 'theme/app_theme.dart';
import 'screens/storefront_screen.dart';
import 'customer_app.dart';
import 'outlet_app.dart';

late Client client;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl = serverUrlFromEnv.isEmpty ? 'http://$localhost:8080/' : serverUrlFromEnv;

  client = Client(serverUrl)..connectivityMonitor = FlutterConnectivityMonitor();

  bool isOutlet = false;
  if (kIsWeb) {
    isOutlet = Uri.base.queryParameters['mode'] == 'outlet' || Uri.base.path.contains('/outlet');
  }

  if (isOutlet) {
    runApp(const OutletApp());
  } else {
    runApp(const DsMilkWorldApp());
  }
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
      routes: {
        '/store': (_) => const StorefrontScreen(),
        '/outlet': (_) => const OutletApp(),
      },
    );
  }
}