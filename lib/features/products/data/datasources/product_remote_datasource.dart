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
      // Build query parameters - use dynamic to match ApiClient signature
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (categoryId != null)
        queryParams['category_id'] = categoryId.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      print(
        '🔍 Fetching products with URL: ${ApiConfig.baseUrl}${ApiConfig.productsEndpoint}',
      );
      print('🔍 Query params: $queryParams');

      // Call API with endpoint and query parameters
      final response = await apiClient.get(
        ApiConfig.productsEndpoint,
        queryParameters: queryParams,
      );

      print('✅ API Response received');
      print('📦 Response type: ${response.runtimeType}');
      print('📦 Response keys: ${response.keys}');

      // Check if response has data
      if (response['data'] != null) {
        final List<dynamic> productsJson = response['data'] as List<dynamic>;
        print('✅ Found ${productsJson.length} products in response["data"]');
        return productsJson
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // If response structure is different (direct array)
      if (response is List) {
        print('✅ Response is direct array with ${response.length} items');
        return (response as List<dynamic>)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      print('❌ Invalid response format. Response: $response');
      throw ServerException('Invalid response format from server');
    } on ServerException {
      rethrow;
    } catch (e) {
      print('Error fetching products: $e');
      throw ServerException('Failed to fetch products: ${e.toString()}');
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
