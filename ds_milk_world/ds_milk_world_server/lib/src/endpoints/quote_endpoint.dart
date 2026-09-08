import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/geo_service.dart';

class QuoteEndpoint extends Endpoint {
  Future<DeliveryQuote> getDeliveryQuote(
    Session session,
    double latitude,
    double longitude,
  ) async {
    final distanceKm = GeoService.calculateDistanceKm(
      GeoService.outletLat,
      GeoService.outletLng,
      latitude,
      longitude,
    );

    final serviceable = distanceKm <= GeoService.maxServiceRadiusKm;
    if (!serviceable) {
      return DeliveryQuote(
        serviceable: false,
        distanceKm: double.parse(distanceKm.toStringAsFixed(2)),
        feePaise: 0,
        message: 'Delivery location is ${(distanceKm).toStringAsFixed(1)} km away. Maximum service radius is 5.0 km.',
      );
    }

    final feePaise = GeoService.calculateDeliveryFeePaise(distanceKm);
    return DeliveryQuote(
      serviceable: true,
      distanceKm: double.parse(distanceKm.toStringAsFixed(2)),
      feePaise: feePaise,
      message: 'Serviceable (${distanceKm.toStringAsFixed(1)} km from store)',
    );
  }
}