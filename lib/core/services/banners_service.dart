import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api_config.dart';

/// Banner Model
/// موديل البانر
class Banner {
  final int id;
  final String title;
  final String? subtitle;
  final String image;
  final String? link;
  final bool isActive;
  final int sortOrder;

  Banner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.image,
    this.link,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    String imageUrl = json['image'] ?? json['image_url'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
    }

    return Banner(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['title_ar'] ?? '',
      subtitle: json['subtitle'] ?? json['description'],
      image: imageUrl,
      link: json['link'] ?? json['url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      sortOrder: json['sort_order'] ?? json['order'] ?? 0,
    );
  }
}

/// Banners Service
/// خدمة البانرات
class BannersService {
  /// Get active banners
  /// جلب البانرات النشطة
  static Future<List<Banner>> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bannersEndpoint}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List bannersJson = data['data'] ?? data;
        return bannersJson.map((json) => Banner.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching banners: $e');
    }
    return [];
  }
}
