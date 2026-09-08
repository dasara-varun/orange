import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import '../services/api_service.dart';
import 'checkout_screen.dart';

class AddressQuoteScreen extends StatefulWidget {
  const AddressQuoteScreen({super.key});

  @override
  State<AddressQuoteScreen> createState() => _AddressQuoteScreenState();
}

class _AddressQuoteScreenState extends State<AddressQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '9876543210');
  final _nameController = TextEditingController(text: 'Ravi Teja');
  final _addressController = TextEditingController(text: 'Flat 301, Sri Krishna Residency, Auto Nagar');
  final _landmarkController = TextEditingController(text: 'Near Auto Nagar Gate');

  // Pre-configured coordinate presets in Vijayawada for testing & ease of use
  final List<Map<String, dynamic>> _locationPresets = [
    {
      'name': 'Auto Nagar (1.2 km)',
      'lat': 16.5020,
      'lng': 80.6680,
      'address': 'Plot 45, Industrial Estate, Auto Nagar, Vijayawada',
    },
    {
      'name': 'Benz Circle (3.1 km)',
      'lat': 16.5000,
      'lng': 80.6400,
      'address': 'MG Road, Near Benz Circle, Vijayawada',
    },
    {
      'name': 'Patamata (2.3 km)',
      'lat': 16.4980,
      'lng': 80.6500,
      'address': 'High School Road, Patamata, Vijayawada',
    },
    {
      'name': 'Governorpet (4.6 km)',
      'lat': 16.5100,
      'lng': 80.6250,
      'address': 'Prakasam Road, Governorpet, Vijayawada',
    },
    {
      'name': 'Gannavaram Airport (14.5 km - Out of service)',
      'lat': 16.5300,
      'lng': 80.7900,
      'address': 'Airport Road, Gannavaram',
    },
  ];

  int _selectedPresetIndex = 0;
  double _selectedLat = 16.5020;
  double _selectedLng = 80.6680;

  bool _isLoadingQuote = false;
  DeliveryQuote? _quote;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuote() async {
    setState(() => _isLoadingQuote = true);
    try {
      final q = await ApiService.instance.getDeliveryQuote(_selectedLat, _selectedLng);
      setState(() {
        _quote = q;
        _isLoadingQuote = false;
      });
    } catch (e) {
      setState(() => _isLoadingQuote = false);
    }
  }

  void _onPresetChanged(int index) {
    setState(() {
      _selectedPresetIndex = index;
      _selectedLat = _locationPresets[index]['lat'] as double;
      _selectedLng = _locationPresets[index]['lng'] as double;
      _addressController.text = _locationPresets[index]['address'] as String;
    });
    _fetchQuote();
  }

  Future<void> _handleProceed() async {
    if (!_formKey.currentState!.validate()) return;
    if (_quote == null || !_quote!.serviceable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot place order: Selected location is outside 5 km delivery radius.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final order = await ApiService.instance.createOrder(
        customerPhone: '+91 ${_phoneController.text.trim()}',
        customerName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
        latitude: _selectedLat,
        longitude: _selectedLng,
        items: CartState.instance.items,
      );

      setState(() => _isSubmitting = false);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutScreen(order: order),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = CartState.instance.subtotalPaise;
    final fee = _quote?.feePaise ?? 0;
    final total = subtotal + fee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery & Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Outlet and radius context
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.store, color: AppTheme.cocoa, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Delivering from DS Milk World, Auto Nagar Gate, Bandar Road, Vijayawada (Max 5.0 km radius)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cocoa,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Contact Information',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number *',
                        prefixText: '+91 ',
                        hintText: '10-digit number',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 10) {
                          return 'Enter valid 10-digit mobile';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name (Optional)',
                        hintText: 'Your name',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Delivery Location / Preset',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a delivery neighborhood to test Haversine distance & fee calculation:',
                style: TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: List.generate(_locationPresets.length, (idx) {
                    final preset = _locationPresets[idx];
                    final isSel = _selectedPresetIndex == idx;
                    return RadioListTile<int>(
                      value: idx,
                      groupValue: _selectedPresetIndex,
                      activeColor: AppTheme.saffronDark,
                      dense: true,
                      title: Text(
                        preset['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: AppTheme.cocoa,
                        ),
                      ),
                      subtitle: Text(
                        'Coordinates: ${preset['lat']}, ${preset['lng']}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                      ),
                      onChanged: (val) {
                        if (val != null) _onPresetChanged(val);
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'House / Flat / Street Address *',
                  hintText: 'Detailed building name, street, locality',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _landmarkController,
                decoration: const InputDecoration(
                  labelText: 'Landmark (Optional)',
                  hintText: 'e.g. Near Krishna Temple, Opposite Water Tank',
                ),
              ),
              const SizedBox(height: 20),

              // Serviceability & Quote Card
              const Text(
                'Delivery Radius & Fee Calculation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
              ),
              const SizedBox(height: 8),
              if (_isLoadingQuote)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppTheme.saffron),
                  ),
                )
              else if (_quote != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _quote!.serviceable ? const Color(0xFFF1F8F5) : const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _quote!.serviceable ? AppTheme.mint : AppTheme.error,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _quote!.serviceable ? Icons.check_circle : Icons.cancel,
                            color: _quote!.serviceable ? const Color(0xFF2E7D32) : AppTheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _quote!.serviceable
                                ? 'Within Service Area (${_quote!.distanceKm} km)'
                                : 'Outside 5 km Delivery Radius',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _quote!.serviceable ? const Color(0xFF2E7D32) : AppTheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _quote!.message ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: _quote!.serviceable ? AppTheme.cocoa : AppTheme.error,
                        ),
                      ),
                      if (_quote!.serviceable) ...[
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Fee (₹30 base + ₹10/km > 2km):',
                              style: TextStyle(fontSize: 12, color: AppTheme.cocoa, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              AppTheme.formatPaise(_quote!.feePaise),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Order Total Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items Subtotal:', style: TextStyle(color: AppTheme.cocoa, fontSize: 13)),
                        Text(AppTheme.formatPaise(subtotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Fee:', style: TextStyle(color: AppTheme.cocoa, fontSize: 13)),
                        Text(
                          _quote != null && _quote!.serviceable ? AppTheme.formatPaise(fee) : '—',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.border, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total to Pay:',
                          style: TextStyle(color: AppTheme.cocoa, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          _quote != null && _quote!.serviceable ? AppTheme.formatPaise(total) : AppTheme.formatPaise(subtotal),
                          style: const TextStyle(color: AppTheme.cocoa, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _quote == null || !_quote!.serviceable ? null : _handleProceed,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cocoa),
                        )
                      : Text(
                          _quote != null && _quote!.serviceable
                              ? 'Proceed to Checkout (${AppTheme.formatPaise(total)}) →'
                              : 'Location Out of Range',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}