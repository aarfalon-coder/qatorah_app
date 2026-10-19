import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

/// كرت زجاجي فاخر قابل لإعادة الاستخدام
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.crystalBlue,
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.goldDark.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  glowColor.withValues(alpha: 0.2),
                  glowColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر ذهبي فاخر
class GoldButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final double height;

  const GoldButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 22) : const SizedBox.shrink(),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldDark,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}

/// عنوان ذهبي
class GoldTitle extends StatelessWidget {
  final String text;
  final double fontSize;

  const GoldTitle({super.key, required this.text, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.goldLight,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
