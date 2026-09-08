import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/catalog_service.dart';

class CatalogEndpoint extends Endpoint {
  Future<StoreCatalog> getCatalog(Session session) async {
    return CatalogService.getCatalog();
  }

  Future<bool> updateProductAvailability(
    Session session,
    String sku,
    bool availability,
  ) async {
    CatalogService.updateProductAvailability(sku, availability);
    return true;
  }
}