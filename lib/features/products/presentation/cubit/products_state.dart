import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

/// Products State - Presentation Layer
/// حالات المنتجات (طبقة العرض)
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

/// Initial State - الحالة الأولية
class ProductsInitial extends ProductsState {}

/// Loading State - حالة التحميل
class ProductsLoading extends ProductsState {}

/// Loaded State - حالة التحميل الناجح
class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final int? selectedCategoryId;
  final String? searchQuery;

  const ProductsLoaded({
    required this.products,
    this.selectedCategoryId,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [products, selectedCategoryId, searchQuery];

  /// Copy with method for updating state
  ProductsLoaded copyWith({
    List<Product>? products,
    int? selectedCategoryId,
    String? searchQuery,
    bool clearCategory = false,
    bool clearSearch = false,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

/// Error State - حالة الخطأ
class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty State - حالة فارغة (لا توجد منتجات)
class ProductsEmpty extends ProductsState {
  final String message;

  const ProductsEmpty([this.message = 'لا توجد منتجات']);

  @override
  List<Object?> get props => [message];
}
