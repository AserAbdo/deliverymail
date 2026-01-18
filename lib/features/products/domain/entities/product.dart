import 'package:equatable/equatable.dart';

/// Product Entity - Domain Layer
/// الكيان الأساسي للمنتج (طبقة المنطق)
class Product extends Equatable {
  final String id;
  final String nameAr;
  final String descriptionAr;
  final double price;
  final String unit;
  final String imageUrl;
  final String category;
  final bool isOrganic;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.nameAr,
    required this.descriptionAr,
    required this.price,
    required this.unit,
    required this.imageUrl,
    required this.category,
    this.isOrganic = false,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    nameAr,
    descriptionAr,
    price,
    unit,
    imageUrl,
    category,
    isOrganic,
    rating,
    reviewCount,
  ];
}
