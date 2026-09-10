import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'staff_console_screen.dart';

class OutletLoginScreen extends StatefulWidget {
  final VoidCallback? onBackToCustomer;

  const OutletLoginScreen({super.key, this.onBackToCustomer});

  @override
  State<OutletLoginScreen> createState() => _OutletLoginScreenState();
}

class _OutletLoginScreenState extends State<OutletLoginScreen> {
  String _enteredPin = '';
  bool _isVerifying = false;
  String? _errorMessage;

  void _onDigitPressed(String digit) {
    if (_isVerifying) return;
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = null;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_isVerifying) return;
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _onClear() {
    if (_isVerifying) return;
    setState(() {
      _enteredPin = '';
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    final pinToCheck = _enteredPin;
    final isValid = await ApiService.instance.verifyStaffPin(pinToCheck);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StaffConsoleScreen(
            onBackToStorefront: () {
              if (widget.onBackToCustomer != null) {
                widget.onBackToCustomer!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Enter valid staff PIN (Default: 1979)';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.milk,
      appBar: AppBar(
        title: const Text('Outlet Staff Portal'),
        leading: widget.onBackToCustomer != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackToCustomer,
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.cocoa,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                      child: Text('👨‍🍳', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kanuru Counter Console',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter 4-digit staff PIN to access order management & kitchen display',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 24),

                  // PIN indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _enteredPin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isFilled ? AppTheme.saffronDark : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFilled ? AppTheme.saffronDark : AppTheme.cocoa.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Number pad
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((digit) {
                        return _buildKey(digit, () => _onDigitPressed(digit));
                      }),
                      _buildKey('C', _onClear, isAction: true),
                      _buildKey('0', () => _onDigitPressed('0')),
                      _buildKey('⌫', _onBackspace, isAction: true),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.key, size: 14, color: AppTheme.cocoa),
                        SizedBox(width: 6),
                        Text(
                          'Staff PIN: 1979',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.cocoa),
                        ),
                      ],
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

  Widget _buildKey(String label, VoidCallback onTap, {bool isAction = false}) {
    return Material(
      color: isAction ? Colors.grey[200] : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: isAction ? 0 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isAction ? AppTheme.muted : AppTheme.cocoa,
            ),
          ),
        ),
      ),
    );
  }
}
