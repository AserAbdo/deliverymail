class ApiConfig {
  // API Base URL Configuration
  //
  // CHOOSE THE RIGHT URL BASED ON WHERE YOU'RE RUNNING THE APP:
  //
  // 1. Android Emulator → use: 'http://10.0.2.2:8000/api'
  // 2. iOS Simulator → use: 'http://127.0.0.1:8000/api'
  // 3. Physical Device (same network) → use: 'http://YOUR_IP:8000/api'
  //    Example: 'http://192.168.1.100:8000/api'
  //    To find your IP: Run 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux)
  //
  // 4. Chrome/Web → use: 'http://127.0.0.1:8000/api'

  // ⚠️ CHANGE THIS LINE based on where you're running:
  static const String baseUrl = 'http://192.168.8.39:8000/api'; // Computer's IP

  // Uncomment the line you need:
  // static const String baseUrl = 'http://127.0.0.1:8000/api';  // iOS Simulator or Chrome
  // static const String baseUrl = 'http://192.168.1.100:8000/api';  // Physical Device (replace with your IP)

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
