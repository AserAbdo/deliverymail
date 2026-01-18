class ApiConfig {
  // Delivery Mall API Base URL
  // For Android Emulator: use 10.0.2.2 (emulator's special alias for host machine)
  // For iOS Simulator: use 127.0.0.1
  // For Physical Device: use your computer's IP address (e.g., 192.168.1.100)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Authentication token (will be set after login)
  static String? authToken;

  // Authentication Endpoints
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String userEndpoint = '/user';

  // Product & Category Endpoints
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String bannersEndpoint = '/banners';
  static const String governoratesEndpoint = '/governorates';

  // Order Endpoints
  static const String ordersEndpoint = '/orders';
  static const String trackOrderEndpoint = '/orders/track';

  // Headers
  static Map<String, String> get headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add Bearer token if available
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  // Set token after login/register
  static void setToken(String token) {
    authToken = token;
  }

  // Clear token on logout
  static void clearToken() {
    authToken = null;
  }

  // Check if user is authenticated
  static bool get isAuthenticated => authToken != null && authToken!.isNotEmpty;
}
