import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InteractiveMapPicker extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final ValueChanged<MapLocation> onLocationChanged;

  const InteractiveMapPicker({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationChanged,
  });

  @override
  State<InteractiveMapPicker> createState() => _InteractiveMapPickerState();
}

class MapLocation {
  final double latitude;
  final double longitude;
  final double distanceKm;
  final bool isServiceable;
  final int feePaise;
  final String nearestLandmark;

  MapLocation({
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.isServiceable,
    required this.feePaise,
    required this.nearestLandmark,
  });
}

class _InteractiveMapPickerState extends State<InteractiveMapPicker> {
  // Outlet coordinates (Auto Nagar Counter)
  static const double outletLat = 16.4950;
  static const double outletLng = 80.6650;
  static const double maxRadiusKm = 5.0;

  // Geographic bounds for Vijayawada map canvas
  static const double minLat = 16.4500;
  static const double maxLat = 16.5400;
  static const double minLng = 80.6000;
  static const double maxLng = 80.7200;

  late double _currentLat;
  late double _currentLng;
  bool _isDragging = false;

  // Landmarks in Vijayawada
  final List<Map<String, dynamic>> _landmarks = [
    {'name': 'Auto Nagar Gate', 'lat': 16.4950, 'lng': 80.6650, 'sub': 'Outlet Location'},
    {'name': 'Patamata', 'lat': 16.4980, 'lng': 80.6500, 'sub': '2.1 km'},
    {'name': 'Benz Circle', 'lat': 16.5000, 'lng': 80.6400, 'sub': '3.2 km'},
    {'name': 'Kanuru', 'lat': 16.4850, 'lng': 80.6900, 'sub': '3.1 km'},
    {'name': 'Governorpet', 'lat': 16.5100, 'lng': 80.6250, 'sub': '4.6 km'},
  ];

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  int _calculateFee(double dist) {
    if (dist <= 2.0) return 3000;
    final extra = dist - 2.0;
    return 3000 + (extra * 1000).ceil();
  }

  String _findNearestLandmark(double lat, double lng) {
    String nearest = 'Vijayawada';
    double minDist = 999.0;
    for (final lm in _landmarks) {
      final d = _haversine(lat, lng, lm['lat'] as double, lm['lng'] as double);
      if (d < minDist) {
        minDist = d;
        nearest = '${lm['name']} (${d.toStringAsFixed(1)} km)';
      }
    }
    return nearest;
  }

