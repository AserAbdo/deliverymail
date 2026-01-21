import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khodargy/core/constants/api_constants.dart';

/// Currency Model
class Currency {
  final String code;
  final String symbol;

  Currency({required this.code, required this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] ?? 'EGP',
      symbol: json['symbol'] ?? 'ج.م',
    );
  }
}

/// App Settings Model
class AppSettings {
  final String companyName;
  final Currency currency;
  final String? phone;
  final String? whatsapp;
  final String? footerText;

  AppSettings({
    required this.companyName,
    required this.currency,
    this.phone,
    this.whatsapp,
    this.footerText,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      companyName: json['company_name'] ?? 'ديليفري مول',
      currency: json['currency'] != null
          ? Currency.fromJson(json['currency'])
          : Currency(code: 'EGP', symbol: 'ج.م'),
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      footerText: json['footer_text'],
    );
  }
}

/// Settings Service
/// خدمة الإعدادات
class SettingsService {
  static const String _settingsKey = 'app_settings';
  static AppSettings? _cachedSettings;

  /// Get app settings from API
  /// جلب إعدادات التطبيق
  static Future<AppSettings> getSettings() async {
    // Return cached if available
    if (_cachedSettings != null) return _cachedSettings!;

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/settings'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final settingsData = data['data'] ?? data;
        _cachedSettings = AppSettings.fromJson(settingsData);

        // Cache in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_settingsKey, jsonEncode(settingsData));

        return _cachedSettings!;
      }
    } catch (e) {
      print('Error fetching settings: $e');
    }

    // Try to load from cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_settingsKey);
      if (cached != null) {
        _cachedSettings = AppSettings.fromJson(jsonDecode(cached));
        return _cachedSettings!;
      }
    } catch (e) {
      print('Error loading cached settings: $e');
    }

    // Return default settings
    return AppSettings(
      companyName: 'ديليفري مول',
      currency: Currency(code: 'EGP', symbol: 'ج.م'),
    );
  }

  /// Get currency symbol
  /// جلب رمز العملة
  static Future<String> getCurrencySymbol() async {
    final settings = await getSettings();
    return settings.currency.symbol;
  }

  /// Clear cached settings
  static void clearCache() {
    _cachedSettings = null;
  }
}
