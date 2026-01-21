import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gradient Text Widget - دليفري مول Brand Style
/// ويدجت النص المتدرج - بنمط علامة دليفري مول التجارية
class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const GradientText({
    super.key,
    required this.text,
    this.fontSize = 28,
    this.fontWeight = FontWeight.bold,
  });

  /// Brand gradient - Dark Green (left) to Orange (right)
  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF2E7D32), // Dark green (left side)
      Color(0xFFFF9800), // Orange (right side)
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => brandGradient.createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white, // This will be masked by the shader
        ),
      ),
    );
  }
}

/// Brand Logo Text - "دليفري مول" with gradient
/// نص الشعار التجاري - "دليفري مول" مع التدرج
class BrandLogoText extends StatelessWidget {
  final double fontSize;

  const BrandLogoText({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return GradientText(
      text: 'دليفري مول',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );
  }
}
