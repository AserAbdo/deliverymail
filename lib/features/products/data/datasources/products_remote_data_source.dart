import '../../domain/entities/product.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';

/// Products Remote Data Source
/// مصدر البيانات البعيد للمنتجات
abstract class ProductsRemoteDataSource {
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

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient apiClient;

  ProductsRemoteDataSourceImpl({required this.apiClient});

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
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (categoryId != null) 'category_id': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
      };

      final response = await apiClient.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );

      // Handle both response formats:
      // 1. Laravel paginated: {data: [...], links: {...}, meta: {...}}
      // 2. Success wrapper: {success: true, data: {...}}
      List<dynamic> productsJson;

      if (response.containsKey('data')) {
        final data = response['data'];
        // If data is a list, use it directly (paginated response)
        if (data is List) {
          productsJson = data;
        } else if (data is Map && data.containsKey('data')) {
          // Nested data structure
          productsJson = data['data'] as List? ?? [];
        } else {
          productsJson = [];
        }
      } else {
        productsJson = [];
      }

      return productsJson.map((json) => _productFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Future<Product> getProductDetails(int id) async {
    try {
      final response = await apiClient.get(ApiConstants.productDetails(id));

      // Handle both formats:
      // 1. Direct data: {data: {...}}
      // 2. Success wrapper: {success: true, data: {...}}
      if (response.containsKey('data')) {
        return _productFromJson(response['data']);
      }

      throw Exception('Product not found');
    } catch (e) {
      throw Exception('Failed to load product details: $e');
    }
  }

  /// Convert JSON to Product entity
  Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? 0).toString(),
      nameAr: json['name_ar'] ?? json['name'] ?? '',
      descriptionAr: json['description_ar'] ?? json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? json['image'] ?? '',
      category: json['category'] is Map
          ? (json['category']?['name_ar'] ?? json['category']?['name'] ?? '')
          : (json['category']?.toString() ?? ''),
      unit: json['unit'] ?? 'كجم',
      isOrganic: json['is_organic'] == 1 || json['is_organic'] == true,
      rating: (json['rating'] ?? 4.0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviews_count'] ?? 0,
    );
  }
}
