import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/splash_ad_model.dart';
import 'package:qatorah_app/services/splash_ad_service.dart';

class CreateSplashAdScreen extends StatefulWidget {
  final SplashAdModel? existingAd;

  const CreateSplashAdScreen({super.key, this.existingAd});

  @override
  State<CreateSplashAdScreen> createState() => _CreateSplashAdScreenState();
}

class _CreateSplashAdScreenState extends State<CreateSplashAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _mediaUrlCtrl = TextEditingController();
  final _advertiserCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _targetUrlCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();

  int _durationSeconds = 5;
  String _mediaType = 'image';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<String> _targetRegions = [];
  List<String> _targetUserTypes = [];
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _availableRegions = [
    'عمان', 'الزرقاء', 'إربد', 'العقبة', 'المفرق',
    'مادبا', 'جرش', 'عجلون', 'الكرك', 'معان', 'الطفيلة', 'البحر الميت',
  ];

  final List<String> _availableUserTypes = ['customer', 'provider'];

  @override
  void initState() {
    super.initState();
    if (widget.existingAd != null) {
      final ad = widget.existingAd!;
      _titleCtrl.text = ad.title;
      _descCtrl.text = ad.description ?? '';
      _mediaUrlCtrl.text = ad.mediaUrl;
      _advertiserCtrl.text = ad.advertiserName;
      _phoneCtrl.text = ad.advertiserPhone;
      _targetUrlCtrl.text = ad.targetUrl ?? '';
      _ctaCtrl.text = ad.callToAction ?? '';
      _durationSeconds = ad.durationSeconds;
      _mediaType = ad.mediaType;
      _startDate = ad.startDate;
      _endDate = ad.endDate;
      _targetRegions = List.from(ad.targetRegions);
      _targetUserTypes = List.from(ad.targetUserTypes);
      _isActive = ad.isActive;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _mediaUrlCtrl.dispose();
    _advertiserCtrl.dispose();
    _phoneCtrl.dispose();
    _targetUrlCtrl.dispose();
    _ctaCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mediaUrlCtrl.text.trim().isEmpty) {
      _showError('أدخل رابط الصورة / الفيديو');
      return;
    }
    if (_targetRegions.isEmpty) {
      _showError('اختر منطقة واحدة على الأقل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = SplashAdService();
      final ad = SplashAdModel(
        id: widget.existingAd?.id ?? '',
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        mediaUrl: _mediaUrlCtrl.text.trim(),
        mediaType: _mediaType,
        durationSeconds: _durationSeconds,
        startDate: _startDate,
        endDate: _endDate,
        targetRegions: _targetRegions,
        targetUserTypes: _targetUserTypes,
        targetUrl: _targetUrlCtrl.text.trim().isEmpty
            ? null
            : _targetUrlCtrl.text.trim(),
        callToAction:
            _ctaCtrl.text.trim().isEmpty ? null : _ctaCtrl.text.trim(),
        isActive: _isActive,
        advertiserName: _advertiserCtrl.text.trim(),
        advertiserPhone: _phoneCtrl.text.trim(),
        createdAt: widget.existingAd?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: AuthManager.firebaseUid ?? 'admin',
      );

      if (widget.existingAd == null) {
        await service.createAd(ad);
      } else {
        await service.updateAd(ad);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingAd == null
              ? '✅ تم إنشاء الإعلان'
              : '✅ تم تحديث الإعلان'),
          backgroundColor: AppColors.refillGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError('فشل الحفظ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.plumberRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0A0A),
        elevation: 0,
        title: Text(
          widget.existingAd == null ? 'إعلان جديد' : 'تعديل الإعلان',
          style: const TextStyle(
              color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('📝 المعلومات الأساسية'),
              _buildField(_titleCtrl, 'عنوان الإعلان', Icons.title),
              const SizedBox(height: 12),
              _buildField(_descCtrl, 'الوصف (اختياري)', Icons.description,
                  maxLines: 3),
              const SizedBox(height: 12),
              _buildField(_advertiserCtrl, 'اسم المعلن', Icons.business),
              const SizedBox(height: 12),
              _buildField(_phoneCtrl, 'رقم الهاتف', Icons.phone,
                  keyboard: TextInputType.phone),

              const SizedBox(height: 24),
              _sectionTitle('🎬 الوسائط'),
              _buildField(_mediaUrlCtrl, 'رابط الصورة / الفيديو', Icons.link),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildChoiceChip(
                      'صورة',
                      _mediaType == 'image',
                      () => setState(() => _mediaType = 'image'),
                      Icons.image,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildChoiceChip(
                      'فيديو',
                      _mediaType == 'video',
                      () => setState(() => _mediaType = 'video'),
                      Icons.videocam,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _sectionTitle('⏰ مدة العرض'),
              Text(
                'المدة: $_durationSeconds ثانية',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Slider(
                value: _durationSeconds.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                activeColor: AppColors.goldLight,
                inactiveColor: Colors.white24,
                label: '$_durationSeconds ث',
                onChanged: (v) =>
                    setState(() => _durationSeconds = v.round()),
              ),

              const SizedBox(height: 24),
              _sectionTitle('📅 فترة العرض'),
              Row(
                children: [
                  Expanded(
                    child: _dateButton(
                      'من',
                      _startDate,
                      (date) => setState(() => _startDate = date),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateButton(
                      'إلى',
                      _endDate,
                      (date) => setState(() => _endDate = date),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _sectionTitle('🎯 الاستهداف'),
              const Text(
                'المناطق (اختر واحدة أو أكثر):',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableRegions.map((region) {
                  final selected = _targetRegions.contains(region);
                  return FilterChip(
                    label: Text(region),
                    selected: selected,
                    selectedColor:
                        AppColors.goldLight.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.goldLight,
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.goldLight
                          : Colors.white70,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFF1A1F2E),
                    side: BorderSide(
                      color: selected
                          ? AppColors.goldLight
                          : Colors.white24,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _targetRegions.add(region);
                        } else {
                          _targetRegions.remove(region);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text(
                'نوع المستخدم:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableUserTypes.map((type) {
                  final selected = _targetUserTypes.contains(type);
                  final label = type == 'customer' ? 'عميل' : 'مزود';
                  return FilterChip(
                    label: Text(label),
                    selected: selected,
                    selectedColor:
                        AppColors.crystalBlue.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.crystalBlue,
                    labelStyle: TextStyle(
                      color: selected
                          ? AppColors.crystalBlue
                          : Colors.white70,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFF1A1F2E),
                    side: BorderSide(
                      color: selected
                          ? AppColors.crystalBlue
                          : Colors.white24,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _targetUserTypes.add(type);
                        } else {
                          _targetUserTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              _sectionTitle('🔗 الإجراء'),
              _buildField(_targetUrlCtrl,
                  'الرابط (WhatsApp / Website / Phone)',
                  Icons.link, keyboard: TextInputType.url),
              const SizedBox(height: 12),
              _buildField(_ctaCtrl, 'نص الزر (مثلاً: اتصل الآن)',
                  Icons.touch_app),

              const SizedBox(height: 24),
              _sectionTitle('📌 الحالة'),
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: const Text(
                  'تفعيل الإعلان فوراً',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                activeThumbColor: AppColors.refillGreen,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading
                      ? 'جاري الحفظ...'
                      : widget.existingAd == null
                          ? 'إنشاء الإعلان'
                          : 'حفظ التعديلات',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldLight,
                  foregroundColor: const Color(0xFF0A0E1A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.goldLight,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.goldLight),
        filled: true,
        fillColor: const Color(0xFF1A1F2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    bool selected,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.goldLight.withValues(alpha: 0.2)
              : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.goldLight : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? AppColors.goldLight : Colors.white54,
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.goldLight : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateButton(
    String label,
    DateTime date,
    ValueChanged<DateTime> onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.goldLight,
                  onPrimary: Color(0xFF0A0E1A),
                  surface: Color(0xFF1A1F2E),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.goldLight,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}