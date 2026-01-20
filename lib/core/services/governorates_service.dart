import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khodargy/core/constants/api_constants.dart';

/// Governorate Model
/// موديل المحافظة
class Governorate {
  final int id;
  final String nameAr;
  final String nameEn;
  final double deliveryFee;
  final bool isActive;

  Governorate({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.deliveryFee = 0.0,
    this.isActive = true,
  });

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      id: json['id'] ?? 0,
      nameAr: json['name_ar'] ?? json['name'] ?? '',
      nameEn: json['name_en'] ?? json['name'] ?? '',
      deliveryFee: (json['delivery_fee'] ?? json['fee'] ?? 0).toDouble(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}

/// Governorates Service
/// خدمة المحافظات
class GovernoratesService {
  /// Get active governorates
  /// جلب المحافظات النشطة
  static Future<List<Governorate>> getGovernorates() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.governorates}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List governoratesJson = data['data'] ?? data;
        return governoratesJson
            .map((json) => Governorate.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error fetching governorates: $e');
    }
    return [];
  }
}
