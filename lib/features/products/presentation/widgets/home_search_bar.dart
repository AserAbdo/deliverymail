import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Search Bar Widget for Home Screen
/// ويدجت شريط البحث للشاشة الرئيسية
class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final VoidCallback onMenuTap;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          // Search Icon (Left side)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Icon(Icons.search, color: Colors.grey[600], size: 22),
          ),
          // Clear button (X) - show when there's text
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.grey[600], size: 20),
              ),
            ),
          // Search Input
          Expanded(
            child: TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث باي طريقه ---- بحث ذكي',
                hintStyle: GoogleFonts.cairo(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              style: GoogleFonts.cairo(fontSize: 14),
            ),
          ),
          // Menu Button (3 dots) - Opens Governorate Selection (Right side)
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Icon(Icons.more_vert, color: Colors.grey[600], size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
