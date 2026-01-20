import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// API Client for making HTTP requests
/// عميل الـ API لإجراء طلبات HTTP
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}$endpoint',
      ).replace(queryParameters: queryParameters);

      final headers = token != null
          ? ApiConstants.authHeaders(token)
          : ApiConstants.headers;

      final response = await _client.get(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST Request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final headers = token != null
          ? ApiConstants.authHeaders(token)
          : ApiConstants.headers;

      final response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final headers = token != null
          ? ApiConstants.authHeaders(token)
          : ApiConstants.headers;

      final response = await _client.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final headers = token != null
          ? ApiConstants.authHeaders(token)
          : ApiConstants.headers;

      final response = await _client.delete(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Handle API Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (body.isEmpty) {
      throw Exception('Empty response from server');
    }

    final Map<String, dynamic> data = jsonDecode(body);

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    } else if (statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    } else if (statusCode == 404) {
      throw Exception('Resource not found');
    } else if (statusCode == 422) {
      // Validation error
      final errors = data['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        final firstError = errors.values.first;
        final errorMessage = firstError is List ? firstError.first : firstError;
        throw Exception(errorMessage.toString());
      }
      throw Exception(data['message'] ?? 'Validation error');
    } else if (statusCode >= 500) {
      throw Exception('Server error - Please try again later');
    } else {
      throw Exception(data['message'] ?? 'Unknown error occurred');
    }
  }

  void dispose() {
    _client.close();
  }
}
