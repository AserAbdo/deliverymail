import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

/// Authentication Service
/// خدمة المصادقة
class AuthService {
  static final ApiClient _apiClient = ApiClient();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Register new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      if (response['success'] == true) {
        final token = response['data']['token'];
        final user = response['data']['user'];

        await _saveToken(token);
        await _saveUser(user);

        return {
          'success': true,
          'message': 'تم إنشاء الحساب بنجاح',
          'data': response['data'],
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'فشل إنشاء الحساب',
      };
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {'email': email, 'password': password},
      );

      if (response['success'] == true) {
        final token = response['data']['token'];
        final user = response['data']['user'];

        await _saveToken(token);
        await _saveUser(user);

        return {
          'success': true,
          'message': 'تم تسجيل الدخول بنجاح',
          'data': response['data'],
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'فشل تسجيل الدخول',
      };
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _apiClient.post(ApiConstants.logout, token: token);
      }
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _clearAuthData();
    }
  }

  /// Get current user from API
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _apiClient.get(ApiConstants.user, token: token);

      if (response['success'] == true) {
        final user = response['data'];
        await _saveUser(user);
        return user;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get saved user data
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      return Map<String, dynamic>.from(
        // Simple parsing without jsonDecode
        _parseUserData(userJson),
      );
    } catch (e) {
      return null;
    }
  }

  /// Save token to local storage
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Save user data to local storage
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toString());
  }

  /// Clear all auth data
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Parse user data from string
  static Map<String, dynamic> _parseUserData(String data) {
    // Simple parsing for demo - in production use proper JSON
    final map = <String, dynamic>{};
    final cleaned = data.replaceAll('{', '').replaceAll('}', '');
    final pairs = cleaned.split(', ');

    for (final pair in pairs) {
      final parts = pair.split(': ');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }

    return map;
  }

  /// Get user-friendly error message
  static String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('Network error')) {
      return 'خطأ في الاتصال بالإنترنت';
    } else if (errorStr.contains('Unauthorized')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (errorStr.contains('already been taken')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    } else if (errorStr.contains('Exception:')) {
      return errorStr.replaceAll('Exception:', '').trim();
    }

    return 'حدث خطأ غير متوقع';
  }
}
