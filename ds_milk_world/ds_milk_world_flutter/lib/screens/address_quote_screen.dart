import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import '../services/api_service.dart';
import '../widgets/interactive_map_picker.dart';
import 'checkout_screen.dart';
import 'location_picker_screen.dart';

class AddressQuoteScreen extends StatefulWidget {
  final MapLocation? initialLocation;

  const AddressQuoteScreen({super.key, this.initialLocation});

  @override
  State<AddressQuoteScreen> createState() => _AddressQuoteScreenState();
}

class _AddressQuoteScreenState extends State<AddressQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();

  bool _consentTransactionalEmail = true;

  // Selected coordinates (from map selection)
  double _selectedLat = 16.4854333;
  double _selectedLng = 80.6874703;
  String? _landmarkName;

  bool _isLoadingQuote = false;
  DeliveryQuote? _quote;
  bool _isSubmitting = false;

  void _onMapLocationChanged(MapLocation loc) {
    setState(() {
      _selectedLat = loc.latitude;
      _selectedLng = loc.longitude;
      _landmarkName = loc.nearestLandmark;
      final roadInfo = loc.roadDistanceText != null
          ? '${loc.roadDistanceText} (~${loc.durationMinutes ?? 12} mins ETA)'
          : '${loc.distanceKm} km from Kanuru';
      _quote = DeliveryQuote(
        serviceable: loc.isServiceable,
        distanceKm: loc.distanceKm,
        feePaise: loc.feePaise,
        message: loc.isServiceable
            ? 'Serviceable ($roadInfo • Direct Cold Chain)'
            : 'Delivery location is ${loc.distanceKm} km away. Maximum service radius is 5.0 km.',
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      final loc = widget.initialLocation!;
      _selectedLat = loc.latitude;
      _selectedLng = loc.longitude;
      _landmarkName = loc.nearestLandmark;
      _quote = DeliveryQuote(
        serviceable: loc.isServiceable,
        distanceKm: loc.distanceKm,
        feePaise: loc.feePaise,
        message: 'Delivery location confirmed (${loc.distanceKm} km from Kanuru)',
      );
    } else {
      _fetchQuote();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
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


  Future<void> _handleProceed() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consentTransactionalEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please consent to receiving transactional invoices via email to proceed.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
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
      final landmarkText = _landmarkController.text.trim();
      final specialNotes = CartState.instance.instructions.trim();
      final combinedLandmark = [
        if (landmarkText.isNotEmpty) landmarkText,
        if (specialNotes.isNotEmpty) 'Note: $specialNotes',
      ].join(' | ');

      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid 10-digit mobile number (compulsory).'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }
      final validName = _nameController.text.trim();
      if (validName.isEmpty || validName.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your full name (compulsory, min 2 characters).'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      final order = await ApiService.instance.createOrder(
        customerPhone: '+91 $cleanPhone',
        customerEmail: _emailController.text.trim(),
        customerName: validName,
        deliveryAddress: _addressController.text.trim(),
        landmark: combinedLandmark.isEmpty ? null : combinedLandmark,
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/images/ds_logo_icon.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Delivering from DS Milk World, Kanuru Center, Bandar Road, Vijayawada (Max 5.0 km radius)',
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
                        final digits = val?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                        if (digits.length != 10) {
                          return 'Enter valid 10-digit mobile number';
                        }
                        if (!RegExp(r'^[6-9]').hasMatch(digits)) {
                          return 'Mobile must start with 6, 7, 8, or 9';
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
                        labelText: 'Full Name *',
                        hintText: 'Your full name',
                      ),
                      validator: (val) {
                        final name = val?.trim() ?? '';
                        if (name.isEmpty) {
                          return 'Full name is compulsory';
                        }
                        if (name.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address * (For Tax Invoice)',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                  hintText: 'name@domain.com',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Email is compulsory for invoice delivery';
                  }
                  if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(val.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppTheme.saffronDark,
                value: _consentTransactionalEmail,
                onChanged: (val) => setState(() => _consentTransactionalEmail = val ?? false),
                title: const Text(
                  'I consent to receive order updates & tax invoice via email upon completion.',
                  style: TextStyle(fontSize: 12, color: AppTheme.cocoa),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),

              if (widget.initialLocation != null || _landmarkName != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.cocoa,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on, color: AppTheme.saffron, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _landmarkName ?? 'Kanuru, Bandar Road',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.cocoa),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_quote?.distanceKm.toStringAsFixed(1) ?? "0.5"} km from Kanuru • ₹${((_quote?.feePaise ?? 3000) / 100).toInt()} Delivery Fee',
                              style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.cocoa,
                          side: const BorderSide(color: AppTheme.cocoa),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.map_outlined, size: 14),
                        label: const Text('Change Pin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        onPressed: () async {
                          final newLoc = await Navigator.push<MapLocation>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LocationPickerScreen(
                                initialLat: _selectedLat,
                                initialLng: _selectedLng,
                                returnOnConfirm: true,
                              ),
                            ),
                          );
                          if (newLoc != null && mounted) {
                            _onMapLocationChanged(newLoc);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                InkWell(
                  onTap: () async {
                    final newLoc = await Navigator.push<MapLocation>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LocationPickerScreen(
                          initialLat: _selectedLat,
                          initialLng: _selectedLng,
                          returnOnConfirm: true,
                        ),
                      ),
                    );
                    if (newLoc != null && mounted) {
                      _onMapLocationChanged(newLoc);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.saffronDark),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map, color: AppTheme.cocoa, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Pin Delivery Location on Map',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.cocoa),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Select your exact location on our full-screen map',
                                style: TextStyle(fontSize: 12, color: AppTheme.muted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppTheme.cocoa),
                      ],
                    ),
                  ),
                ),
              ],
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
    ),
  ),
);
  }
}