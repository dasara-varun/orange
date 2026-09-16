import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../services/rapido_live_service.dart';
import '../widgets/interactive_map_picker.dart';
import 'address_quote_screen.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final bool returnOnConfirm;

  const LocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.returnOnConfirm = false,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Outlet coordinates (D.S MILK WORLD - Kanuru Center, Bandar Road, Vijayawada)
  static const double outletLat = 16.4854333;
  static const double outletLng = 80.6874703;
  static const double maxRadiusKm = 5.0;

  // Geographic boundary clamp for Vijayawada delivery region
  static const double minLat = 16.3500;
  static const double maxLat = 16.6500;
  static const double minLng = 80.5000;
  static const double maxLng = 80.8000;

  late double _currentLat;
  late double _currentLng;
  final MapController _mapController = MapController();

  final TextEditingController _searchController = TextEditingController();
  List<AddressSearchResult> _searchResults = [];
  bool _isLocating = false;

  RapidoLiveQuote? _liveQuote;
  bool _isLoadingQuote = false;
  Timer? _debounceTimer;

  // Curated Vijayawada localities for instant search
  final List<AddressSearchResult> _localities = [
    AddressSearchResult(
      title: 'Kanuru Center (D.S MILK WORLD)',
      fullAddress: 'Bandar Road, Near Kanuru Center, Vijayawada, AP 520007',
      latitude: 16.4854333,
      longitude: 80.6874703,
    ),
    AddressSearchResult(
      title: 'Tadigadapa',
      fullAddress: 'Tadigadapa Donka Road, Bandar Road, Vijayawada, AP 521137',
      latitude: 16.4800,
      longitude: 80.6800,
    ),
    AddressSearchResult(
      title: 'Poranki Center',
      fullAddress: 'Poranki Main Road, Bandar Road, Vijayawada, AP 521137',
      latitude: 16.4780,
      longitude: 80.7050,
    ),
    AddressSearchResult(
      title: 'Auto Nagar Gate',
      fullAddress: 'Auto Nagar Main Road, Vijayawada, AP 520007',
      latitude: 16.4950,
      longitude: 80.6650,
    ),
    AddressSearchResult(
      title: 'Patamata',
      fullAddress: 'High School Road, Patamata, Vijayawada, AP 520010',
      latitude: 16.4980,
      longitude: 80.6500,
    ),
    AddressSearchResult(
      title: 'Benz Circle',
      fullAddress: 'M.G. Road, Benz Circle, Vijayawada, AP 520010',
      latitude: 16.5000,
      longitude: 80.6400,
    ),
    AddressSearchResult(
      title: 'Enikepadu',
      fullAddress: 'National Highway 16, Enikepadu, Vijayawada, AP 521108',
      latitude: 16.5150,
      longitude: 80.6950,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLat ?? outletLat;
    _currentLng = widget.initialLng ?? outletLng;
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
    const double r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  String _findNearestLandmark(double lat, double lng) {
    double minD = double.infinity;
    String best = 'Kanuru, Bandar Road';
    for (final loc in _localities) {
      final d = _haversine(lat, lng, loc.latitude, loc.longitude);
      if (d < minD) {
        minD = d;
        best = loc.title;
      }
    }
    return best;
  }

  void _onMapPanned(LatLng center) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchQuoteForPosition(center.latitude, center.longitude);
    });
  }

  Future<void> _fetchQuoteForPosition(double lat, double lng) async {
    final clampedLat = lat.clamp(minLat, maxLat);
    final clampedLng = lng.clamp(minLng, maxLng);

    setState(() {
      _currentLat = clampedLat;
      _currentLng = clampedLng;
      _isLoadingQuote = true;
    });

    final quote = await RapidoLiveService.fetchLiveRapidoQuote(
      dropLat: clampedLat,
      dropLng: clampedLng,
    );

    if (mounted) {
      setState(() {
        _liveQuote = quote;
        _isLoadingQuote = false;
      });
    }
  }

  void _searchAddress(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final matches = _localities.where((loc) {
      return loc.title.toLowerCase().contains(q) || loc.fullAddress.toLowerCase().contains(q);
    }).toList();

    setState(() {
      _searchResults = matches;
    });
  }

  void _selectSearchResult(AddressSearchResult item) {
    _searchController.text = item.title;
    setState(() => _searchResults = []);
    _moveToLocation(item.latitude, item.longitude);
  }

  void _moveToLocation(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 15.5);
    _fetchQuoteForPosition(lat, lng);
  }

  void _zoomIn() {
    final z = (_mapController.camera.zoom + 1.0).clamp(10.0, 18.0);
    _mapController.move(_mapController.camera.center, z);
  }

  void _zoomOut() {
    final z = (_mapController.camera.zoom - 1.0).clamp(10.0, 18.0);
    _mapController.move(_mapController.camera.center, z);
  }

  void _centerOnOutlet() {
    _moveToLocation(outletLat, outletLng);
  }

  Future<void> _locateMe() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS location services are disabled on this device.'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 8)),
      );
      _moveToLocation(pos.latitude, pos.longitude);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not fetch GPS location. Please drag the map pin.'),
            backgroundColor: AppTheme.cocoa,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _confirmLocation() {
    final dist = _haversine(outletLat, outletLng, _currentLat, _currentLng);
    final isServiceable = _liveQuote?.isServiceable ?? (dist <= maxRadiusKm);
    if (!isServiceable) return;

    final landmark = _findNearestLandmark(_currentLat, _currentLng);
    final fee = _liveQuote?.totalFeePaise ?? (dist <= 2.0 ? 3000 : 3000 + ((dist - 2.0) * 1000).ceil());

    final mapLoc = MapLocation(
      latitude: double.parse(_currentLat.toStringAsFixed(5)),
      longitude: double.parse(_currentLng.toStringAsFixed(5)),
      distanceKm: _liveQuote?.roadDistanceKm ?? double.parse(dist.toStringAsFixed(1)),
      isServiceable: true,
      feePaise: fee,
      nearestLandmark: landmark,
      roadDistanceText: '${_liveQuote?.roadDistanceKm ?? dist.toStringAsFixed(1)} km road distance',
      durationMinutes: _liveQuote?.durationMinutes ?? 20,
      providerSource: _liveQuote?.providerSource ?? 'direct_cold_chain',
    );

    if (widget.returnOnConfirm) {
      Navigator.pop(context, mapLoc);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddressQuoteScreen(initialLocation: mapLoc),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dist = _haversine(outletLat, outletLng, _currentLat, _currentLng);
    final isServiceable = _liveQuote?.isServiceable ?? (dist <= maxRadiusKm);
    final fee = _liveQuote?.totalFeePaise ?? (dist <= 2.0 ? 3000 : 3000 + ((dist - 2.0) * 1000).ceil());
    final landmark = _findNearestLandmark(_currentLat, _currentLng);

    return Scaffold(
      backgroundColor: AppTheme.milk,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Select Delivery Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              'D.S MILK WORLD • Kanuru Center (5 km Max Radius)',
              style: TextStyle(fontSize: 11, color: AppTheme.cream),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront, color: AppTheme.saffron),
            tooltip: 'Center on Kanuru Outlet',
            onPressed: _centerOnOutlet,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full-Screen Interactive OpenStreetMap Canvas
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_currentLat, _currentLng),
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
              onTap: (_, point) => _moveToLocation(point.latitude, point.longitude),
            ),
            children: [
              // 100% Free OpenStreetMap Standard Tiles (No API key, zero Carto)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'in.isroot.dsmilkworld',
                maxZoom: 19,
              ),

              // 5.0 km Freshness Service Radius Circle around D.S MILK WORLD
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: const LatLng(outletLat, outletLng),
                    radius: maxRadiusKm * 1000,
                    useRadiusInMeter: true,
                    color: const Color(0xFF72B7A1).withValues(alpha: 0.12),
                    borderColor: const Color(0xFFE8A23A),
                    borderStrokeWidth: 2.5,
                  ),
                  CircleMarker(
                    point: const LatLng(outletLat, outletLng),
                    radius: (maxRadiusKm * 1000) - 50,
                    useRadiusInMeter: true,
                    color: Colors.transparent,
                    borderColor: const Color(0xFFE8A23A).withValues(alpha: 0.4),
                    borderStrokeWidth: 1.0,
                  ),
                ],
              ),

              // Polyline connecting Outlet to Delivery Location
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

              // D.S MILK WORLD Outlet Marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(outletLat, outletLng),
                    width: 180,
                    height: 52,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.cocoa,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🥛', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 4),
                              Text(
                                'D.S MILK WORLD',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppTheme.cocoa, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top Search Bar & Auto-Suggestions Overlay
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchAddress,
                    decoration: InputDecoration(
                      hintText: 'Search Vijayawada locality (e.g. Benz Circle, Poranki)...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.muted),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.cocoa),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
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
                          leading: const Icon(Icons.location_on, size: 18, color: AppTheme.saffronDark),
                          title: Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.cocoa)),
                          subtitle: Text(item.fullAddress, style: const TextStyle(fontSize: 11, color: AppTheme.muted), maxLines: 1),
                          onTap: () => _selectSearchResult(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Fixed Center Delivery Target Pin with Live Indicator
          Center(
            child: FractionalTranslation(
              translation: const Offset(0.0, -0.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Floating status pill above pin
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isServiceable ? AppTheme.cocoa : AppTheme.error,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isServiceable ? Icons.check_circle : Icons.warning_amber,
                          size: 13,
                          color: isServiceable ? AppTheme.saffron : Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isServiceable
                              ? '₹${fee ~/ 100} • ${dist.toStringAsFixed(1)} km'
                              : 'Out of 5 km Range (${dist.toStringAsFixed(1)} km)',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.location_pin,
                    size: 42,
                    color: isServiceable ? AppTheme.saffronDark : AppTheme.error,
                  ),
                ],
              ),
            ),
          ),

          // Floating Map Control Buttons (Zoom in, Zoom out, Locate me, Outlet center)
          Positioned(
            right: 14,
            bottom: 220,
            child: Column(
              children: [
                _mapControlButton(
                  icon: Icons.add,
                  tooltip: 'Zoom In',
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Icons.remove,
                  tooltip: 'Zoom Out',
                  onPressed: _zoomOut,
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: _isLocating ? Icons.hourglass_top : Icons.my_location,
                  tooltip: 'Locate Me (GPS)',
                  onPressed: _locateMe,
                  iconColor: AppTheme.cocoa,
                ),
                const SizedBox(height: 8),
                _mapControlButton(
                  icon: Icons.store,
                  tooltip: 'Center on D.S MILK WORLD',
                  onPressed: _centerOnOutlet,
                  iconColor: AppTheme.saffronDark,
                ),
              ],
            ),
          ),

          // Bottom Location Confirmation Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isServiceable ? AppTheme.cream : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isServiceable ? AppTheme.saffron : AppTheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            isServiceable ? Icons.place : Icons.location_off,
                            color: isServiceable ? AppTheme.cocoa : AppTheme.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                landmark,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isServiceable
                                    ? '${dist.toStringAsFixed(1)} km from Kanuru • ~${_liveQuote?.durationMinutes ?? 20} mins prep & delivery'
                                    : 'Selected location is ${dist.toStringAsFixed(1)} km away. Direct delivery limited to 5.0 km.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isServiceable ? AppTheme.muted : AppTheme.error,
                                  fontWeight: isServiceable ? FontWeight.w500 : FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isServiceable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isServiceable ? '₹${fee ~/ 100} Delivery' : 'Out of Area',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isServiceable ? const Color(0xFF2E7D32) : AppTheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isServiceable ? AppTheme.cocoa : Colors.grey[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: isServiceable ? 2 : 0,
                        ),
                        onPressed: isServiceable ? _confirmLocation : null,
                        icon: _isLoadingQuote
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.arrow_forward, size: 18),
                        label: Text(
                          isServiceable
                              ? 'Confirm Location & Enter Address →'
                              : 'Location Out of 5 km Service Area',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color iconColor = AppTheme.cocoa,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
