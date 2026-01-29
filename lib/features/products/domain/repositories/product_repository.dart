import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

/// Product Repository Interface - Domain Layer
/// واجهة مستودع المنتجات (طبقة المنطق)
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int perPage = 15,
    int? categoryId,
    int? governorateId,
    String? search,
    double? minPrice,
    double? maxPrice,
  });

  Future<Either<Failure, Product>> getProductDetails(String productId);

  Future<Either<Failure, List<Product>>> searchProducts(
    String query, {
    int? governorateId,
  });

  Future<Either<Failure, List<Product>>> getProductsByCategory(
    int categoryId, {
    int? governorateId,
  });
}
