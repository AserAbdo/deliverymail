import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khodargy/core/constants/api_constants.dart';

/// Order Item Model
/// موديل عنصر الطلب
class OrderItem {
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    String? imageUrl = json['product']?['image'] ?? json['product_image'];
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl = '$baseUrl${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
    }

    return OrderItem(
      productId: json['product_id'] ?? json['product']?['id'] ?? 0,
      productName: json['product']?['name_ar'] ?? json['product_name'] ?? '',
      productImage: imageUrl,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? json['unit_price'] ?? 0).toDouble(),
      total: (json['total'] ?? json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
  };
}

/// Order Model
/// موديل الطلب
class Order {
  final int id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String address;
  final String? notes;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final List<OrderItem> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    this.notes,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = [];
    if (json['items'] != null) {
      orderItems = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? json['id'].toString(),
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      items: orderItems,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Get status in Arabic
  String get statusAr {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'processing':
        return 'قيد التجهيز';
      case 'shipped':
        return 'تم الشحن';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

/// Orders Service
/// خدمة الطلبات
class OrdersService {
  /// Get user's orders
  /// جلب طلبات المستخدم
  static Future<List<Order>> getMyOrders({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.orders}?page=$page&per_page=$perPage',
        ),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List ordersJson = data['data'] ?? data;
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
    return [];
  }

  /// Get order details
  /// جلب تفاصيل الطلب
  static Future<Order?> getOrderDetails(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}/$orderId'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data['data'] ?? data);
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
    return null;
  }

  /// Create new order
  /// إنشاء طلب جديد
  static Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String customerPhone,
    required String address,
    String? notes,
    required List<OrderItem> items,
  }) async {
    try {
      final body = {
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'address': address,
        'notes': notes,
        'items': items.map((item) => item.toJson()).toList(),
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}'),
        headers: ApiConstants.headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'order': Order.fromJson(data['data'] ?? data),
          'message': data['message'] ?? 'تم إنشاء الطلب بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'حدث خطأ أثناء إنشاء الطلب',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في الاتصال: $e'};
    }
  }

  /// Track order by phone (for guests)
  /// تتبع الطلب برقم الهاتف (للزوار)
  static Future<Map<String, dynamic>> trackOrder(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.trackOrder}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List ordersJson = data['data'] ?? data;
        final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
        return {
          'success': true,
          'orders': orders,
          'message': data['message'] ?? 'تم العثور على طلباتك',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'لم يتم العثور على طلبات',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ في الاتصال: $e'};
    }
  }
}
