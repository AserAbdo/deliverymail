import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

/// Products Repository Implementation
/// تطبيق مستودع المنتجات
class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts({
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      return await remoteDataSource.getProducts(
        categoryId: categoryId,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<Product> getProductDetails(int id) async {
    try {
      return await remoteDataSource.getProductDetails(id);
    } catch (e) {
      throw Exception('Failed to get product details: $e');
    }
  }
}
