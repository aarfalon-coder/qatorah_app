import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class ProviderOrdersScreen extends StatefulWidget {
  const ProviderOrdersScreen({super.key});

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState extends State<ProviderOrdersScreen> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _orders = [
    {'id': '1', 'customer': 'أحمد محمد', 'service': 'أسطوانة غاز', 'status': 'new', 'time': '12:10 م', 'amount': '12.50 د.أ'},
    {'id': '2', 'customer': 'سارة علي', 'service': 'تنك مياه', 'status': 'progress', 'time': '11:45 ص', 'amount': '8.00 د.أ'},
    {'id': '3', 'customer': 'محمد حسن', 'service': 'صيانة خزان', 'status': 'completed', 'time': '10:30 ص', 'amount': '25.00 د.أ'},
    {'id': '4', 'customer': 'فاطمة أحمد', 'service': 'أسطوانة غاز', 'status': 'cancelled', 'time': 'أمس', 'amount': '12.50 د.أ'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الطلبات', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Column(
        children: [
          // ═══ فلتر الحالات ═══
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'الكل', Icons.list),
                _buildFilterChip('new', 'جديد', Icons.fiber_new),
                _buildFilterChip('progress', 'قيد التنفيذ', Icons.hourglass_empty),
                _buildFilterChip('completed', 'مكتمل', Icons.check_circle),
                _buildFilterChip('cancelled', 'ملغي', Icons.cancel),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ═══ قائمة الطلبات ═══
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _orders.length,
              itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0A0E1A) : Colors.white, fontSize: 12)),
        avatar: Icon(icon, size: 16, color: isSelected ? const Color(0xFF0A0E1A) : Colors.white54),
        onSelected: (selected) => setState(() => _selectedFilter = value),
        backgroundColor: const Color(0xFF1A1F2E),
        selectedColor: AppColors.goldLight,
        checkmarkColor: const Color(0xFF0A0E1A),
        side: BorderSide(color: isSelected ? AppColors.goldLight : Colors.white.withValues(alpha: 0.1)),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order['status']) {
      case 'new':
        statusColor = AppColors.crystalBlue;
        statusText = 'جديد';
        statusIcon = Icons.fiber_new;
        break;
      case 'progress':
        statusColor = AppColors.goldLight;
        statusText = 'قيد التنفيذ';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'completed':
        statusColor = AppColors.refillGreen;
        statusText = 'مكتمل';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = AppColors.plumberRed;
        statusText = 'ملغي';
        statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('طلب #${order['id']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(order['customer'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.shopping_bag, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Text(order['service'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              const Icon(Icons.access_time, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Text(order['time'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'المبلغ: ${order['amount']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم تحديث حالة الطلب #${order['id']}'), backgroundColor: AppColors.refillGreen),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('تحديث الحالة', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}