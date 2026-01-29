import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/categories_service.dart';
import '../../../../core/services/governorates_service.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_card.dart';
import '../widgets/quantity_selector_dialog.dart';
import 'product_details_screen.dart';

/// Category Products Screen - شاشة منتجات القسم
class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final List<Category>? subcategories;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.subcategories,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final CartService _cartService = CartService();
  int? _selectedSubcategoryId;
  Governorate? _selectedGovernorate;
  bool _isLoadingGovernorate = true;

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
    _loadSelectedGovernorate();
  }

  Future<void> _loadSelectedGovernorate() async {
    final governorate = await GovernoratesService.getSelectedGovernorate();
    if (mounted) {
      setState(() {
        _selectedGovernorate = governorate;
        _isLoadingGovernorate = false;
      });
    }
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Wait for governorate to load
    if (_isLoadingGovernorate) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (_) => di.sl<ProductsCubit>()
        ..loadProducts(
          categoryId: _selectedSubcategoryId ?? widget.categoryId,
          governorateId: _selectedGovernorate?.id,
        ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App Bar
              _buildSliverAppBar(context),
              // Subcategories chips (if available)
              if (widget.subcategories != null &&
                  widget.subcategories!.isNotEmpty)
                _buildSubcategoriesChips(),
              // Products Grid
              _buildProductsGrid(),
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryGreenLight, AppColors.primaryGreenDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 20,
                left: 60,
                top: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.categoryName,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildSubcategoriesChips() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Builder(
            builder: (context) {
              final productsCubit = context.read<ProductsCubit>();
              return Row(
                children: [
                  // "All" chip
                  _buildSubcategoryChip(
                    label: 'الكل',
                    isSelected: _selectedSubcategoryId == null,
                    onTap: () {
                      setState(() {
                        _selectedSubcategoryId = null;
                      });
                      productsCubit.loadProducts(
                        categoryId: widget.categoryId,
                        governorateId: _selectedGovernorate?.id,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Subcategory chips
                  ...widget.subcategories!.map((subcat) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildSubcategoryChip(
                        label: subcat.nameAr,
                        isSelected: _selectedSubcategoryId == subcat.id,
                        onTap: () {
                          setState(() {
                            _selectedSubcategoryId = subcat.id;
                          });
                          productsCubit.loadProducts(
                            categoryId: subcat.id,
                            governorateId: _selectedGovernorate?.id,
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.cairo()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProductsLoading) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحميل المنتجات...',
                    style: GoogleFonts.cairo(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ProductsEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(context, state.message),
          );
        }

        if (state is ProductsLoaded) {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildProductCard(context, state.products[index], index),
                childCount: state.products.length,
              ),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, int index) {
    final cartService = CartService();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: ProductCard(
        product: product,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        onAddToCart: () {
          QuantitySelectorDialog.show(
            context: context,
            product: product,
            cartService: cartService,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProductsCubit>().loadProducts(
                categoryId: widget.categoryId,
                governorateId: _selectedGovernorate?.id,
              );
            },
            icon: const Icon(Icons.refresh),
            label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
