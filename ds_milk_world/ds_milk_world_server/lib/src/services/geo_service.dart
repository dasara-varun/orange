import 'dart:math';

class GeoService {
  // DS Milk World, Auto Nagar, Vijayawada
  static const double outletLat = 16.4950;
  static const double outletLng = 80.6650;
  static const double maxServiceRadiusKm = 5.0;

  /// Calculate distance in kilometers between two GPS coordinates using Haversine formula
  static double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }

  /// Calculates delivery fee in paise:
  /// Base fee: 3000 paise (Rs 30) for up to 2.0 km
  /// Additional fee: 1000 paise (Rs 10) per km beyond 2.0 km
  static int calculateDeliveryFeePaise(double distanceKm) {
    if (distanceKm <= 2.0) {
      return 3000;
    }
    final double extraKm = distanceKm - 2.0;
    final int extraFeePaise = (extraKm * 1000).ceil();
    return 3000 + extraFeePaise;
  }
}
