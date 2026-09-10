import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/outlet_header.dart';
import '../widgets/category_rail.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_drawer.dart';
import 'outlet_login_screen.dart';
import 'order_history_screen.dart';

class StorefrontScreen extends StatefulWidget {
  const StorefrontScreen({super.key});

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  StoreCatalog? _catalog;
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isStaffMode = false;

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  Future<void> _fetchCatalog() async {
    setState(() => _isLoading = true);
    try {
      final cat = await ApiService.instance.getCatalog();
      if (mounted) {
        setState(() {
          _catalog = cat;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Product> _getFilteredProducts() {
    if (_catalog == null) return [];
    return _catalog!.products.where((p) {
      final matchesCategory = _selectedCategory == 'all' || p.categoryName == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.shortDescription != null && p.shortDescription!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<List<Product>> _getGroupedProducts() {
    final filtered = _getFilteredProducts();
    final Map<String, List<Product>> groups = {};
    for (final p in filtered) {
      final key = '${p.categoryName}__${p.name}';
      groups.putIfAbsent(key, () => []).add(p);
    }
    return groups.values.toList();
  }

  Map<String, int> _getCategoryItemCounts() {
    if (_catalog == null) return {};
    final Map<String, Set<String>> categoryItemNames = {};
    for (final p in _catalog!.products) {
      categoryItemNames.putIfAbsent(p.categoryName, () => <String>{}).add(p.name);
    }
    return categoryItemNames.map((key, val) => MapEntry(key, val.length));
  }

  @override
  Widget build(BuildContext context) {
    if (_isStaffMode) {
      return OutletLoginScreen(
        onBackToCustomer: () => setState(() => _isStaffMode = false),
      );
    }

    final groupedProducts = _getGroupedProducts();
    final categoryCounts = _getCategoryItemCounts();

    return Scaffold(
      backgroundColor: AppTheme.milk,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                // Outlet Header
                OutletHeader(
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  onToggleStaffMode: () => setState(() => _isStaffMode = !_isStaffMode),
                  onOpenHistory: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                  ),
                  isStaffMode: _isStaffMode,
                ),
                // Category Rail
                if (_catalog != null)
                  CategoryRail(
                    categories: _catalog!.categories,
                    selectedCategory: _selectedCategory,
                    onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
                    itemCounts: categoryCounts,
                  ),
                // Product List / Grid
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppTheme.saffron),
                        )
                      : groupedProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off, size: 48, color: AppTheme.muted),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No matching items found for "$_searchQuery"',
                                    style: const TextStyle(color: AppTheme.muted, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 90),
                              itemCount: groupedProducts.length,
                              itemBuilder: (context, idx) => ProductCard(variants: groupedProducts[idx]),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FloatingCartBar(),
    );
  }
}
