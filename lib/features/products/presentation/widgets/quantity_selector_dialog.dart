import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/cart_service.dart';
import '../../domain/entities/product.dart';

/// Quantity Selector Dialog
/// نافذة اختيار الكمية - موحدة للاستخدام في جميع الشاشات
class QuantitySelectorDialog {
  /// Show quantity selector dialog
  static Future<void> show({
    required BuildContext context,
    required Product product,
    CartService? cartService,
  }) {
    final cart = cartService ?? CartService();
    int quantity = 1;

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final double totalPrice = product.price * quantity;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close, color: Colors.grey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      'تحديد الكمية',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      'اختر كمية ${product.nameAr} بالكيلوغرام',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Plus button
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              quantity++;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 24,
                              color: Color(0xFF457C3B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Quantity display
                        Column(
                          children: [
                            Text(
                              '$quantity',
                              style: GoogleFonts.cairo(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF457C3B),
                              ),
                            ),
                            Text(
                              'كيلوغرام',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                        // Minus button
                        InkWell(
                          onTap: quantity > 1
                              ? () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              : null,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 24,
                              color: quantity > 1
                                  ? const Color(0xFF457C3B)
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Total price section
                    Column(
                      children: [
                        Text(
                          'المجموع',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalPrice.toStringAsFixed(0)} ل.س',
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF457C3B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          cart.addToCart(product, quantity: quantity);
                          Navigator.pop(dialogContext);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'تمت الإضافة إلى السلة: $quantity كغ من ${product.nameAr}',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF457C3B),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(12),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF457C3B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'أضف للسلة',
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
