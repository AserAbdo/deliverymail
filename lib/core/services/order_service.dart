import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khodargy/core/constants/api_constants.dart';
import 'package:khodargy/core/services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Order Item Model for creating orders
class OrderItem {
  final int productId;
  final int quantity;

  OrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };
}

/// Order Item Details (from API response)
class OrderItemDetails {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItemDetails({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemDetails.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};
    return OrderItemDetails(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: product['name'] ?? 'منتج',
      productImage: product['image'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}

/// Governorate Info
class OrderGovernorate {
  final int id;
  final String name;
  final double deliveryFee;

  OrderGovernorate({
    required this.id,
    required this.name,
    required this.deliveryFee,
  });

  factory OrderGovernorate.fromJson(Map<String, dynamic> json) {
    return OrderGovernorate(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
    );
  }
}

/// Full Order Model
class Order {
  final int id;
  final String status;
  final String statusLabel;
  final String statusColor;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double total;
  final String? couponCode;
  final String customerName;
  final String customerPhone;
  final String address;
  final String? notes;
  final OrderGovernorate? governorate;
  final List<OrderItemDetails> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.statusColor,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.total,
    this.couponCode,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    this.notes,
    this.governorate,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'] ?? 'قيد الانتظار',
      statusColor: json['status_color'] ?? 'yellow',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      couponCode: json['coupon_code'],
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'],
      governorate: json['governorate'] != null
          ? OrderGovernorate.fromJson(json['governorate'])
          : null,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemDetails.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
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
  static const String _phoneKey = 'last_order_phone';

  /// Save phone number for order tracking
  static Future<void> savePhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phone);
  }

  /// Get saved phone number
  static Future<String?> getSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Get orders by phone number
  /// الحصول على الطلبات برقم الهاتف
  static Future<List<Order>> getOrdersByPhone(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'phone': phone}),
      );

      print('Get orders response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> ordersJson = data['data'];
          return ordersJson.map((json) => Order.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

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
        // Save phone for order tracking
        await savePhoneNumber(request.customerPhone);

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
