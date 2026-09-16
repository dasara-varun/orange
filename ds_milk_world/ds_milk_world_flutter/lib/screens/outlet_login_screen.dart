import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'staff_console_screen.dart';

class OutletLoginScreen extends StatefulWidget {
  const OutletLoginScreen({super.key});

  @override
  State<OutletLoginScreen> createState() => _OutletLoginScreenState();
}

class _OutletLoginScreenState extends State<OutletLoginScreen> with SingleTickerProviderStateMixin {
  late TabController _authTabController;
  
  // Named Account fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // PIN fields
  String _enteredPin = '';
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _authTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _authTabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
      _navigateToConsole(role: 'administrator');
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Enter valid staff PIN (Default: 1979)';
        _enteredPin = '';
      });
    }
  }

  Future<void> _loginWithCredentials() async {
    final user = _usernameController.text.trim();
    final pass = _passwordController.text;
    if (user.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Please enter both username and password.');
      return;
    }
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final role = await ApiService.instance.authenticateStaff(user, pass);
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (role != null) {
      _navigateToConsole(role: role);
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password. Check staff credentials.';
      });
    }
  }

  void _navigateToConsole({required String role}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StaffConsoleScreen(
          staffRole: role,
          onBackToStorefront: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OutletLoginScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.milk,
      appBar: AppBar(
        title: const Text('Outlet Staff Portal'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.cocoa,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                      child: Text('👨‍🍳', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Kanuru Counter Console',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'DS Milk World • Bandar Road, Kanuru, Vijayawada',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                  const SizedBox(height: 18),

                  // Auth Mode Segmented Tab
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: TabBar(
                      controller: _authTabController,
                      indicator: BoxDecoration(
                        color: AppTheme.cocoa,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.cocoa,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Named Account'),
                        Tab(text: 'Quick PIN'),
                      ],
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: AppTheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      controller: _authTabController,
                      children: [
                        _buildNamedAccountTab(),
                        _buildPinPadTab(),
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

  Widget _buildNamedAccountTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Staff Username',
            hintText: 'e.g. kitchen, dispatch, admin',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cocoa,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isVerifying ? null : _loginWithCredentials,
            icon: _isVerifying
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.login, size: 18),
            label: Text(
              _isVerifying ? 'Authenticating...' : 'Sign In to Console',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinPadTab() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // PIN indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < _enteredPin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16,
              height: 16,
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
        const SizedBox(height: 14),
        // Number pad
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((digit) {
                return _buildKey(digit, () => _onDigitPressed(digit));
              }),
              _buildKey('C', _onClear, isAction: true),
              _buildKey('0', () => _onDigitPressed('0')),
              _buildKey('⌫', _onBackspace, isAction: true),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildKey(String label, VoidCallback onTap, {bool isAction = false}) {
    return Material(
      color: isAction ? Colors.grey[200] : Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: isAction ? 0 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isAction ? AppTheme.muted : AppTheme.cocoa,
            ),
          ),
        ),
      ),
    );
  }
}
