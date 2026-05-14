import 'package:flutter/material.dart';
import 'package:lumina/core/theme/app_colors.dart';

class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final bool isFullWidth;
  final bool hasShadow;
  final Color shadowColor;
  final double paddingHorizontal;
  final double paddingVertical;

  const BigButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    required this.textColor,
    this.isFullWidth = false,
    this.hasShadow = true,
    this.shadowColor = AppColors.primaryPurple,
    this.paddingHorizontal = 32,
    this.paddingVertical = 12
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}


