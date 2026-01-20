import '../entities/product.dart';
import '../repositories/products_repository.dart';

/// Get Products Use Case
/// حالة استخدام: جلب المنتجات
class GetProducts {
  final ProductsRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call({
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 15,
  }) async {
    return await repository.getProducts(
      categoryId: categoryId,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      perPage: perPage,
    );
  }
}
