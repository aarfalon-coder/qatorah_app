import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class StarRatingWidget extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowTap;
  final Function(int)? onRatingSelected;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 32,
    this.activeColor = AppColors.goldLight,
    this.inactiveColor = Colors.white24,
    this.allowTap = false,
    this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final isActive = starValue <= rating;
        
        return GestureDetector(
          onTap: allowTap && onRatingSelected != null 
              ? () => onRatingSelected!(starValue) 
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isActive ? Icons.star : Icons.star_border,
              color: isActive ? activeColor : inactiveColor,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}