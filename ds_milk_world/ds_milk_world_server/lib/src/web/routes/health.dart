import 'dart:io';
import 'package:serverpod/serverpod.dart';

class RouteHealth extends Route {
  @override
  Future<bool> handleCall(Session session, HttpRequest request) async {
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"status":"ok","service":"ds_milk_world_server","version":"1.0.0"}');
    await request.response.close();
    return true;
  }
}
