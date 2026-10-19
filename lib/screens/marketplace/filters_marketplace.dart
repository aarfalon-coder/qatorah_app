import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class FiltersMarketplaceScreen extends StatefulWidget {
  const FiltersMarketplaceScreen({super.key});

  @override
  State<FiltersMarketplaceScreen> createState() => _FiltersMarketplaceScreenState();
}

class _FiltersMarketplaceScreenState extends State<FiltersMarketplaceScreen> {
  String _category = 'all';
  RangeValues _priceRange = const RangeValues(0, 500);
  double _minRating = 0;

  final _categories = [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'filter', 'label': 'فلاتر'},
    {'id': 'pump', 'label': 'مضخات'},
    {'id': 'machine', 'label': 'ماكينات'},
    {'id': 'parts', 'label': 'قطع غيار'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الفلاتر', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('الفئة', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _categories.map((c) => GestureDetector(
              onTap: () => setState(() => _category = c['id'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _category == c['id'] ? AppColors.factoryPurple.withValues(alpha: 0.2) : const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _category == c['id'] ? AppColors.factoryPurple : Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(c['label'] as String, style: TextStyle(color: _category == c['id'] ? AppColors.factoryPurple : Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          const Text('السعر', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500,
            divisions: 50,
            activeColor: AppColors.goldLight,
            labels: RangeLabels('${_priceRange.start.toInt()}', '${_priceRange.end.toInt()}'),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          Center(child: Text('${_priceRange.start.toInt()} - ${_priceRange.end.toInt()} د.أ', style: const TextStyle(color: Colors.white70, fontSize: 13))),
          const SizedBox(height: 24),
          const Text('التقييم الأدنى', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _minRating = (i + 1).toDouble()),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(i < _minRating ? Icons.star : Icons.star_border, color: AppColors.goldLight, size: 32),
              ),
            )),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.filter_alt),
              label: const Text('تطبيق الفلاتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.factoryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}