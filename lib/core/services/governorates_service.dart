import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khodargy/core/constants/api_constants.dart';

/// Governorate Model
/// موديل المحافظة
class Governorate {
  final int id;
  final String name;
  final double deliveryFee;
  final int order;

  Governorate({
    required this.id,
    required this.name,
    this.deliveryFee = 0.0,
    this.order = 0,
  });

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'delivery_fee': deliveryFee,
    'order': order,
  };
}

/// Governorates Service
/// خدمة المحافظات
class GovernoratesService {
  static const String _selectedGovernorateKey = 'selected_governorate';

  /// Get active governorates
  /// جلب المحافظات النشطة
  static Future<List<Governorate>> getGovernorates() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.governorates}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
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

  /// Save selected governorate to SharedPreferences
  /// حفظ المحافظة المختارة
  static Future<void> saveSelectedGovernorate(Governorate governorate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _selectedGovernorateKey,
      jsonEncode(governorate.toJson()),
    );
  }

  /// Load selected governorate from SharedPreferences
  /// تحميل المحافظة المختارة
  static Future<Governorate?> getSelectedGovernorate() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_selectedGovernorateKey);
    if (jsonStr != null) {
      try {
        return Governorate.fromJson(jsonDecode(jsonStr));
      } catch (e) {
        print('Error loading governorate: $e');
      }
    }
    return null;
  }

  /// Clear selected governorate
  /// مسح المحافظة المختارة
  static Future<void> clearSelectedGovernorate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedGovernorateKey);
  }
}
