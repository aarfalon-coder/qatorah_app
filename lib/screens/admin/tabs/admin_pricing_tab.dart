import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'pricing_editors/water_pricing_editor.dart';
import 'pricing_editors/tank_pricing_editor.dart';
import 'pricing_editors/gas_pricing_editor.dart';

class AdminPricingTab extends StatefulWidget {
  const AdminPricingTab({super.key});

  @override
  State<AdminPricingTab> createState() => _AdminPricingTabState();
}

class _AdminPricingTabState extends State<AdminPricingTab> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF0A0E1A),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.price_change, color: AppColors.goldLight, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إدارة التسعير الشامل', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('مياه • تنك • غاز', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _filterButton('الكل', 'all'),
                  _filterButton('محطات مياه', 'station'),
                  _filterButton('تنك مياه', 'tanker'),
                  _filterButton('غاز', 'gas'),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('suppliers')
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_mall_directory, color: Colors.white24, size: 64),
                      SizedBox(height: 16),
                      Text('لا توجد محطات نشطة', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              }

              final suppliers = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final type = data['type'] ?? data['role'] ?? 'station';
                if (_filterType == 'all') return true;
                return type == _filterType;
              }).toList();

              if (suppliers.isEmpty) {
                return const Center(child: Text('لا يوجد مزودين بهذا النوع', style: TextStyle(color: Colors.white54)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  final doc = suppliers[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final prices = Map<String, dynamic>.from(data['prices'] ?? {});
                  final type = data['type'] ?? data['role'] ?? 'station';
                  final productsCount = prices.length;

                  return GestureDetector(
                    onTap: () => _openPricingEditor(doc.id, data['name'] ?? 'مزود', type, prices),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getTypeColor(type).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getTypeColor(type).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getTypeIcon(type), color: _getTypeColor(type), size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'مزود بدون اسم',
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['address'] ?? '',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(type).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getTypeName(type),
                                        style: TextStyle(color: _getTypeColor(type), fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$productsCount منتج مسعّر',
                                      style: const TextStyle(color: AppColors.goldLight, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white54, size: 24),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openPricingEditor(String supplierId, String supplierName, String type, Map<String, dynamic> currentPrices) {
    Widget editor;
    
    switch (type) {
      case 'station':
        editor = WaterPricingEditor(
          supplierId: supplierId,
          supplierName: supplierName,
          currentPrices: currentPrices,
        );
        break;
      case 'tanker':
        editor = TankPricingEditor(
          supplierId: supplierId,
          supplierName: supplierName,
          currentPrices: currentPrices,
        );
        break;
      case 'gas':
        editor = GasPricingEditor(
          supplierId: supplierId,
          supplierName: supplierName,
          currentPrices: currentPrices,
        );
        break;
      default:
        editor = WaterPricingEditor(
          supplierId: supplierId,
          supplierName: supplierName,
          currentPrices: currentPrices,
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => editor),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'station': return AppColors.waterBlue;
      case 'tanker': return AppColors.tankCyan;
      case 'gas': return AppColors.maintenanceOrange;
      default: return AppColors.crystalBlue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'station': return Icons.water_drop;
      case 'tanker': return Icons.opacity;
      case 'gas': return Icons.local_fire_department;
      default: return Icons.store;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'station': return 'محطة مياه';
      case 'tanker': return 'تنك مياه';
      case 'gas': return 'غاز';
      default: return 'مزود';
    }
  }

  Widget _filterButton(String label, String type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () => setState(() => _filterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldLight.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.goldLight : Colors.white24),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? AppColors.goldLight : Colors.white54, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}