import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khodargy/core/constants/api_constants.dart';

/// Category Model
/// موديل الفئة
class Category {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? image;
  final String? description;
  final bool isActive;
  final int productsCount;
  final List<Category>? children;

  Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.image,
    this.description,
    this.isActive = true,
    this.productsCount = 0,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    String? imageUrl = json['image'] ?? json['image_url'];
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
    }

    // Parse subcategories if they exist
    List<Category>? subcategories;
    if (json['children'] != null && json['children'] is List) {
      subcategories = (json['children'] as List)
          .map((child) => Category.fromJson(child))
          .toList();
    }

    return Category(
      id: json['id'] ?? 0,
      nameAr: json['name_ar'] ?? json['name'] ?? '',
      nameEn: json['name_en'] ?? json['name'] ?? '',
      image: imageUrl,
      description: json['description'] ?? json['description_ar'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      productsCount: json['products_count'] ?? 0,
      children: subcategories,
    );
  }
}

/// Categories Service
/// خدمة الفئات
class CategoriesService {
  /// Get all categories
  /// جلب جميع الفئات
  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List categoriesJson = data['data'] ?? data;
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
    return [];
  }

  /// Get category with its products
  /// جلب فئة مع منتجاتها
  static Future<Map<String, dynamic>?> getCategoryWithProducts(
    int categoryId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.categories}/$categoryId',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
    } catch (e) {
      print('Error fetching category: $e');
    }
    return null;
  }
}
