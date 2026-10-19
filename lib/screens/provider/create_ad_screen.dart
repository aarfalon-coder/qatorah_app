import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_type_badge.dart';
import 'package:qatorah_app/core/widgets/ads/geo_coverage_selector.dart';
import 'package:qatorah_app/core/widgets/ads/price_plan_card.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';
import 'package:qatorah_app/models/region_model.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  AdType _type = AdType.free;
  AdCategory _category = AdCategory.water;
  Governorate _governorate = Governorate.irbid;
  AdScope _scope = AdScope.governorate;
  int _days = 7;
  final List<String> _imagePaths = [];
  bool _submitting = false;
  
  final _picker = ImagePicker();

  int get _maxImages => AdLimits.maxImages[_type] ?? 1;
  double get _price => AdPlans.priceFor(_type, _days);
  bool get _isValid => _titleCtrl.text.trim().length >= 3 && _descCtrl.text.trim().length >= 10;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onTypeChanged(AdType newType) {
    setState(() {
      _type = newType;
      if (newType == AdType.free) _days = 7;
      if (_imagePaths.length > _maxImages) {
        _imagePaths.removeRange(_maxImages, _imagePaths.length);
      }
    });
  }

  // ✅ دالة عرض القائمة المنبثقة (كاميرا / معرض)
  Future<void> _pickImages() async {
    if (_imagePaths.length >= _maxImages) {
      _snack('وصلت للحد الأقصى للصور ($_maxImages)');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
                const Text('اختر مصدر الصورة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.goldLight.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: AppColors.goldLight, size: 24)),
                  title: const Text('التقاط صورة بالكاميرا', style: TextStyle(color: Colors.white, fontSize: 15)),
                  subtitle: Text('صورة واحدة فقط', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                  onTap: () { Navigator.pop(sheetContext); _pickFromCamera(); },
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.crystalBlue.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library, color: AppColors.crystalBlue, size: 24)),
                  title: const Text('اختيار من المعرض', style: TextStyle(color: Colors.white, fontSize: 15)),
                  subtitle: Text('يمكنك اختيار عدة صور (حتى $_maxImages)', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                  onTap: () { Navigator.pop(sheetContext); _pickFromGallery(); },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ دالة الكاميرا
  Future<void> _pickFromCamera() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
      if (picked != null && mounted) {
        setState(() { if (_imagePaths.length < _maxImages) _imagePaths.add(picked.path); });
      }
    } catch (e) { if (mounted) _snack('تعذر فتح الكاميرا'); }
  }

  // ✅ دالة المعرض
  Future<void> _pickFromGallery() async {
    final remaining = _maxImages - _imagePaths.length;
    if (remaining <= 0) { _snack('وصلت للحد الأقصى ($_maxImages)'); return; }
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 75, maxWidth: 1200);
      if (picked.isNotEmpty && mounted) {
        setState(() {
          for (final f in picked) { if (_imagePaths.length < _maxImages) _imagePaths.add(f.path); }
        });
      }
    } catch (e) { if (mounted) _snack('تعذر فتح المعرض'); }
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  // ✅ دالة النشر
  Future<void> _submit() async {
    if (!_isValid) { _snack('العنوان (3 أحرف+) والوصف (10 أحرف+) مطلوبان'); return; }
    
    final mgr = context.read<AdvertisementManager>();
    if (_type == AdType.free && !mgr.canCreateFree) { 
      _snack('وصلت للحد الشهري (${AdLimits.freeMonthlyLimit} إعلانات مجانية).'); return; 
    }

    setState(() => _submitting = true);
    
    final result = await mgr.createAd(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      images: List.of(_imagePaths),
      category: _category,
      governorate: _governorate,
      type: _type,
      scope: _scope,
      durationDays: _days,
      price: _price,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result == null) { _snack(mgr.error ?? 'حدث خطأ أثناء النشر'); return; }

    final msg = _type == AdType.free
        ? '✅ تم نشر إعلانك المجاني فوراً لمدة $_days أيام'
        : '⏳ تم حجز ${_price.toInt()} د.أ من محفظتك، وإعلانك بانتظار موافقة الإدارة';
        
    _snack(msg, color: AppColors.refillGreen);
    Navigator.pop(context, true);
  }

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color ?? AppColors.navyDark, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text('إنشاء إعلان جديد', style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('1', 'نوع الإعلان'), const SizedBox(height: 12), _buildTypeSelector(), const SizedBox(height: 24),
            _stepTitle('2', 'أضف الصور'), const SizedBox(height: 4),
            Text('الحد الأقصى لهذا النوع: $_maxImages ${_maxImages == 1 ? "صورة" : "صور"}', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
            const SizedBox(height: 12), _buildImageGrid(), const SizedBox(height: 24),
            _stepTitle('3', 'العنوان والوصف'), const SizedBox(height: 12),
            _buildTextField(_titleCtrl, hint: 'مثال: أسطوانات غاز منزلية — توصيل فوري', maxLines: 1), const SizedBox(height: 12),
            _buildTextField(_descCtrl, hint: 'اكتب وصفاً تفصيلياً لخدمتك...', maxLines: 4), const SizedBox(height: 24),
            _stepTitle('4', 'التصنيف'), const SizedBox(height: 12), _buildCategoryChips(), const SizedBox(height: 24),
            _stepTitle('5', 'المنطقة والتغطية'), const SizedBox(height: 12),
            GeoCoverageSelector(selected: _governorate, type: _type, onChanged: (g) => setState(() => _governorate = g)), const SizedBox(height: 24),
            
            // 🆕 الخطوة 6: نطاق الظهور
            _stepTitle('6', 'نطاق الظهور'), const SizedBox(height: 12),
            if (_type == AdType.free)
              _freeScopeNote()
            else
              Row(
                children: [
                  Expanded(child: _buildScopeCard(AdScope.governorate, ' محافظة', 'يظهر في شريط محافظتك فقط')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildScopeCard(AdScope.kingdom, '🌍 كل المملكة', 'يظهر في الشريط العلوي لكل الأردن')),
                ],
              ),
            const SizedBox(height: 24),
            
            _stepTitle('7', 'المدة والباقة'), const SizedBox(height: 12),
            PricePlanCard(type: _type, selectedDays: _days, onChanged: (d) => setState(() => _days = d)), const SizedBox(height: 28),
            _buildSummary(), const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton.icon(
                onPressed: (_submitting || !_isValid) ? null : _submit,
                icon: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.publish),
                label: Text(_submitting ? 'جاري النشر...' : 'نشر الإعلان', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldLight, foregroundColor: const Color(0xFF0A0E1A),
                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ══ عناصر واجهة المستخدم المساعدة ═══

  Widget _stepTitle(String num, String title) {
    return Row(
      children: [
        Container(width: 26, height: 26, decoration: BoxDecoration(color: AppColors.goldLight.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.5))),
          child: Center(child: Text(num, style: const TextStyle(color: AppColors.goldLight, fontSize: 13, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 🆕 بطاقة اختيار النطاق
  Widget _buildScopeCard(AdScope scope, String title, String desc) {
    final selected = _scope == scope;
    final accent = scope == AdScope.kingdom ? AppColors.goldLight : AppColors.crystalBlue;
    return GestureDetector(
      onTap: () => setState(() => _scope = scope),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.18) : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? accent : Colors.white.withValues(alpha: 0.1), width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, height: 1.4)),
          ],
        ),
      ),
    );
  }

  //  ملاحظة للإعلانات المجانية
  Widget _freeScopeNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.crystalBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.crystalBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.crystalBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '🛒 الإعلانات المجانية تظهر في السوق فقط.\nللظهور بالأشرطة المتحركة (محافظة/مملكة) اختر نوع بريميوم ⭐',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(children: [
      Expanded(child: _typeCard(AdType.free, '7 أيام', '0 د.أ', 'منطقتك فقط • صورة واحدة')),
      const SizedBox(width: 12),
      Expanded(child: _typeCard(AdType.premium, 'حسب الباقة', 'من 10 د.أ', 'منطقتك + المجاورة • 3 صور • شريط إعلاني')),
    ]);
  }

  Widget _typeCard(AdType type, String dur, String cost, String perks) {
    final selected = _type == type;
    final accent = type == AdType.free ? AppColors.crystalBlue : AppColors.goldLight;
    return GestureDetector(
      onTap: () => _onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: selected ? accent.withValues(alpha: 0.18) : const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? accent : Colors.white.withValues(alpha: 0.1), width: selected ? 2 : 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AdTypeBadge(type: type, compact: true), const SizedBox(height: 10),
          Text(cost, style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 2),
          Text(dur, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)), const SizedBox(height: 8),
          Text(perks, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, height: 1.4)),
        ]),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: _imagePaths.length + 1,
      itemBuilder: (context, index) {
        if (index == _imagePaths.length) {
          final canAdd = _imagePaths.length < _maxImages;
          return GestureDetector(
            onTap: canAdd ? _pickImages : null,
            child: Container(decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: canAdd ? AppColors.goldLight.withValues(alpha: 0.4) : Colors.white10)),
              child: Icon(canAdd ? Icons.add_a_photo : Icons.lock_outline, color: canAdd ? AppColors.goldLight : Colors.white24, size: 28)),
          );
        }
        return Stack(fit: StackFit.expand, children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_imagePaths[index]), fit: BoxFit.cover)),
          Positioned(top: 4, left: 4, child: GestureDetector(onTap: () => _removeImage(index),
            child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)))),
        ]);
      },
    );
  }

  Widget _buildTextField(TextEditingController ctrl, {required String hint, required int maxLines}) {
    return TextField(
      controller: ctrl, maxLines: maxLines, onChanged: (_) => setState(() {}),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)), filled: true, fillColor: const Color(0xFF1A1F2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.goldLight)),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(spacing: 8, runSpacing: 8, children: AdCategory.values.map((c) {
      final selected = _category == c;
      return GestureDetector(
        onTap: () => setState(() => _category = c),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: selected ? AppColors.goldLight.withValues(alpha: 0.25) : const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(10), border: Border.all(color: selected ? AppColors.goldLight : Colors.white.withValues(alpha: 0.1), width: selected ? 2 : 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(c.emoji, style: const TextStyle(fontSize: 14)), const SizedBox(width: 6),
            Text(c.label, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ]),
        ),
      );
    }).toList());
  }

  Widget _buildSummary() {
    final coverage = Regions.describeCoverage(_governorate, _type.code);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.goldLight.withValues(alpha: 0.12), AppColors.goldLight.withValues(alpha: 0.04)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.3))),
      child: Column(children: [
        _summaryRow('النوع', '${_type.emoji} ${_type.label}'),
        _summaryRow('النطاق', _type == AdType.free ? '🛒 السوق فقط' : '${_scope.emoji} ${_scope.label}'),
        _summaryRow('المدة', '$_days يوم'),
        _summaryRow('التكلفة', _price == 0 ? 'مجاني' : '${_price.toInt()} د.أ', valueColor: _price == 0 ? AppColors.refillGreen : AppColors.goldLight),
        _summaryRow('التغطية', coverage),
        if (_type == AdType.premium) _noteRow('💡 سيتم حجز المبلغ حتى موافقة الإدارة، ويُسترد تلقائياً عند الرفض'),
      ]),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
      Flexible(child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
    ]));
  }

  Widget _noteRow(String text) {
    return Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
      const Icon(Icons.info_outline, color: AppColors.crystalBlue, size: 16),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, height: 1.4))),
    ]));
  }
}