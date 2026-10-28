import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminAccountingTab extends StatefulWidget {
  const AdminAccountingTab({super.key});

  @override
  State<AdminAccountingTab> createState() => _AdminAccountingTabState();
}

class _AdminAccountingTabState extends State<AdminAccountingTab> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _period = 'today'; // today, week, month, all
  final double _platformCommissionRate = 0.10; // 10% عمولة المنصة (قابلة للتعديل)

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // رأس التبويب + الفلاتر
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
                    child: const Icon(Icons.account_balance_wallet, color: AppColors.goldLight, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المحاسبة والتقارير', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('إحصائيات مالية حقيقية من قاعدة البيانات', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // فلاتر الفترة الزمنية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _periodButton('اليوم', 'today'),
                  _periodButton('الأسبوع', 'week'),
                  _periodButton('الشهر', 'month'),
                  _periodButton('الكل', 'all'),
                ],
              ),
            ],
          ),
        ),

        // المحتوى الرئيسي
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('orders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, color: Colors.white24, size: 64),
                      SizedBox(height: 16),
                      Text('لا توجد طلبات حتى الآن', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              }

              // فلترة الطلبات حسب الفترة
              final allOrders = snapshot.data!.docs;
              final filteredOrders = _filterByPeriod(allOrders);

              // حساب الإحصائيات
              final stats = _calculateStats(filteredOrders);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // بطاقات الإحصائيات الرئيسية
                  _buildMainStatsCards(stats),
                  const SizedBox(height: 20),

                  // تقسيم حسب نوع الخدمة
                  _buildServiceBreakdown(stats),
                  const SizedBox(height: 20),

                  // تقسيم حسب طريقة الدفع
                  _buildPaymentBreakdown(stats),
                  const SizedBox(height: 20),

                  // آخر الطلبات
                  _buildRecentOrders(filteredOrders),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // دالة فلترة الطلبات حسب الفترة الزمنية
  // ═══════════════════════════════════════════════════════════════
  List<QueryDocumentSnapshot> _filterByPeriod(List<QueryDocumentSnapshot> orders) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_period) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        return orders; // all
    }

    return orders.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'];
      if (timestamp is Timestamp) {
        return timestamp.toDate().isAfter(startDate);
      }
      return false;
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════
  // دالة حساب الإحصائيات
  // ═══════════════════════════════════════════════════════════════
  Map<String, dynamic> _calculateStats(List<QueryDocumentSnapshot> orders) {
    double totalRevenue = 0;
    int totalOrders = 0;
    int completedOrders = 0;
    int cancelledOrders = 0;
    Map<String, double> serviceRevenue = {};
    Map<String, double> paymentRevenue = {};
    double totalDiscount = 0;

    for (final doc in orders) {
      final data = doc.data() as Map<String, dynamic>;
      final details = Map<String, dynamic>.from(data['details'] ?? {});
      final status = data['status'] ?? 'completed'; // افتراضي: مكتمل
      final finalTotal = (details['final_total'] ?? 0.0).toDouble();
      final serviceType = data['serviceType'] ?? 'unknown';
      final paymentMethod = details['payment_method'] ?? 'cash';
      final discount = (details['coupon_discount'] ?? 0.0).toDouble();

      totalOrders++;

      if (status == 'completed') {
        completedOrders++;
        totalRevenue += finalTotal;

        // تجميع حسب نوع الخدمة
        serviceRevenue[serviceType] = (serviceRevenue[serviceType] ?? 0) + finalTotal;

        // تجميع حسب طريقة الدفع
        paymentRevenue[paymentMethod] = (paymentRevenue[paymentMethod] ?? 0) + finalTotal;

        totalDiscount += discount;
      } else if (status == 'cancelled') {
        cancelledOrders++;
      }
    }

    final platformCommission = totalRevenue * _platformCommissionRate;
    final netRevenue = totalRevenue - platformCommission;

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'serviceRevenue': serviceRevenue,
      'paymentRevenue': paymentRevenue,
      'totalDiscount': totalDiscount,
      'platformCommission': platformCommission,
      'netRevenue': netRevenue,
    };
  }

  // ══════════════════════════════════════════════════════════════
  // بطاقات الإحصائيات الرئيسية
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainStatsCards(Map<String, dynamic> stats) {
    return Column(
      children: [
        // الإيرادات
        _statCard(
          title: 'إجمالي الإيرادات',
          value: '${(stats['totalRevenue'] as double).toStringAsFixed(2)} د.أ',
          icon: Icons.attach_money,
          color: AppColors.refillGreen,
          subtitle: '${stats['completedOrders']} طلب مكتمل',
        ),
        const SizedBox(height: 12),

        // عمولة المنصة + الصافي
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'عمولة المنصة (${(_platformCommissionRate * 100).toInt()}%)',
                value: '${(stats['platformCommission'] as double).toStringAsFixed(2)} د.أ',
                icon: Icons.percent,
                color: AppColors.crystalBlue,
                isSmall: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'صافي المنصة',
                value: '${(stats['netRevenue'] as double).toStringAsFixed(2)} د.أ',
                icon: Icons.account_balance_wallet,
                color: AppColors.goldLight,
                isSmall: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // الطلبات والإلغاءات
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'إجمالي الطلبات',
                value: '${stats['totalOrders']}',
                icon: Icons.receipt_long,
                color: AppColors.waterBlue,
                isSmall: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'ملغاة',
                value: '${stats['cancelledOrders']}',
                icon: Icons.cancel,
                color: AppColors.plumberRed,
                isSmall: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'خصومات',
                value: '${(stats['totalDiscount'] as double).toStringAsFixed(2)} د.أ',
                icon: Icons.discount,
                color: AppColors.maintenanceOrange,
                isSmall: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isSmall ? 20 : 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: isSmall ? 11 : 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: isSmall ? 18 : 22, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // تقسيم حسب نوع الخدمة
  // ═══════════════════════════════════════════════════════════════
  Widget _buildServiceBreakdown(Map<String, dynamic> stats) {
    final serviceRevenue = Map<String, double>.from(stats['serviceRevenue'] as Map);
    final total = stats['totalRevenue'] as double;

    if (serviceRevenue.isEmpty) {
      return _emptySection('لا توجد بيانات للخدمات');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category, color: AppColors.waterBlue, size: 20),
              SizedBox(width: 8),
              Text('الإيرادات حسب نوع الخدمة', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...serviceRevenue.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_getServiceName(entry.key), style: const TextStyle(color: Colors.white, fontSize: 13)),
                    Text('${entry.value.toStringAsFixed(2)} د.أ (${percentage.toStringAsFixed(1)}%)', style: const TextStyle(color: AppColors.goldLight, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.waterBlue),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _getServiceName(String type) {
    switch (type) {
      case 'water_delivery': return 'توصيل مياه';
      case 'home_refill': return 'تعبئة منزلية';
      case 'water_tank': return 'تنك مياه';
      case 'gas': return 'غاز منزلي';
      case 'maintenance': return 'صيانة';
      default: return type;
    }
  }

  // ═════════════════════════════════════════════════════════════
  // تقسيم حسب طريقة الدفع
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPaymentBreakdown(Map<String, dynamic> stats) {
    final paymentRevenue = Map<String, double>.from(stats['paymentRevenue'] as Map);

    if (paymentRevenue.isEmpty) {
      return _emptySection('لا توجد بيانات لطرق الدفع');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment, color: AppColors.crystalBlue, size: 20),
              SizedBox(width: 8),
              Text('الإيرادات حسب طريقة الدفع', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: paymentRevenue.entries.map((entry) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.crystalBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getPaymentIcon(entry.key), color: AppColors.crystalBlue, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(_getPaymentName(entry.key), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${entry.value.toStringAsFixed(2)} د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'cash': return Icons.money;
      case 'wallet': return Icons.account_balance_wallet;
      case 'coupon': return Icons.card_giftcard;
      default: return Icons.payment;
    }
  }

  String _getPaymentName(String method) {
    switch (method) {
      case 'cash': return 'كاش';
      case 'wallet': return 'محفظة';
      case 'coupon': return 'كوبون';
      default: return method;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // آخر الطلبات
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRecentOrders(List<QueryDocumentSnapshot> orders) {
    if (orders.isEmpty) {
      return _emptySection('لا توجد طلبات');
    }

    // نأخذ آخر 10 طلبات
    final recentOrders = orders.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: AppColors.maintenanceOrange, size: 20),
              SizedBox(width: 8),
              Text('آخر الطلبات', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...recentOrders.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final details = Map<String, dynamic>.from(data['details'] ?? {});
            final finalTotal = (details['final_total'] ?? 0.0).toDouble();
            final customerName = data['customerName'] ?? 'عميل';
            final serviceType = data['serviceType'] ?? 'unknown';
            final timestamp = data['timestamp'];
            String timeStr = '';
            if (timestamp is Timestamp) {
              timeStr = DateFormat('yyyy/MM/dd HH:mm').format(timestamp.toDate());
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.waterBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getServiceIcon(serviceType), color: AppColors.waterBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customerName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${_getServiceName(serviceType)} • $timeStr', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                      ],
                    ),
                  ),
                  Text('${finalTotal.toStringAsFixed(2)} د.أ', style: const TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String type) {
    switch (type) {
      case 'water_delivery': return Icons.water_drop;
      case 'home_refill': return Icons.home;
      case 'water_tank': return Icons.opacity;
      case 'gas': return Icons.local_fire_department;
      case 'maintenance': return Icons.build;
      default: return Icons.receipt;
    }
  }

  Widget _emptySection(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ),
    );
  }

  Widget _periodButton(String label, String period) {
    final isSelected = _period == period;
    return GestureDetector(
      onTap: () => setState(() => _period = period),
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