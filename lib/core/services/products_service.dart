import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khodargy/core/constants/api_constants.dart';
import '../../features/products/data/models/product_model.dart';
import '../../features/products/domain/entities/product.dart';

/// Products Service
/// خدمة المنتجات
class ProductsService {
  /// Get all products with optional filters
  /// جلب جميع المنتجات مع فلاتر اختيارية
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 15,
    int? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.products}',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List productsJson = data['data'] ?? data;
        final products = productsJson
            .map((json) => ProductModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'products': products,
          'meta': data['meta'],
          'links': data['links'],
        };
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    return {'success': false, 'products': <Product>[]};
  }

  /// Get product details
  /// جلب تفاصيل المنتج
  static Future<Product?> getProductDetails(int productId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.products}/$productId',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ProductModel.fromJson(data['data'] ?? data);
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
    return null;
  }

  /// Search products
  /// البحث عن منتجات
  static Future<List<Product>> searchProducts(String query) async {
    final result = await getProducts(search: query, perPage: 50);
    return result['products'] ?? [];
  }

  /// Get products by category
  /// جلب منتجات حسب الفئة
  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    final result = await getProducts(categoryId: categoryId, perPage: 50);
    return result['products'] ?? [];
  }
}
