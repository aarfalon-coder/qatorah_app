import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/profile_manager.dart';
import 'package:qatorah_app/screens/account_statement_screen.dart';
import 'package:qatorah_app/screens/customer/payment_history_screen.dart';
import 'package:qatorah_app/screens/customer/my_reviews_screen.dart';
import 'package:qatorah_app/screens/customer/payment_options_dialog.dart';

class CustomerIdScreen extends StatefulWidget {
  const CustomerIdScreen({super.key});

  @override
  State<CustomerIdScreen> createState() => _CustomerIdScreenState();
}

class _CustomerIdScreenState extends State<CustomerIdScreen> {
  int _gasQty = 1;
  String _tankSize = '4';
  int _pointsToRedeem = 100;
  int _currentPoints = 1250;
  double _currentBalance = 45.50;

  bool _isGasExpanded = false;
  bool _isTankExpanded = false;
  bool _isRewardsExpanded = false;

  final double _cylinderPrice = 7.0;
  final double _gasDelivery = 0.5;
  double get _gasTotal => (_gasQty * _cylinderPrice) + _gasDelivery;

  final List<String> _tankSizes = ['3', '4', '6', '8', '10', '20'];
  final double _pricePerMeter = 3.0;
  final double _tankDelivery = 1.0;

  double _getTankPrice(String size) => (int.parse(size) * _pricePerMeter) + _tankDelivery;
  double get _tankTotal => _getTankPrice(_tankSize);
  double get _discount => _pointsToRedeem * 0.01;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A3E), Color(0xFF2D1B69), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildProfileSection(),
                const SizedBox(height: 24),
                _buildDigitalIdCard(),
                const SizedBox(height: 24),
                _buildBalanceCard(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),

                const Text('الدفع السريع', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 1. دفع أسطوانة غاز ✅ الاسم الجديد
                _buildServiceOption(
                  icon: Icons.local_fire_department,
                  title: 'دفع أسطوانة غاز',
                  subtitle: 'حدد الكمية وادفع مباشرة',
                  color: const Color(0xFFE65100),
                  price: 'ادفع',
                  onTap: () => setState(() {
                    _isGasExpanded = !_isGasExpanded;
                    _isTankExpanded = false;
                    _isRewardsExpanded = false;
                  }),
                ),
                if (_isGasExpanded) ...[
                  const SizedBox(height: 10),
                  _buildGasOrderCard(),
                ],
                const SizedBox(height: 10),

                // 2. دفع تنك مياه ✅ الاسم الجديد
                _buildServiceOption(
                  icon: Icons.water_drop,
                  title: 'دفع تنك مياه',
                  subtitle: 'اختر الحجم وادفع مباشرة',
                  color: AppColors.tankCyan,
                  price: 'ادفع',
                  onTap: () => setState(() {
                    _isTankExpanded = !_isTankExpanded;
                    _isGasExpanded = false;
                    _isRewardsExpanded = false;
                  }),
                ),
                if (_isTankExpanded) ...[
                  const SizedBox(height: 10),
                  _buildTankOrderCard(),
                ],
                const SizedBox(height: 10),

                // 3. المكافآت
                _buildServiceOption(
                  icon: Icons.emoji_events,
                  title: 'المكافآت والاستبدال',
                  subtitle: 'استبدل نقاطك بخصومات',
                  color: AppColors.goldLight,
                  price: 'استبدل',
                  onTap: () => setState(() {
                    _isRewardsExpanded = !_isRewardsExpanded;
                    _isGasExpanded = false;
                    _isTankExpanded = false;
                  }),
                ),
                if (_isRewardsExpanded) ...[
                  const SizedBox(height: 10),
                  _buildRewardsCard(),
                ],
                const SizedBox(height: 24),

                const Text('خدمات أخرى', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                _buildServiceOption(
                  icon: Icons.receipt_long,
                  title: 'كشف الحساب',
                  subtitle: 'عرض المعاملات والمستحقات',
                  color: AppColors.crystalBlue,
                  price: 'عرض',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountStatementScreen())),
                ),
                const SizedBox(height: 10),

                _buildServiceOption(
                  icon: Icons.payment,
                  title: 'سجل المدفوعات',
                  subtitle: 'عرض جميع عمليات الدفع',
                  color: AppColors.refillGreen,
                  price: 'عرض',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
                ),
                const SizedBox(height: 10),

                _buildServiceOption(
                  icon: Icons.star_rate,
                  title: 'تقييماتي',
                  subtitle: 'عرض وتقييم المزودين',
                  color: AppColors.goldLight,
                  price: 'عرض',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsScreen())),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══ بطاقة دفع الغاز ═══
  Widget _buildGasOrderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('حدد عدد الأسطوانات', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircleBtn(Icons.remove, () => setState(() { if (_gasQty > 1) _gasQty--; }), AppColors.plumberRed),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text('$_gasQty', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(_gasQty == 1 ? 'أسطوانة' : 'أسطوانات', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                ],
              ),
              const SizedBox(width: 20),
              _buildCircleBtn(Icons.add, () => setState(() => _gasQty++), AppColors.refillGreen),
            ],
          ),
          const SizedBox(height: 16),
          _calcRow('سعر الأسطوانة', '${_cylinderPrice.toInt()} د.أ × $_gasQty', Colors.white70),
          const SizedBox(height: 6),
          _calcRow('أجور النقل (ثابتة)', '${_gasDelivery.toStringAsFixed(1)} د.أ', AppColors.waterBlue),
          const Divider(color: Colors.white24, height: 16),
          _calcRow('المجموع الكلي', '${_gasTotal.toStringAsFixed(2)} د.أ', AppColors.goldLight, isTotal: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPaymentOptions(_gasTotal, '$_gasQty أسطوانة غاز'),
              icon: const Icon(Icons.payment),
              label: const Text('ادفع الآن', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ═══ بطاقة دفع التنك ═══
  Widget _buildTankOrderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tankCyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('اختر حجم التنك', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tankSizes.map((size) {
              bool isSelected = _tankSize == size;
              return GestureDetector(
                onTap: () => setState(() => _tankSize = size),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tankCyan.withValues(alpha: 0.3) : const Color(0xFF1A1F2E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? AppColors.tankCyan : Colors.white24, width: isSelected ? 2 : 1),
                  ),
                  child: Column(
                    children: [
                      Text('$size متر', style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${_getTankPrice(size).toStringAsFixed(0)} د.أ', style: TextStyle(color: isSelected ? AppColors.goldLight : Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _calcRow('سعر التنك ($_tankSize متر)', '${(_tankTotal - _tankDelivery).toStringAsFixed(0)} د.أ', Colors.white70),
          const SizedBox(height: 6),
          _calcRow('أجور النقل', '${_tankDelivery.toStringAsFixed(0)} د.أ', AppColors.waterBlue),
          const Divider(color: Colors.white24, height: 16),
          _calcRow('المجموع الكلي', '${_tankTotal.toStringAsFixed(0)} د.أ', AppColors.goldLight, isTotal: true),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPaymentOptions(_tankTotal, 'تنك $_tankSize متر'),
              icon: const Icon(Icons.payment),
              label: const Text('ادفع الآن', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tankCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ═══ بطاقة المكافآت (مصححة - لا تنهار أبداً) ═══
  Widget _buildRewardsCard() {
    // ✅ الحماية من الشاشة الحمراء: نتأكد أن max >= min دائماً
    final int safeMax = _currentPoints < 100 ? 100 : _currentPoints;
    final int safeValue = _pointsToRedeem > safeMax ? safeMax : _pointsToRedeem;
    final int rawDivisions = (safeMax - 100) ~/ 50;
    final int safeDivisions = rawDivisions < 1 ? 1 : rawDivisions;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('نقاطك الحالية: $_currentPoints نقطة', style: const TextStyle(color: AppColors.goldLight, fontSize: 13, fontWeight: FontWeight.bold)),
          Slider(
            value: safeValue.toDouble(),
            min: 100,
            max: safeMax.toDouble(),
            divisions: safeDivisions,
            activeColor: AppColors.goldLight,
            inactiveColor: Colors.white24,
            label: '$safeValue نقطة',
            onChanged: (val) => setState(() => _pointsToRedeem = val.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _pointsBox('النقاط', '$safeValue', AppColors.goldLight),
              const Icon(Icons.arrow_forward, color: AppColors.goldLight),
              _pointsBox('الخصم', '${(safeValue * 0.01).toStringAsFixed(2)} د.أ', AppColors.refillGreen),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _redeemPoints(),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('تأكيد الاستبدال'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldLight,
                foregroundColor: const Color(0xFF0A0E1A),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ═══ نافذة اختيار طريقة الدفع ═══
  void _showPaymentOptions(double amount, String itemName) {
    showDialog(
      context: context,
      builder: (ctx) => PaymentOptionsDialog(
        amount: amount,
        itemName: itemName,
        walletBalance: _currentBalance,
        onPaymentSelected: (method) {
          Navigator.pop(ctx);
          _processPayment(amount, itemName, method);
        },
      ),
    );
  }

  // ═══ معالجة الدفع ═══
  void _processPayment(double amount, String itemName, String paymentMethod) {
    if (paymentMethod == 'wallet') {
      if (_currentBalance < amount) {
        _showErrorDialog('رصيد غير كافٍ', 'رصيد محفظتك لا يكفي لإتمام هذه العملية');
        return;
      }
      setState(() { _currentBalance -= amount; });
      _showSuccessDialog(
        'تم الدفع بنجاح! ✅',
        'تم خصم ${amount.toStringAsFixed(2)} د.أ من محفظتك\nالرصيد المتبقي: ${_currentBalance.toStringAsFixed(2)} د.أ\n$itemName',
        Icons.check_circle,
        AppColors.refillGreen,
      );
    } else if (paymentMethod == 'cash') {
      _showSuccessDialog(
        'تم تسجيل الطلب! 📦',
        'سيتم الدفع نقداً عند الاستلام\nالمبلغ: ${amount.toStringAsFixed(2)} د.أ\n$itemName\n\nسيصلك السائق خلال ساعة',
        Icons.payments,
        AppColors.crystalBlue,
      );
    }
  }

  // ═══ استبدال النقاط (مصحح 100%) ═══
  void _redeemPoints() {
    // ✅ نحفظ القيم قبل التغيير حتى لا تنهار الرسالة
    final int redeemedPoints = _pointsToRedeem;
    final double discountAmount = _pointsToRedeem * 0.01;

    if (redeemedPoints > _currentPoints) {
      _showErrorDialog('نقاط غير كافية', 'رصيد نقاطك لا يسمح بهذا الاستبدال');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تأكيد الاستبدال', style: TextStyle(color: AppColors.goldLight)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_horiz, color: AppColors.goldLight, size: 50),
            const SizedBox(height: 12),
            Text('استبدال $redeemedPoints نقطة', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('بخصم ${discountAmount.toStringAsFixed(2)} د.أ', style: const TextStyle(color: AppColors.refillGreen, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentPoints -= redeemedPoints;
                _currentBalance += discountAmount;
                _pointsToRedeem = 100;
              });
              Navigator.pop(ctx);
              _showSuccessDialog(
                'تم الاستبدال بنجاح! ✅',
                'تم خصم $redeemedPoints نقطة\nوإضافة ${discountAmount.toStringAsFixed(2)} د.أ لرصيدك\nالرصيد الجديد: ${_currentBalance.toStringAsFixed(2)} د.أ',
                Icons.check_circle,
                AppColors.refillGreen,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.5), width: 2)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(icon, color: color, size: 50)),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)), child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: AppColors.plumberRed)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.plumberRed), child: const Text('حسناً', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('حسابي', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]);
  }

  Widget _buildProfileSection() {
    return Consumer<ProfileManager>(
      builder: (context, profile, child) {
        return Row(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldLight, width: 3),
                boxShadow: [BoxShadow(color: AppColors.goldLight.withValues(alpha: 0.5), blurRadius: 15)],
              ),
              child: CircleAvatar(
                radius: 37,
                backgroundColor: const Color(0xFF1A1F2E),
                backgroundImage: profile.imageFile != null ? FileImage(profile.imageFile!) : null,
                child: profile.imageFile == null ? const Icon(Icons.person, color: Colors.white, size: 40) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name.isNotEmpty ? profile.name : 'قاسم أبو البراء', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('🇯🇴', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(profile.email.isNotEmpty ? profile.email : 'عميل مميز في قطوره', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.crystalBlue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.5))),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified, color: AppColors.crystalBlue, size: 14), SizedBox(width: 4), Text('عميل موثق ومحمي', style: TextStyle(color: AppColors.crystalBlue, fontSize: 11, fontWeight: FontWeight.bold))]),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDigitalIdCard() {
    return Consumer<ProfileManager>(
      builder: (context, profile, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF1E3A8A).withValues(alpha: 0.8), const Color(0xFF3B82F6).withValues(alpha: 0.4)]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5), width: 2),
            boxShadow: [BoxShadow(color: AppColors.goldLight.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 3)],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: profile.imageFile != null ? DecorationImage(image: FileImage(profile.imageFile!), fit: BoxFit.cover) : null,
                  color: profile.imageFile == null ? Colors.white.withValues(alpha: 0.1) : null,
                ),
                child: profile.imageFile == null ? const Icon(Icons.person, color: Colors.white, size: 40) : null,
              ),
              const SizedBox(height: 16),
              Text(profile.name.isNotEmpty ? profile.name : 'QASIM ABU AL-BARA', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)), child: const Text('ID: 8B-2024-JO', style: TextStyle(color: AppColors.goldLight, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('النقاط', style: TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 4), Text('$_currentPoints نقطة', style: const TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold))]),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.goldLight, width: 2)),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              const Text('امسح هذا الكود', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              QrImageView(data: 'QATORAH|CUST-1001|QASIM', version: QrVersions.auto, size: 250.0, backgroundColor: Colors.white),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pop(dialogContext),
                                icon: const Icon(Icons.close),
                                label: const Text('إغلاق'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A)),
                              )
                            ]),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.goldLight, width: 2)),
                      child: QrImageView(data: 'QATORAH|CUST-1001|QASIM', version: QrVersions.auto, size: 80.0, backgroundColor: Colors.white),
                    ),
                  ),
                  const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('الرتبة', style: TextStyle(color: Colors.white70, fontSize: 12)), SizedBox(height: 4), Text('عميل ذهبي', style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold))]),
                ],
              ),
              const SizedBox(height: 8),
              const Text('اضغط على الكود لتكبيره', style: TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E).withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.refillGreen.withValues(alpha: 0.4))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الرصيد المتبقي', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text('${_currentBalance.toStringAsFixed(2)} د.أ', style: const TextStyle(color: AppColors.refillGreen, fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.refillGreen.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet, color: AppColors.refillGreen, size: 28)),
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      _statBox('98%', 'التقييم', Icons.star, AppColors.goldLight),
      const SizedBox(width: 12),
      _statBox('12', 'طلب منفذ', Icons.check_circle, AppColors.refillGreen),
      const SizedBox(width: 12),
      _statBox('48', 'ساعة توفير', Icons.timer, AppColors.crystalBlue),
    ]);
  }

  Widget _buildServiceOption({required IconData icon, required String title, required String subtitle, required Color color, required String price, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF1A1F2E).withValues(alpha: 0.6), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11))])),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(price, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: color)), child: Icon(icon, color: color, size: 24)));
  }

  Widget _calcRow(String label, String value, Color color, {bool isTotal = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: isTotal ? 15 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
      Text(value, style: TextStyle(color: color, fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _pointsBox(String label, String value, Color color) {
    return Column(children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 4), Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))]);
  }

  Widget _statBox(String value, String label, IconData icon, Color color) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: const Color(0xFF1A1F2E).withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.4))), child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 8), Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))])));
  }
}