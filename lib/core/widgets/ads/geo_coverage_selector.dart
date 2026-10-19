import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/models/region_model.dart';

class GeoCoverageSelector extends StatelessWidget {
  final Governorate selected;
  final AdType type;
  final ValueChanged<Governorate> onChanged;
  const GeoCoverageSelector({super.key, required this.selected, required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cov = Regions.describeCoverage(selected, type.code);
    final accent = type == AdType.free ? AppColors.crystalBlue : AppColors.goldLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('محافظة المزود', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Governorate>(
              value: selected,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1F2E),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              icon: const Icon(Icons.expand_more, color: AppColors.goldLight),
              items: Governorate.values.map((g) => DropdownMenuItem(
                value: g,
                child: Row(children: [
                  Text(g.displayName),
                  const SizedBox(width: 6),
                  Text('(${g.region.displayName})', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                ]),
              )).toList(),
              onChanged: (g) { if (g != null) onChanged(g); },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.map_outlined, color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('نطاق الظهور: $cov', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, height: 1.4))),
            ],
          ),
        ),
      ],
    );
  }
}
