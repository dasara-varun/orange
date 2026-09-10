import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../services/rapido_live_service.dart';

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
  final String? roadDistanceText;
  final int? durationMinutes;
  final String? providerSource;

  MapLocation({
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.isServiceable,
    required this.feePaise,
    required this.nearestLandmark,
    this.roadDistanceText,
    this.durationMinutes,
    this.providerSource,
  });
}

class _InteractiveMapPickerState extends State<InteractiveMapPicker> {
  // Outlet coordinates (Kanuru Counter)
  static const double outletLat = 16.4850;
  static const double outletLng = 80.6900;
  static const double maxRadiusKm = 5.0;

  // Vijayawada geographic bounds for fallback clamping
  static const double minLat = 16.3500;
  static const double maxLat = 16.6500;
  static const double minLng = 80.5000;
  static const double maxLng = 80.8000;

  late double _currentLat;
  late double _currentLng;
  bool _isLocating = false;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<AddressSearchResult> _searchResults = [];
  bool _isSearching = false;

  RapidoLiveQuote? _liveQuote;
  bool _isLoadingQuote = false;
  Timer? _debounceTimer;

  // Key Vijayawada landmarks for rapid reference around Kanuru
  final List<Map<String, dynamic>> _landmarks = [
    {'name': 'Kanuru Center', 'lat': 16.4850, 'lng': 80.6900, 'sub': 'Outlet Location'},
    {'name': 'Tadigadapa', 'lat': 16.4800, 'lng': 80.6800, 'sub': '1.2 km'},
    {'name': 'Poranki', 'lat': 16.4780, 'lng': 80.7050, 'sub': '1.8 km'},
    {'name': 'Auto Nagar Gate', 'lat': 16.4950, 'lng': 80.6650, 'sub': '2.9 km'},
    {'name': 'Patamata', 'lat': 16.4980, 'lng': 80.6500, 'sub': '4.2 km'},
    {'name': 'Benz Circle', 'lat': 16.5000, 'lng': 80.6400, 'sub': '4.9 km'},
  ];

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat;
    _currentLng = widget.initialLng;
    _fetchQuoteForPosition(_currentLat, _currentLng);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
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

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await RapidoLiveService.searchAddress(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(AddressSearchResult res) {
    _searchController.text = res.title;
    setState(() => _searchResults = []);
    _moveToLocation(res.latitude, res.longitude, zoom: 15.5);
  }

  void _moveToLocation(double lat, double lng, {double? zoom}) {
    final clampedLat = lat.clamp(minLat, maxLat);
    final clampedLng = lng.clamp(minLng, maxLng);
    _mapController.move(
      LatLng(clampedLat, clampedLng),
      zoom ?? _mapController.camera.zoom,
    );
    _fetchQuoteForPosition(clampedLat, clampedLng);
  }

  void _onMapPanned(LatLng center) {
    setState(() {
      _currentLat = center.latitude;
      _currentLng = center.longitude;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fetchQuoteForPosition(center.latitude, center.longitude);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are turned off. Please enable GPS.'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied.'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied. Enable it in App Settings.'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      if (mounted) {
        _searchController.text = 'My Current GPS Location';
        _moveToLocation(position.latitude, position.longitude, zoom: 16.0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Centered on your exact doorstep GPS location!'),
            backgroundColor: AppTheme.mint,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get GPS location: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _fetchQuoteForPosition(double lat, double lng) async {
    final clampedLat = lat.clamp(minLat, maxLat);
    final clampedLng = lng.clamp(minLng, maxLng);

    setState(() {
      _currentLat = clampedLat;
      _currentLng = clampedLng;
      _isLoadingQuote = true;
    });

    final landmark = _findNearestLandmark(clampedLat, clampedLng);
    final quote = await RapidoLiveService.fetchLiveRapidoQuote(
      dropLat: clampedLat,
      dropLng: clampedLng,
    );

    if (mounted) {
      setState(() {
        _liveQuote = quote;
        _isLoadingQuote = false;
      });

      widget.onLocationChanged(MapLocation(
        latitude: double.parse(clampedLat.toStringAsFixed(4)),
        longitude: double.parse(clampedLng.toStringAsFixed(4)),
        distanceKm: quote.roadDistanceKm,
        isServiceable: quote.isServiceable,
        feePaise: quote.totalFeePaise,
        nearestLandmark: landmark,
        roadDistanceText: '${quote.roadDistanceKm} km road distance',
        durationMinutes: quote.durationMinutes,
        providerSource: quote.providerSource,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dist = _haversine(outletLat, outletLng, _currentLat, _currentLng);
    final isServiceable = _liveQuote?.isServiceable ?? (dist <= maxRadiusKm);
    final fee = _liveQuote?.totalFeePaise ?? 3000;

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
                const Icon(Icons.delivery_dining, size: 18, color: AppTheme.cocoa),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Live OpenStreetMap & Rapido Rate',
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
                    isServiceable
                        ? '₹${fee ~/ 100} • ${_liveQuote?.roadDistanceKm ?? dist.toStringAsFixed(1)} km road'
                        : 'Out of 5 km Range',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Customer Address Search Bar (Typing method)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: TextField(
              controller: _searchController,
              onChanged: _searchAddress,
              decoration: InputDecoration(
                hintText: 'Type your address / locality (e.g. Benz Circle)...',
                prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.muted),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : (_searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          )
                        : null),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF9F6F0),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
              ),
            ),
          ),

          // Live Search Suggestions Dropdown
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              constraints: const BoxConstraints(maxHeight: 160),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, idx) {
                  final item = _searchResults[idx];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on, size: 16, color: AppTheme.rose),
                    title: Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      item.fullAddress,
                      style: const TextStyle(fontSize: 10, color: AppTheme.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSearchResult(item),
                  );
                },
              ),
            ),

          // Live OpenStreetMap Canvas
          ClipRRect(
            child: SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(widget.initialLat, widget.initialLng),
                      initialZoom: 14.5,
                      minZoom: 10.0,
                      maxZoom: 18.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      onPositionChanged: (MapCamera camera, bool hasGesture) {
                        if (hasGesture) {
                          _onMapPanned(camera.center);
                        }
                      },
                      onTap: (tapPosition, point) {
                        _moveToLocation(point.latitude, point.longitude);
                      },
                    ),
                    children: [
                      // OpenStreetMap standard tile layer (Pure open source, zero API keys required)
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'org.openstreetmap.dsmilkworld',
                        maxZoom: 19,
                      ),

                      // 5.0 km Freshness Service Radius Circle
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: const LatLng(outletLat, outletLng),
                            radius: maxRadiusKm * 1000, // 5000 meters
                            useRadiusInMeter: true,
                            color: const Color(0xFF72B7A1).withValues(alpha: 0.14),
                            borderColor: const Color(0xFFCE8822),
                            borderStrokeWidth: 2.5,
                          ),
                          CircleMarker(
                            point: const LatLng(outletLat, outletLng),
                            radius: (maxRadiusKm * 1000) - 60,
                            useRadiusInMeter: true,
                            color: Colors.transparent,
                            borderColor: const Color(0xFFE8A23A).withValues(alpha: 0.4),
                            borderStrokeWidth: 1.0,
                          ),
                        ],
                      ),

                      // Delivery Route Polyline connecting Kanuru Outlet to Delivery Pin
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              const LatLng(outletLat, outletLng),
                              LatLng(_currentLat, _currentLng),
                            ],
                            strokeWidth: 3.0,
                            color: isServiceable ? AppTheme.saffronDark : AppTheme.error,
                            pattern: StrokePattern.dashed(segments: const [6, 4]),
                          ),
                        ],
                      ),

                      // Markers (Outlet and Delivery Location Pin)
                      MarkerLayer(
                        markers: [
                          // Outlet Marker (DS Milk World Kanuru)
                          Marker(
                            point: const LatLng(outletLat, outletLng),
                            width: 100,
                            height: 52,
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.saffronDark,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                                    ],
                                  ),
                                  child: const Text(
                                    'DS Outlet',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: AppTheme.saffron,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text('🥛', style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Customer Delivery Spot Marker anchored at LatLng(_currentLat, _currentLng)
                          Marker(
                            point: LatLng(_currentLat, _currentLng),
                            width: 120,
                            height: 76,
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isServiceable ? AppTheme.cocoa : AppTheme.error,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isServiceable ? 'Deliver Here' : 'Out of 5 km Limit',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Icon(
                                  Icons.location_on,
                                  color: isServiceable ? AppTheme.rose : AppTheme.error,
                                  size: 36,
                                  shadows: const [
                                    Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Top left: 5.0 km Freshness Perimeter badge
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified, size: 12, color: AppTheme.mint),
                          SizedBox(width: 4),
                          Text(
                            '5.0 km Freshness Radius',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.cocoa),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Map tap/drag instruction & OpenStreetMap attribution
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '© OpenStreetMap contributors • Tap map to set delivery pin',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // Top right: Zoom in / Zoom out buttons
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  _mapController.move(
                                    _mapController.camera.center,
                                    (_mapController.camera.zoom + 1).clamp(10.0, 18.0),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.add, size: 18, color: AppTheme.cocoa),
                                ),
                              ),
                              const Divider(height: 1, thickness: 0.5),
                              InkWell(
                                onTap: () {
                                  _mapController.move(
                                    _mapController.camera.center,
                                    (_mapController.camera.zoom - 1).clamp(10.0, 18.0),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.remove, size: 18, color: AppTheme.cocoa),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom right: GPS & Center on Outlet Buttons
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Center on Kanuru Outlet
                        FloatingActionButton.small(
                          heroTag: 'center_outlet_btn',
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.cocoa,
                          elevation: 2,
                          tooltip: 'Center on Kanuru Outlet',
                          onPressed: () => _moveToLocation(outletLat, outletLng, zoom: 14.5),
                          child: const Icon(Icons.storefront, size: 18),
                        ),
                        const SizedBox(width: 8),
                        // Device Current GPS Location
                        FloatingActionButton.small(
                          heroTag: 'device_gps_btn',
                          backgroundColor: AppTheme.mint,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          tooltip: 'Use My Current GPS Location',
                          onPressed: _isLocating ? null : _getCurrentLocation,
                          child: _isLocating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.my_location, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  onPressed: () => _moveToLocation(lat, lng),
                );
              }).toList(),
            ),
          ),

          // Real-Time Rapido Bike Parcel Fare Card
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Center(
                    child: Text('🛵', style: TextStyle(fontSize: 22)),
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
                          Row(
                            children: [
                              const Text(
                                'Rapido Bike Parcel',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.cocoa),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.saffronDark,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'REAL-TIME',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          _isLoadingQuote
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.saffronDark),
                                )
                              : Text(
                                  isServiceable ? '₹${fee ~/ 100}' : 'Blocked',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: isServiceable ? AppTheme.cocoa : AppTheme.error,
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isServiceable
                            ? '${_liveQuote?.roadDistanceKm ?? dist.toStringAsFixed(1)} km road (~${_liveQuote?.durationMinutes ?? 10}m ETA) • Base ₹30 + Dist ₹${((_liveQuote?.distanceFarePaise ?? 0) / 100).ceil()} + Plat ₹3'
                            : 'Exceeds 5.0 km freshness radius limit from Kanuru',
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
