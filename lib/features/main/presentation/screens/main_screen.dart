import 'package:flutter/material.dart';
import 'package:khodargy/features/products/presentation/screens/home_screen.dart';

/// Main Screen - Home Only (Bottom Navigation Removed)
/// الشاشة الرئيسية - الصفحة الرئيسية فقط (تم إزالة شريط التنقل السفلي)
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
