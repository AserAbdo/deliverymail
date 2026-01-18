import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

/// Product Remote Data Source - Data Layer
/// مصدر البيانات البعيد للمنتجات (طبقة البيانات)
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int perPage = 15,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
  });

  Future<ProductModel> getProductDetails(String productId);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getProductsByCategory(int categoryId);
}

/// Implementation of ProductRemoteDataSource
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int perPage = 15,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;

      // Build URL with query parameters
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}')
          .replace(
            queryParameters: queryParams.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          );

      final response = await apiClient.get(uri.toString());

      if (response['success'] == true) {
        final List<dynamic> productsJson = response['data'] ?? [];
        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }

      throw ServerException('Failed to load products');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProductModel> getProductDetails(String productId) async {
    try {
      final response = await apiClient.get(
        '${ApiConfig.productsEndpoint}/$productId',
      );

      if (response['success'] == true && response['data'] != null) {
        return ProductModel.fromJson(response['data']);
      }

      throw ServerException('Product not found');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    return getProducts(search: query);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    return getProducts(categoryId: categoryId);
  }
}
