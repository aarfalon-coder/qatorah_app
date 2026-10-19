import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/advertisement_model.dart';

class AdTypeBadge extends StatelessWidget {
  final AdType type;
  final bool compact;
  const AdTypeBadge({super.key, required this.type, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = _colorsFor(type);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type.emoji, style: TextStyle(fontSize: compact ? 10 : 13)),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(type.label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  (Color, Color) _colorsFor(AdType type) {
    switch (type) {
      case AdType.free:
        return (AppColors.crystalBlue, AppColors.crystalBlue.withValues(alpha: 0.15));
      case AdType.premium:
        return (AppColors.goldLight, AppColors.goldLight.withValues(alpha: 0.15));
      case AdType.qatorah:
        return (AppColors.factoryPurple, AppColors.factoryPurple.withValues(alpha: 0.15));
    }
  }
}