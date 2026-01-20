import '../entities/product.dart';

/// Products Repository Interface
/// واجهة مستودع المنتجات
abstract class ProductsRepository {
  Future<List<Product>> getProducts({
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 15,
  });

  Future<Product> getProductDetails(int id);
}
