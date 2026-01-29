import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Get Products Use Case
/// حالة استخدام: جلب المنتجات
class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<Either<Failure, List<Product>>> call({
    int? categoryId,
    int? governorateId,
    String? search,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 15,
  }) async {
    return await repository.getProducts(
      categoryId: categoryId,
      governorateId: governorateId,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      perPage: perPage,
    );
  }
}
