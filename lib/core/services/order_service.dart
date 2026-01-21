import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khodargy/core/constants/api_constants.dart';
import 'package:khodargy/core/services/cart_service.dart';

/// Order Item Model
class OrderItem {
  final int productId;
  final int quantity;

  OrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };
}

/// Create Order Request
class CreateOrderRequest {
  final String customerName;
  final String customerPhone;
  final int governorateId;
  final String address;
  final String? couponCode;
  final String? notes;
  final List<OrderItem> items;

  CreateOrderRequest({
    required this.customerName,
    required this.customerPhone,
    required this.governorateId,
    required this.address,
    this.couponCode,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'governorate_id': governorateId,
    'address': address,
    if (couponCode != null && couponCode!.isNotEmpty) 'coupon_code': couponCode,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'items': items.map((item) => item.toJson()).toList(),
  };
}

/// Order Response Model
class OrderResponse {
  final bool success;
  final String? orderId;
  final String message;

  OrderResponse({required this.success, this.orderId, required this.message});
}

/// Order Service
/// خدمة الطلبات
class OrderService {
  /// Create a new order
  /// إنشاء طلب جديد
  static Future<OrderResponse> createOrder(CreateOrderRequest request) async {
    try {
      print('Sending order: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Order response status: ${response.statusCode}');
      print('Order response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderResponse(
          success: data['success'] ?? true,
          orderId:
              data['data']?['id']?.toString() ?? data['order_id']?.toString(),
          message: data['message'] ?? 'تم تقديم الطلب بنجاح',
        );
      } else {
        return OrderResponse(
          success: false,
          message: data['message'] ?? 'حدث خطأ في تقديم الطلب',
        );
      }
    } catch (e) {
      print('Error creating order: $e');
      return OrderResponse(
        success: false,
        message: 'حدث خطأ في الاتصال بالخادم',
      );
    }
  }

  /// Create order from cart
  /// إنشاء طلب من السلة
  static Future<OrderResponse> createOrderFromCart({
    required String customerName,
    required String customerPhone,
    required int governorateId,
    required String address,
    String? couponCode,
    String? notes,
  }) async {
    final cartService = CartService();

    // Convert cart items to order items
    final items = cartService.items
        .map(
          (cartItem) => OrderItem(
            productId: int.tryParse(cartItem.product.id) ?? 0,
            quantity: cartItem.quantity,
          ),
        )
        .toList();

    final request = CreateOrderRequest(
      customerName: customerName,
      customerPhone: customerPhone,
      governorateId: governorateId,
      address: address,
      couponCode: couponCode,
      notes: notes,
      items: items,
    );

    return createOrder(request);
  }
}
