import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';

class AccountStatementScreen extends StatefulWidget {
  const AccountStatementScreen({super.key});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  String _selectedPeriod = 'الشهر';
  final List<String> _periods = ['اليوم', 'الأسبوع', 'الشهر', 'مخصص'];

  // ✅ تم إزالة البيانات التجريبية واستبدالها بقوائم فارغة
  final List<Map<String, dynamic>> _customerTransactions = [];
  final List<Map<String, dynamic>> _providerTransactions = [];

  @override
  Widget build(BuildContext context) {
    final isProvider = AuthManager.isLoggedIn && AuthManager.isProvider;
    final transactions = isProvider ? _providerTransactions : _customerTransactions;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isProvider ? 'كشف حساب المزود' : 'كشف حساب العميل',
          style: const TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: AppColors.goldLight),
            onPressed: () => _exportStatement(),
            tooltip: 'تصدير الكشف',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodFilter(),
            const SizedBox(height: 20),

            if (isProvider) _buildProviderSummary() else _buildCustomerSummary(),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'سجل المعاملات',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${transactions.length} معاملة',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ واجهة فارغة أنيقة في حال عدم وجود معاملات
            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 60, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد معاملات في هذه الفترة',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(
                transactions.length,
                (index) {
                  final tx = transactions[index];
                  return _buildTransactionCard(tx, isProvider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.goldLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0A0E1A) : Colors.white70,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomerSummary() {
    // ✅ تم تصفير القيم الوهمية
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.crystalBlue.withValues(alpha: 0.3),
            AppColors.waterBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem('الرصيد المتبقي', '0.00 د.أ', AppColors.refillGreen, Icons.account_balance_wallet),
              _summaryItem('إجمالي المشتريات', '0.00 د.أ', AppColors.plumberRed, Icons.shopping_bag),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem('المكافآت', '0.00 د.أ', AppColors.goldLight, Icons.emoji_events),
              _summaryItem('عدد الطلبات', '0', AppColors.crystalBlue, Icons.receipt_long),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSummary() {
    // ✅ تم تصفير القيم الوهمية
    const totalSales = 0.0;
    const totalCommission = 0.0;
    const netProfit = 0.0;
    const companyDue = 0.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.goldLight.withValues(alpha: 0.3),
                AppColors.goldDark.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldLight.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'صافي أرباحك',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                '$netProfit د.أ',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('المبيعات', '$totalSales د.أ', AppColors.refillGreen, Icons.trending_up),
                  _summaryItem('العمولات', '$totalCommission د.أ', AppColors.plumberRed, Icons.percent),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: companyDue > 0 ? AppColors.plumberRed.withValues(alpha: 0.15) : AppColors.refillGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: companyDue > 0 ? AppColors.plumberRed.withValues(alpha: 0.5) : AppColors.refillGreen.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                companyDue > 0 ? Icons.warning_amber : Icons.check_circle,
                color: companyDue > 0 ? AppColors.plumberRed : AppColors.refillGreen,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyDue > 0 ? 'مستحق للشركة' : 'رصيد لك لدى الشركة',
                      style: TextStyle(
                        color: companyDue > 0 ? AppColors.plumberRed : AppColors.refillGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$companyDue د.أ',
                      style: TextStyle(
                        color: companyDue > 0 ? AppColors.plumberRed : AppColors.refillGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showPaymentDialog(companyDue),
                style: ElevatedButton.styleFrom(
                  backgroundColor: companyDue > 0 ? AppColors.plumberRed : AppColors.refillGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text(companyDue > 0 ? 'ادفع الآن' : 'اسحب الرصيد'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx, bool isProvider) {
    final amount = tx['amount'] as double;
    final isPositive = amount > 0;
    final commission = isProvider ? (tx['commission'] as double?) ?? 0 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.refillGreen : AppColors.plumberRed).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTransactionIcon(tx['type']),
              color: isPositive ? AppColors.refillGreen : AppColors.plumberRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['desc'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${tx['date']} - ${tx['time']}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.crystalBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx['status'],
                        style: const TextStyle(
                          color: AppColors.crystalBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isProvider && commission != 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'عمولة الشركة: ${commission.toStringAsFixed(2)} د.أ',
                      style: TextStyle(
                        color: AppColors.plumberRed.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${amount.toStringAsFixed(2)} د.أ',
                style: TextStyle(
                  color: isPositive ? AppColors.refillGreen : AppColors.plumberRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isProvider && commission != 0)
                Text(
                  'صافي: ${(amount + commission).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.goldLight.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'شراء':
      case 'مبيعة':
        return Icons.shopping_bag;
      case 'شحن':
      case 'سحب':
        return Icons.account_balance_wallet;
      case 'مكافأة':
        return Icons.emoji_events;
      case 'عمولة':
        return Icons.percent;
      default:
        return Icons.receipt_long;
    }
  }

  void _exportStatement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('جاري تصدير كشف الحساب PDF... 📄'),
          ],
        ),
        backgroundColor: AppColors.crystalBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPaymentDialog(double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          amount > 0 ? 'تسوية مستحقات الشركة' : 'سحب الأرباح',
          style: const TextStyle(color: AppColors.goldLight),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount > 0
                  ? 'المبلغ المستحق للشركة: $amount د.أ'
                  : 'رصيدك المتاح للسحب: ${amount.abs()} د.أ',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.crystalBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.crystalBlue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم خصم/تحويل المبلغ من/إلى محفظتك',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(amount > 0 ? 'تم تسوية المستحقات ✅' : 'تم سحب الأرباح بنجاح 💰'),
                  backgroundColor: AppColors.refillGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: amount > 0 ? AppColors.plumberRed : AppColors.refillGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(amount > 0 ? 'ادفع الآن' : 'تأكيد السحب'),
          ),
        ],
      ),
    );
  }
}