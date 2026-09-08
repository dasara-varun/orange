import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';

class CategoryRail extends StatelessWidget {
  final List<Category> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const CategoryRail({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  Color _getCategoryColor(String slug) {
    switch (slug) {
      case 'falooda':
        return AppTheme.rose;
      case 'our-specials':
        return AppTheme.saffronDark;
      case 'thick-shakes':
        return const Color(0xFF6D4C41);
      case 'butter-milk':
        return AppTheme.mint;
      case 'milk-shakes':
        return const Color(0xFF8D6E63);
      case 'soda':
        return const Color(0xFF26A69A);
      case 'lassi':
        return const Color(0xFFFFB300);
      case 'mocktails':
        return const Color(0xFFE91E63);
      default:
        return AppTheme.cocoa;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppTheme.milk,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All"
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategory == 'all';
            return ChoiceChip(
              avatar: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/ds_logo_icon.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                ),
              ),
              label: const Text('All Items'),
              selected: isSelected,
              selectedColor: AppTheme.cocoa,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.milk : AppTheme.cocoa,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.cocoa : AppTheme.border,
              ),
              onSelected: (_) => onSelectCategory('all'),
            );
          }

          final cat = categories[index - 1];
          final isSelected = selectedCategory == cat.name;
          final accentColor = _getCategoryColor(cat.slug);

          return ChoiceChip(
            avatar: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ds_logo_icon.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: Text(cat.name),
            selected: isSelected,
            selectedColor: AppTheme.cream,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: AppTheme.cocoa,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected ? AppTheme.saffron : AppTheme.border,
              width: isSelected ? 1.5 : 1.0,
            ),
            onSelected: (_) => onSelectCategory(cat.name),
          );
        },
      ),
    );
  }
}