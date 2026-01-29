import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import 'products_state.dart';

/// Products Cubit - Presentation Layer
/// Cubit المنتجات (طبقة العرض) - إدارة الحالة
class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts;

  ProductsCubit({required this.getProducts}) : super(ProductsInitial());

  /// Load all products (optionally filtered by category and governorate)
  /// تحميل جميع المنتجات (اختياريًا حسب الفئة والمحافظة)
  Future<void> loadProducts({
    int? categoryId,
    int? governorateId,
    int page = 1,
    int perPage = 100,
  }) async {
    emit(ProductsLoading());

    try {
      final result = await getProducts(
        categoryId: categoryId,
        governorateId: governorateId,
        page: page,
        perPage: perPage,
      );

      result.fold((failure) => emit(ProductsError(failure.message)), (
        products,
      ) {
        if (products.isEmpty) {
          emit(
            ProductsEmpty(
              categoryId != null
                  ? 'لا توجد منتجات في هذه الفئة'
                  : 'لا توجد منتجات متاحة',
            ),
          );
        } else {
          emit(
            ProductsLoaded(products: products, selectedCategoryId: categoryId),
          );
        }
      });
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  /// Filter products by category
  /// تصفية المنتجات حسب الفئة
  Future<void> filterByCategory(int? categoryId, {int? governorateId}) async {
    emit(ProductsLoading());

    try {
      final result = await getProducts(
        categoryId: categoryId,
        governorateId: governorateId,
        perPage: 100,
      );

      result.fold((failure) => emit(ProductsError(failure.message)), (
        products,
      ) {
        if (products.isEmpty) {
          emit(const ProductsEmpty('لا توجد منتجات في هذه الفئة'));
        } else {
          emit(
            ProductsLoaded(products: products, selectedCategoryId: categoryId),
          );
        }
      });
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  /// Search products
  /// البحث عن المنتجات
  Future<void> searchProducts(String query, {int? governorateId}) async {
    if (query.isEmpty) {
      loadProducts(governorateId: governorateId);
      return;
    }

    emit(ProductsLoading());

    try {
      final result = await getProducts(
        search: query,
        governorateId: governorateId,
        perPage: 100,
      );

      result.fold((failure) => emit(ProductsError(failure.message)), (
        products,
      ) {
        if (products.isEmpty) {
          emit(const ProductsEmpty('لا توجد نتائج للبحث'));
        } else {
          emit(ProductsLoaded(products: products, searchQuery: query));
        }
      });
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
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
