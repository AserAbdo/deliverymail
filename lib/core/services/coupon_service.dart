import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khodargy/core/constants/api_constants.dart';

/// Coupon Model
class Coupon {
  final String code;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final double discountAmount;
  final double minPurchaseAmount;
  final double maxDiscountAmount;

  Coupon({
    required this.code,
    required this.type,
    required this.value,
    required this.discountAmount,
    this.minPurchaseAmount = 0,
    this.maxDiscountAmount = 0,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      code: json['code'] ?? '',
      type: json['type'] ?? 'percentage',
      value: (json['value'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      minPurchaseAmount: (json['min_purchase_amount'] ?? 0).toDouble(),
      maxDiscountAmount: (json['max_discount_amount'] ?? 0).toDouble(),
    );
  }
}

/// Coupon Validation Result
class CouponValidationResult {
  final bool success;
  final String message;
  final Coupon? coupon;

  CouponValidationResult({
    required this.success,
    required this.message,
    this.coupon,
  });
}

/// Coupon Service
/// خدمة الكوبونات
class CouponService {
  /// Validate coupon code
  /// التحقق من صحة كود الكوبون
  static Future<CouponValidationResult> validateCoupon({
    required String code,
    required double subtotal,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/coupons/validate'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'code': code, 'subtotal': subtotal}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return CouponValidationResult(
          success: true,
          message: data['message'] ?? 'الكوبون صالح',
          coupon: Coupon.fromJson(data['data']),
        );
      } else {
        return CouponValidationResult(
          success: false,
          message: data['message'] ?? 'الكوبون غير صالح',
        );
      }
    } catch (e) {
      print('Error validating coupon: $e');
      return CouponValidationResult(
        success: false,
        message: 'حدث خطأ في التحقق من الكوبون',
      );
    }
  }
}
