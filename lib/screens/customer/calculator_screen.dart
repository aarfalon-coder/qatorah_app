import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  int _familySize = 4;
  int _litersPerPerson = 3; // لتر يومياً للشرب والطهي
  String _waterQuality = 'normal'; // normal, hard, veryHard
  String _governorate = 'amman';
  bool _hasTank = false;

  // نتائج الحساب
  double _dailyConsumption = 0;
  double _monthlyConsumption = 0;
  String _recommendedFilter = '';
  String _filterCapacity = '';
  double _estimatedCost = 0;
  String _maintenancePeriod = '';
  bool _calculated = false;

  void _calculate() {
    setState(() {
      _dailyConsumption = (_familySize * _litersPerPerson).toDouble();
      _monthlyConsumption = _dailyConsumption * 30;

      // تحديد نوع الفلتر المناسب
      if (_waterQuality == 'veryHard') {
        _recommendedFilter = 'فلتر تناضحي عكسي (RO) 7 مراحل';
        _filterCapacity = '100-150 جالون/يوم';
        _estimatedCost = 180 + (_familySize > 6 ? 50 : 0);
        _maintenancePeriod = '6 أشهر';
      } else if (_waterQuality == 'hard') {
        _recommendedFilter = 'فلتر تناضحي عكسي (RO) 5 مراحل';
        _filterCapacity = '75-100 جالون/يوم';
        _estimatedCost = 120 + (_familySize > 6 ? 30 : 0);
        _maintenancePeriod = '6-8 أشهر';
      } else {
        _recommendedFilter = 'فلتر كربوني نشط 3 مراحل';
        _filterCapacity = '50-75 جالون/يوم';
        _estimatedCost = 65 + (_familySize > 6 ? 20 : 0);
        _maintenancePeriod = '8-12 شهر';
      }

      // تعديل حسب وجود خزان
      if (_hasTank) {
        _estimatedCost += 25; // تكلفة مضخة إضافية
      }

      // تعديل حسب المحافظة (بعض المناطق تحتاج فلاتر أقوى)
      if (_governorate == 'zarqa' || _governorate == 'mafraq') {
        _estimatedCost += 15;
      }

      _calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('حاسبة المياه والفلاتر', 
          style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ بطاقة العنوان ═══
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.waterBlue.withValues(alpha: 0.25),
                    AppColors.waterBlue.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.waterBlue.withValues(alpha: 0.5), width: 2),
              ),
              child: const Column(
                children: [
                  Icon(Icons.calculate, color: AppColors.waterBlue, size: 50),
                  SizedBox(height: 12),
                  Text('احسب احتياجك من المياه', 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), 
                    textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text('أدخل بيانات عائلتك لتحصل على التوصية المناسبة', 
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5), 
                    textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ═══ عدد أفراد العائلة ═══
            const Text('عدد أفراد العائلة', 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppColors.goldLight),
                    onPressed: () => setState(() {
                      if (_familySize > 1) _familySize--;
                      _calculated = false;
                    }),
                  ),
                  Expanded(
                    child: Text('$_familySize شخص', 
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.goldLight),
                    onPressed: () => setState(() {
                      _familySize++;
                      _calculated = false;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ═══ استهلاك الفرد اليومي ═══
            const Text('متوسط الاستهلاك اليومي (لتر/شخص)', 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Slider(
                    value: _litersPerPerson.toDouble(),
                    min: 2,
                    max: 5,
                    divisions: 3,
                    activeColor: AppColors.waterBlue,
                    inactiveColor: AppColors.waterBlue.withValues(alpha: 0.3),
                    label: '$_litersPerPerson لتر',
                    onChanged: (value) {
                      setState(() {
                        _litersPerPerson = value.toInt();
                        _calculated = false;
                      });
                    },
                  ),
                  Text('$_litersPerPerson لتر يومياً للشرب والطهي', 
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ═══ جودة المياه ═══
            const Text('جودة المياه في منطقتك', 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildQualityOption('normal', 'عادية', 'مياه بلدية عادية', Icons.water_drop),
            const SizedBox(height: 8),
            _buildQualityOption('hard', 'عسرة', 'تحتوي على نسبة أملاح عالية', Icons.scuba_diving),
            const SizedBox(height: 8),
            _buildQualityOption('veryHard', 'عسرة جداً', 'تحتاج تنقية متقدمة', Icons.warning),
            const SizedBox(height: 20),

            // ═══ المحافظة ═══
            const Text('المحافظة', 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _governorate,
              dropdownColor: const Color(0xFF1A1F2E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A1F2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.location_on, color: AppColors.goldLight),
              ),
              items: const [
                DropdownMenuItem(value: 'amman', child: Text('عمان')),
                DropdownMenuItem(value: 'zarqa', child: Text('الزرقاء')),
                DropdownMenuItem(value: 'irbid', child: Text('إربد')),
                DropdownMenuItem(value: 'mafraq', child: Text('المفرق')),
                DropdownMenuItem(value: 'balqa', child: Text('البلقاء')),
                DropdownMenuItem(value: 'karak', child: Text('الكرك')),
                DropdownMenuItem(value: 'tafela', child: Text('الطفيلة')),
                DropdownMenuItem(value: 'maan', child: Text('معان')),
                DropdownMenuItem(value: 'aqaba', child: Text('العقبة')),
              ],
              onChanged: (value) {
                setState(() {
                  _governorate = value!;
                  _calculated = false;
                });
              },
            ),
            const SizedBox(height: 20),

            // ═══ وجود خزان مياه ═══
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storage, color: AppColors.waterBlue, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('هل يوجد خزان مياه؟', 
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('يؤثر على تكلفة التركيب', 
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _hasTank,
                    onChanged: (value) {
                      setState(() {
                        _hasTank = value;
                        _calculated = false;
                      });
                    },
                    activeThumbColor: AppColors.waterBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ═══ زر الحساب ═══
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate, size: 22),
                label: const Text('احسب الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.waterBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ═══ النتائج ═══
            if (_calculated) ...[
              const Text('نتائج التوصية', 
                style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // البطاقة الرئيسية
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.goldLight.withValues(alpha: 0.2),
                      AppColors.goldLight.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5), width: 2),
                ),
                child: Column(
                  children: [
                    _resultRow('الاستهلاك اليومي', '${_dailyConsumption.toStringAsFixed(0)} لتر', Icons.water_drop),
                    const Divider(color: Colors.white24, height: 24),
                    _resultRow('الاستهلاك الشهري', '${_monthlyConsumption.toStringAsFixed(0)} لتر', Icons.calendar_today),
                    const Divider(color: Colors.white24, height: 24),
                    _resultRow('نوع الفلتر', _recommendedFilter, Icons.filter_list),
                    const Divider(color: Colors.white24, height: 24),
                    _resultRow('طاقة التنقية', _filterCapacity, Icons.speed),
                    const Divider(color: Colors.white24, height: 24),
                    _resultRow('الصيانة الدورية', _maintenancePeriod, Icons.build),
                    const Divider(color: Colors.white24, height: 24),
                    _resultRow('التكلفة التقريبية', '${_estimatedCost.toStringAsFixed(0)} د.أ', Icons.attach_money, isPrice: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ═══ ملاحظات ═══
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.crystalBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.crystalBlue, size: 20),
                        SizedBox(width: 8),
                        Text('ملاحظات هامة', 
                          style: TextStyle(color: AppColors.crystalBlue, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text('• الأسعار تشمل التركيب المجاني', 
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6)),
                    Text('• الضمان لمدة سنة كاملة على الفلتر', 
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6)),
                    Text('• قد تختلف الأسعار حسب الموقع الدقيق', 
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6)),
                    Text('• صيانة مجانية خلال فترة الضمان', 
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ══ زر الطلب ═══
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // هنا يمكن توجيه المستخدم لشاشة الطلب
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔄 جاري تحويلك لصفحة الطلب...'),
                        backgroundColor: AppColors.refillGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart, size: 22),
                  label: const Text('طلب هذا الفلتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.refillGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(String value, String title, String subtitle, IconData icon) {
    final isSelected = _waterQuality == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _waterQuality = value;
          _calculated = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.waterBlue.withValues(alpha: 0.2) : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.waterBlue : AppColors.goldLight.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.waterBlue.withValues(alpha: 0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, 
                color: isSelected ? AppColors.waterBlue : Colors.white54, 
                size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, 
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70, 
                      fontSize: 14, 
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                  Text(subtitle, 
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.white54, 
                      fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.waterBlue, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, IconData icon, {bool isPrice = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.goldLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.goldLight, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, 
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        Text(value, 
          style: TextStyle(
            color: isPrice ? AppColors.refillGreen : Colors.white, 
            fontSize: isPrice ? 18 : 14, 
            fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}