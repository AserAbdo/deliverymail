import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/utils/cache_manager.dart';
import '../../domain/entities/product.dart';

/// Minimalistic Product Card Widget
/// بطاقة منتج بسيطة
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  cacheManager: CustomCacheManager.instance,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[50],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[50],
                    child: Icon(Icons.image, color: Colors.grey[300]),
                  ),
                ),
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameAr,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price.toStringAsFixed(0)} ل.س',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF457C3B),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _handleAddToCart(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF457C3B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_shopping_cart,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'أضف للسلة',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart(BuildContext context) {
    if (onAddToCart != null) {
      onAddToCart!();
    } else {
      CartService().addToCart(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت الإضافة', style: GoogleFonts.cairo(fontSize: 13)),
          backgroundColor: const Color(0xFF457C3B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(8),
        ),
      );
    }
  }
}
