/// API Constants
/// ثوابت الـ API
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://vella-niftier-gertrude.ngrok-free.dev/api';

  // Authentication Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';

  // Products Endpoints
  static const String products = '/products';
  static String productDetails(int id) => '/products/$id';

  // Categories Endpoints
  static const String categories = '/categories';
  static String categoryProducts(int id) => '/categories/$id';

  // Banners Endpoints
  static const String banners = '/banners';

  // Governorates Endpoints
  static const String governorates = '/governorates';

  // Orders Endpoints
  static const String orders = '/orders';
  static String orderDetails(int id) => '/orders/$id';
  static const String trackOrder = '/orders/track';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
