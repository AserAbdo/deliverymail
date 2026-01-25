import 'package:shared_preferences/shared_preferences.dart';

/// Checkout Data Service
/// خدمة بيانات إتمام الطلب
class CheckoutDataService {
  static const String _nameKey = 'checkout_name';
  static const String _phoneKey = 'checkout_phone';
  static const String _emailKey = 'checkout_email';
  static const String _addressKey = 'checkout_address';
  static const String _governorateKey = 'checkout_governorate';
  static const String _governorateIdKey = 'checkout_governorate_id';

  /// Save name
  static Future<bool> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_nameKey, name);
  }

  /// Get name
  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  /// Save phone
  static Future<bool> savePhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_phoneKey, phone);
  }

  /// Get phone
  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Save email
  static Future<bool> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_emailKey, email);
  }

  /// Get email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Save address
  static Future<bool> saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_addressKey, address);
  }

  /// Get address
  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressKey);
  }

  /// Save governorate
  static Future<bool> saveGovernorate(String name, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_governorateKey, name);
    return await prefs.setString(_governorateIdKey, id);
  }

  /// Get governorate name
  static Future<String?> getGovernorate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_governorateKey);
  }

  /// Get governorate ID
  static Future<String?> getGovernorateId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_governorateIdKey);
  }

  /// Clear all checkout data
  static Future<bool> clearCheckoutData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_governorateKey);
    await prefs.remove(_governorateIdKey);
    return true;
  }

  /// Get all checkout data
  static Future<Map<String, String?>> getAllCheckoutData() async {
    return {
      'name': await getName(),
      'phone': await getPhone(),
      'email': await getEmail(),
      'address': await getAddress(),
      'governorate': await getGovernorate(),
      'governorateId': await getGovernorateId(),
    };
  }

  /// Load all data to controllers
  static Future<void> loadAllData({
    required Function(String?) onNameLoaded,
    required Function(String?) onPhoneLoaded,
    required Function(String?) onEmailLoaded,
    required Function(String?) onAddressLoaded,
    required Function(String?) onGovernorateLoaded,
    required Function(String?) onGovernorateIdLoaded,
  }) async {
    onNameLoaded(await getName());
    onPhoneLoaded(await getPhone());
    onEmailLoaded(await getEmail());
    onAddressLoaded(await getAddress());
    onGovernorateLoaded(await getGovernorate());
    onGovernorateIdLoaded(await getGovernorateId());
  }
}