  void _updatePosition(double lat, double lng) {
    // Clamp to map bounds
    final clampedLat = lat.clamp(minLat, maxLat);
    final clampedLng = lng.clamp(minLng, maxLng);

    setState(() {
      _currentLat = clampedLat;
      _currentLng = clampedLng;
    });

    final dist = _haversine(outletLat, outletLng, clampedLat, clampedLng);
    final serviceable = dist <= maxRadiusKm;
    final fee = serviceable ? _calculateFee(dist) : 0;
    final landmark = _findNearestLandmark(clampedLat, clampedLng);

    widget.onLocationChanged(MapLocation(
      latitude: double.parse(clampedLat.toStringAsFixed(4)),
      longitude: double.parse(clampedLng.toStringAsFixed(4)),
      distanceKm: double.parse(dist.toStringAsFixed(2)),
      isServiceable: serviceable,
      feePaise: fee,
      nearestLandmark: landmark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dist = _haversine(outletLat, outletLng, _currentLat, _currentLng);
    final isServiceable = dist <= maxRadiusKm;
    final fee = isServiceable ? _calculateFee(dist) : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, size: 18, color: AppTheme.cocoa),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Interactive Vijayawada Map Pin Drop',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isServiceable ? AppTheme.mint : AppTheme.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isServiceable ? '${dist.toStringAsFixed(1)} km • ₹${fee ~/ 100} Rapido' : 'Out of 5 km Range',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Map Canvas
          ClipRRect(
            child: SizedBox(
              height: 230,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  const h = 230.0;

                  // Convert Lat/Lng to pixel X/Y
                  double toX(double lng) => ((lng - minLng) / (maxLng - minLng)) * w;
                  double toY(double lat) => (1.0 - (lat - minLat) / (maxLat - minLat)) * h;

                  // Convert pixel X/Y back to Lat/Lng
                  double toLng(double x) => minLng + (x / w) * (maxLng - minLng);
                  double toLat(double y) => maxLat - (y / h) * (maxLat - minLat);

                  final pinX = toX(_currentLng);
                  final pinY = toY(_currentLat);
                  final outletX = toX(outletLng);
                  final outletY = toY(outletLat);

                  return GestureDetector(
                    onTapDown: (details) {
                      final lat = toLat(details.localPosition.dy);
                      final lng = toLng(details.localPosition.dx);
                      _updatePosition(lat, lng);
                    },
                    onPanUpdate: (details) {
                      final lat = toLat(details.localPosition.dy);
                      final lng = toLng(details.localPosition.dx);
                      _updatePosition(lat, lng);
                    },
                    onPanStart: (_) => setState(() => _isDragging = true),
                    onPanEnd: (_) => setState(() => _isDragging = false),
                    onPanCancel: () => setState(() => _isDragging = false),
                    child: Stack(
                      children: [
                        // Custom Painted Map Background (Waterways, Roads, 5km circle)
                        CustomPaint(
                          size: Size(w, h),
                          painter: _VijayawadaMapPainter(
                            outletX: outletX,
                            outletY: outletY,
                            radiusPixels: (maxRadiusKm / 6.0) * (w / 2.5),
                          ),
                        ),

                        // Landmark labels
                        ..._landmarks.map((lm) {
                          final lx = toX(lm['lng'] as double);
                          final ly = toY(lm['lat'] as double);
                          final isOutlet = lm['name'] == 'Auto Nagar Gate';
                          return Positioned(
                            left: lx - 30,
                            top: ly + (isOutlet ? 14 : 6),
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 0.5),
                                ),
                                child: Text(
                                  lm['name'] as String,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isOutlet ? FontWeight.w800 : FontWeight.w600,
                                    color: isOutlet ? AppTheme.saffronDark : AppTheme.cocoa,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // Outlet Location Pin (Auto Nagar)
                        Positioned(
                          left: outletX - 14,
                          top: outletY - 14,
                          child: IgnorePointer(
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.saffron,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.cocoa, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('🥛', style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          ),
                        ),

                        // User Selected Delivery Pin (Animated Lift & Drop like Rapido)
                        Positioned(
                          left: pinX - 16,
                          top: pinY - (_isDragging ? 44 : 32),
                          child: IgnorePointer(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isServiceable ? AppTheme.cocoa : AppTheme.error,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: _isDragging ? 0.3 : 0.15),
                                        blurRadius: _isDragging ? 8 : 4,
                                        offset: Offset(0, _isDragging ? 6 : 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _isDragging
                                        ? 'Release to Set Drop'
                                        : (isServiceable ? 'Drop Here' : 'Out of range'),
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Icon(
                                  Icons.location_on,
                                  color: isServiceable ? AppTheme.rose : AppTheme.error,
                                  size: _isDragging ? 38 : 32,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: _isDragging ? 0.4 : 0.2),
                                      blurRadius: _isDragging ? 8 : 4,
                                      offset: Offset(0, _isDragging ? 6 : 2),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Map hint overlay
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '👆 Drag map to adjust pin position',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        // Reset to Outlet GPS Button
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: FloatingActionButton.small(
                            heroTag: 'map_locate_btn',
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.cocoa,
                            elevation: 2,
                            tooltip: 'Center on Auto Nagar',
                            onPressed: () => _updatePosition(16.5020, 80.6680),
                            child: const Icon(Icons.my_location, size: 18),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Quick Landmark Selector Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _landmarks.map((lm) {
                final lat = lm['lat'] as double;
                final lng = lm['lng'] as double;
                final isSelected = (_haversine(lat, lng, _currentLat, _currentLng) < 0.3);
                return ActionChip(
                  avatar: Icon(
                    isSelected ? Icons.check_circle : Icons.location_pin,
                    size: 14,
                    color: isSelected ? AppTheme.saffronDark : AppTheme.muted,
                  ),
                  label: Text(
                    '${lm['name']} (${lm['sub']})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.cocoa : AppTheme.cocoa,
                    ),
                  ),
                  backgroundColor: isSelected ? AppTheme.cream : Colors.grey[100],
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _updatePosition(lat, lng),
                );
              }).toList(),
            ),
          ),

          // Rapido Bike Parcel Fare Card
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isServiceable ? AppTheme.cream : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isServiceable ? AppTheme.saffron : AppTheme.error),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Center(
                    child: Text('🛵', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rapido Bike Parcel',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.cocoa),
                          ),
                          Text(
                            isServiceable ? '₹${fee ~/ 100}' : 'Blocked',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isServiceable ? AppTheme.cocoa : AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isServiceable
                            ? '8-12m pickup • ₹30 base (2 km) + ₹10/km (${dist.toStringAsFixed(1)} km)'
                            : 'Exceeds 5.0 km freshness radius limit',
                        style: TextStyle(fontSize: 11, color: isServiceable ? AppTheme.muted : AppTheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VijayawadaMapPainter extends CustomPainter {
  final double outletX;
  final double outletY;
  final double radiusPixels;

  _VijayawadaMapPainter({
    required this.outletX,
    required this.outletY,
    required this.radiusPixels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background terrain (soft warm parchment)
    final bgPaint = Paint()..color = const Color(0xFFF9F6F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Krishna River (light blue curve across south-west)
    final riverPaint = Paint()
      ..color = const Color(0xFFD6E9FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(0, size.height * 0.85)
      ..cubicTo(
        size.width * 0.25, size.height * 0.95,
        size.width * 0.6, size.height * 0.70,
        size.width, size.height * 0.80,
      );
    canvas.drawPath(riverPath, riverPaint);

    // 3. Grid road network (Bandar Road, MG Road, Ring Road)
    final roadPaint = Paint()
      ..color = const Color(0xFFE5DDD3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Bandar Road (diagonal NW to SE)
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.75),
      roadPaint,
    );

    // MG Road
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.4),
      Offset(size.width * 0.85, size.height * 0.4),
      roadPaint..strokeWidth = 2,
    );

    // Ring Road curve
    final ringPaint = Paint()
      ..color = const Color(0xFFEBE3D9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.5), radius: size.width * 0.42),
      -pi / 3,
      pi * 1.2,
      false,
      ringPaint,
    );

    // 4. 5.0 km Service Radius Circle
    // Soft transparent fill
    final radiusFillPaint = Paint()
      ..color = const Color(0xFF72B7A1).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(outletX, outletY), radiusPixels, radiusFillPaint);

    // Dashed / solid boundary border
    final radiusBorderPaint = Paint()
      ..color = const Color(0xFFCE8822).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(outletX, outletY), radiusPixels, radiusBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _VijayawadaMapPainter oldDelegate) {
    return oldDelegate.outletX != outletX ||
        oldDelegate.outletY != outletY ||
        oldDelegate.radiusPixels != radiusPixels;
  }
}
