import 'package:serverpod/serverpod.dart';
import 'package:ds_milk_world_server/src/web/routes/root.dart';
import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

void run(List<String> args) async {
  // Initialize Serverpod and connect it with generated code
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Setup default page at web root
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  // Start the server
  await pod.start();
}