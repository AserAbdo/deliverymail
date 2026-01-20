import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';

/// Auth Service - Handles authentication with the API
/// خدمة المصادقة - التعامل مع الـ API للتسجيل وتسجيل الدخول
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Login with email and password
  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token - API returns data.token
        final token =
            data['data']?['token'] ?? data['token'] ?? data['access_token'];
        if (token != null) {
          await _saveToken(token);
          ApiConfig.setToken(token);
        }

        // Save user data
        final user = data['data']?['user'] ?? data['user'];
        if (user != null) {
          await _saveUser(user);
        }

        return {
          'success': true,
          'user': user,
          'message': data['message'] ?? 'تم تسجيل الدخول بنجاح',
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في الاتصال: $e'};
    }
  }

  /// Register new user
  /// تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        // Save token - API returns data.token
        final token =
            data['data']?['token'] ?? data['token'] ?? data['access_token'];
        if (token != null) {
          await _saveToken(token);
          ApiConfig.setToken(token);
        }

        // Save user data
        final user = data['data']?['user'] ?? data['user'];
        if (user != null) {
          await _saveUser(user);
        }

        return {
          'success': true,
          'user': user,
          'message': data['message'] ?? 'تم إنشاء الحساب بنجاح',
        };
      } else {
        String errorMessage = 'حدث خطأ أثناء التسجيل';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first is List
              ? errors.values.first[0]
              : errors.values.first.toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في الاتصال: $e'};
    }
  }

  /// Logout
  /// تسجيل الخروج
  static Future<void> logout() async {
    try {
      if (ApiConfig.isAuthenticated) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}'),
          headers: ApiConfig.headers,
        );
      }
    } catch (_) {}

    ApiConfig.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Get current user from API
  /// جلب بيانات المستخدم الحالي
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      if (!ApiConfig.isAuthenticated) return null;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userEndpoint}'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['data'] ?? data['user'] ?? data;
        await _saveUser(user);
        return user;
      }
    } catch (_) {}
    return null;
  }

  /// Check if user is logged in
  /// التحقق إذا المستخدم مسجل دخول
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      ApiConfig.setToken(token);
      return true;
    }
    return false;
  }

  /// Get saved user data
  /// جلب بيانات المستخدم المحفوظة
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  /// Save token locally
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Save user data locally
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }
}
