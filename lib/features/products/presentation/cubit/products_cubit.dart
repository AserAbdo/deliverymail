import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import 'products_state.dart';

/// Products Cubit - Presentation Layer
/// Cubit المنتجات (طبقة العرض) - إدارة الحالة
class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts;

  ProductsCubit({required this.getProducts}) : super(ProductsInitial());

  /// Load all products
  /// تحميل جميع المنتجات
  Future<void> loadProducts({int page = 1, int perPage = 100}) async {
    emit(ProductsLoading());

    final result = await getProducts(
      GetProductsParams(page: page, perPage: perPage),
    );

    result.fold((failure) => emit(ProductsError(failure.message)), (products) {
      if (products.isEmpty) {
        emit(const ProductsEmpty());
      } else {
        emit(ProductsLoaded(products: products));
      }
    });
  }

  /// Filter products by category
  /// تصفية المنتجات حسب الفئة
  Future<void> filterByCategory(int? categoryId) async {
    emit(ProductsLoading());

    final result = await getProducts(
      GetProductsParams(categoryId: categoryId, perPage: 100),
    );

    result.fold((failure) => emit(ProductsError(failure.message)), (products) {
      if (products.isEmpty) {
        emit(const ProductsEmpty('لا توجد منتجات في هذه الفئة'));
      } else {
        emit(
          ProductsLoaded(products: products, selectedCategoryId: categoryId),
        );
      }
    });
  }

  /// Search products
  /// البحث عن المنتجات
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      loadProducts();
      return;
    }

    emit(ProductsLoading());

    final result = await getProducts(
      GetProductsParams(search: query, perPage: 100),
    );

    result.fold((failure) => emit(ProductsError(failure.message)), (products) {
      if (products.isEmpty) {
        emit(const ProductsEmpty('لا توجد نتائج للبحث'));
      } else {
        emit(ProductsLoaded(products: products, searchQuery: query));
      }
    });
  }

  /// Refresh products
  /// تحديث المنتجات
  Future<void> refreshProducts() async {
    final currentState = state;

    if (currentState is ProductsLoaded) {
      // Keep current filters
      if (currentState.selectedCategoryId != null) {
        await filterByCategory(currentState.selectedCategoryId);
      } else if (currentState.searchQuery != null) {
        await searchProducts(currentState.searchQuery!);
      } else {
        await loadProducts();
      }
    } else {
      await loadProducts();
    }
  }

  /// Clear filters
  /// مسح التصفية
  Future<void> clearFilters() async {
    await loadProducts();
  }
}
