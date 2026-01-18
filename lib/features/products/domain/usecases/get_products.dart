import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Get Products Use Case - Domain Layer
/// حالة استخدام: جلب المنتجات (طبقة المنطق)
class GetProducts implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) async {
    return await repository.getProducts(
      page: params.page,
      perPage: params.perPage,
      categoryId: params.categoryId,
      search: params.search,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
    );
  }
}

/// Parameters for GetProducts Use Case
class GetProductsParams {
  final int page;
  final int perPage;
  final int? categoryId;
  final String? search;
  final double? minPrice;
  final double? maxPrice;

  const GetProductsParams({
    this.page = 1,
    this.perPage = 100,
    this.categoryId,
    this.search,
    this.minPrice,
    this.maxPrice,
  });
}
