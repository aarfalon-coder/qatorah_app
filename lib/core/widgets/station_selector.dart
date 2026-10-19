import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class StationSelector extends StatelessWidget {
  final List<Map<String, dynamic>> stations;
  final String? selectedStationId;
  final ValueChanged<Map<String, dynamic>>? onStationSelected;
  final VoidCallback? onAddStation;
  final bool isLoading;

  const StationSelector({
    super.key,
    required this.stations,
    this.selectedStationId,
    this.onStationSelected,
    this.onAddStation,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.goldLight,
          ),
        ),
      );
    }

    if (stations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 10),
            const Text(
              'لا توجد محطات متاحة',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            if (onAddStation != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onAddStation,
                icon: const Icon(
                  Icons.add,
                  color: AppColors.goldLight,
                  size: 18,
                ),
                label: const Text(
                  'إضافة محطة جديدة',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══ العنوان ═══
          Row(
            children: [
              const Icon(
                Icons.store,
                color: AppColors.goldLight,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'اختر المحطة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onAddStation != null)
                GestureDetector(
                  onTap: onAddStation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.goldLight.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: AppColors.goldLight,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'إضافة',
                          style: TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ═══ قائمة المحطات ═══
          ...stations.map((station) => _buildStationCard(station)),
        ],
      ),
    );
  }

  Widget _buildStationCard(Map<String, dynamic> station) {
    final isSelected = station['id'] == selectedStationId;
    final name = station['name'] ?? 'محطة';
    final address = station['address'] ?? '';
    final rating = station['rating'] ?? 0.0;
    final distance = station['distance'] ?? 0.0;
    final isOpen = station['isOpen'] ?? true;

    return GestureDetector(
      onTap: isOpen ? () => onStationSelected?.call(station) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.goldLight.withValues(alpha: 0.12)
              : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.goldLight
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.goldLight.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Opacity(
          opacity: isOpen ? 1.0 : 0.5,
          child: Row(
            children: [
              // ═══ الأيقونة ═══
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOpen ? Icons.store : Icons.store_outlined,
                  color: AppColors.goldLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // ═══ المعلومات ═══
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isOpen)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.plumberRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'مغلق',
                              style: TextStyle(
                                color: AppColors.plumberRed,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // ═══ التقييم ═══
                        const Icon(
                          Icons.star,
                          color: AppColors.goldLight,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // ═══ المسافة ═══
                        const Icon(
                          Icons.location_on,
                          color: Colors.white54,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${distance.toStringAsFixed(1)} كم',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ═══ علامة الاختيار ═══
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.goldLight,
                  size: 24,
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}