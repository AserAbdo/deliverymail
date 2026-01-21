import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cart_service.dart';
import '../../../cart/presentation/screens/cart_screen.dart';

/// Header Icons Widget for Home Screen
/// ويدجت أيقونات الرأس للشاشة الرئيسية

/// Simple Header Icon Button
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const HeaderIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 24),
      ),
    );
  }
}

/// Cart Icon with Badge
class CartIconButton extends StatelessWidget {
  final CartService cartService;

  const CartIconButton({super.key, required this.cartService});

  @override
  Widget build(BuildContext context) {
    final cartCount = cartService.itemCount;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.primaryGreen,
              size: 24,
            ),
            if (cartCount > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    cartCount > 99 ? '99+' : '$cartCount',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
