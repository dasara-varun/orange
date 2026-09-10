import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import 'customer_app.dart';
import 'outlet_app.dart';

late Client client;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Production Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Material(
      color: const Color(0xFFFFFDF8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_cafe_rounded, size: 52, color: Color(0xFF3A241B)),
              const SizedBox(height: 16),
              const Text(
                'DS Milk World',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3A241B),
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Something unexpected occurred. Please refresh the page to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF7A6B63)),
              ),
            ],
          ),
        ),
      ),
    );
  };

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
    return const CustomerApp();
  }
}