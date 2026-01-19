import '../../domain/entities/product.dart';

/// Product Model - Data Layer
/// نموذج المنتج (طبقة البيانات) - يحتوي على fromJson/toJson
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.nameAr,
    required super.descriptionAr,
    required super.price,
    required super.unit,
    required super.imageUrl,
    required super.category,
    super.isOrganic,
    super.rating,
    super.reviewCount,
  });

  /// Create ProductModel from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar'] ?? json['name'] ?? '',
      descriptionAr: json['description_ar'] ?? json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? json['unit_ar'] ?? 'كجم',
      imageUrl: _buildImageUrl(json['image_url'] ?? json['image'] ?? ''),
      category: json['category'] is Map
          ? (json['category']?['name_ar'] ?? json['category']?['name'] ?? '')
          : (json['category']?.toString() ?? ''),
      isOrganic: json['is_organic'] == 1 || json['is_organic'] == true,
      rating: (json['rating'] ?? 4.5).toDouble(),
      reviewCount: json['review_count'] ?? json['reviews_count'] ?? 0,
    );
  }

  /// Convert ProductModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'description_ar': descriptionAr,
      'price': price,
      'unit': unit,
      'image_url': imageUrl,
      'category': category,
      'is_organic': isOrganic,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  /// Convert Product Entity to ProductModel
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      nameAr: product.nameAr,
      descriptionAr: product.descriptionAr,
      price: product.price,
      unit: product.unit,
      imageUrl: product.imageUrl,
      category: product.category,
      isOrganic: product.isOrganic,
      rating: product.rating,
      reviewCount: product.reviewCount,
    );
  }
}
