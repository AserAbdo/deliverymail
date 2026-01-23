import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/categories_service.dart';
import '../cubit/products_cubit.dart';

/// Categories Filter Widget
/// ويدجت فلتر الفئات
class CategoriesFilter extends StatelessWidget {
  final List<Category> categories;
  final int selectedIndex;
  final bool isLoading;
  final ValueChanged<int> onCategorySelected;

  const CategoriesFilter({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.isLoading,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        reverse: false,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              onCategorySelected(index);
              // Filter products by category
              if (index == 0) {
                context.read<ProductsCubit>().loadProducts();
              } else {
                context.read<ProductsCubit>().loadProducts(
                  categoryId: category.id,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular icon container with leaf design
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primaryGreen
                          : const Color(0xFFE8F5E9), // Light green background
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(category),
                        color: isSelected
                            ? Colors.white
                            : AppColors.primaryGreen,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.nameAr,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(Category category) {
    final name = category.nameAr.toLowerCase();
    if (category.id == 0) return Icons.grid_view_rounded;
    if (name.contains('خضر')) return Icons.eco;
    if (name.contains('فاكه') || name.contains('فواكه')) return Icons.apple;
    if (name.contains('عضوي')) return Icons.grass;
    if (name.contains('عرض') || name.contains('عروض')) return Icons.local_offer;
    if (name.contains('لحوم') || name.contains('لحم')) return Icons.set_meal;
    if (name.contains('ألبان') || name.contains('حليب')) return Icons.egg;
    return Icons.category;
  }
}
