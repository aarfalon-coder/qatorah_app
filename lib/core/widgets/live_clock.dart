import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/services/location_service.dart';

/// شريط الحالة الكريستالي الحي — متحرك + يجلب الموقع الحقيقي
class LiveStatusBar extends StatefulWidget {
  const LiveStatusBar({super.key});

  @override
  State<LiveStatusBar> createState() => _LiveStatusBarState();
}

class _LiveStatusBarState extends State<LiveStatusBar>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  DateTime _now = DateTime.now();

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── بيانات حية (تم تحويلها من static const إلى متغيرات قابلة للتحديث) ──
  String _city = 'جاري تحديد الموقع...';
  final String _tempC = '--';
  double _lat = 0.0;
  double _lng = 0.0;

  static const List<String> _weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  static const List<String> _months = [
    'كانون الثاني',
    'شباط',
    'آذار',
    'نيسان',
    'أيار',
    'حزيران',
    'تموز',
    'آب',
    'أيلول',
    'تشرين الأول',
    'تشرين الثاني',
    'كانون الأول',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.35, end: 0.95).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ✅ جلب الموقع الحقيقي عند بدء التشغيل
    _fetchLiveLocation();
  }

  Future<void> _fetchLiveLocation() async {
    try {
      Position pos = await LocationService.getCurrentPosition();
      String address = await LocationService.getAddressFromCoordinates(
          pos.latitude, pos.longitude);

      if (mounted) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
          // نأخذ آخر جزء من العنوان كاسم مدينة للعرض في الشريط العلوي
          final parts = address.split('، ');
          _city = parts.isNotEmpty ? parts.last : 'الموقع الحالي';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _city = 'الموقع غير متاح';
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _time =>
      '${_now.hour.toString().padLeft(2, '0')}:'
      '${_now.minute.toString().padLeft(2, '0')}:'
      '${_now.second.toString().padLeft(2, '0')}';

  String get _date =>
      '${_weekdays[_now.weekday - 1]}، ${_now.day} '
      '${_months[_now.month - 1]} ${_now.year}';

  void _showDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WeatherDetailsSheet(
        now: _now,
        city: _city,
        lat: _lat,
        lng: _lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ الحل الجذري: HitTestBehavior.opaque لضمان استجابة الضغط
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('✅ تم الضغط على الشريط بنجاح! جاري فتح التفاصيل...');
        _showDetails();
      },
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.crystalBlue.withValues(alpha: 0.35),
                  AppColors.crystalBlue.withValues(alpha: 0.18),
                  AppColors.crystalBlue.withValues(alpha: 0.35),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.crystalBlue.withValues(alpha: _pulseAnim.value),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.crystalBlue
                      .withValues(alpha: _pulseAnim.value * 0.55),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule,
                    color: AppColors.crystalBlue, size: 15),
                const SizedBox(width: 6),
                Text(
                  _time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 14, color: Colors.white24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _date,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.location_on,
                    color: AppColors.crystalBlue, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _city,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.wb_sunny,
                    color: Colors.amberAccent, size: 15),
                const SizedBox(width: 4),
                Text(
                  '$_tempC°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  النافذة المنسدلة (Sheet) بالتفاصيل الموسعة
// ═══════════════════════════════════════════════════
class _WeatherDetailsSheet extends StatefulWidget {
  final DateTime now;
  final String city;
  final double lat;
  final double lng;

  const _WeatherDetailsSheet({
    required this.now,
    required this.city,
    required this.lat,
    required this.lng,
  });

  @override
  State<_WeatherDetailsSheet> createState() => _WeatherDetailsSheetState();
}

class _WeatherDetailsSheetState extends State<_WeatherDetailsSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _isLoadingAddress = true;
  String _fullAddress = 'جاري تحديد العنوان الدقيق...';

  static const List<String> _weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  static const List<String> _months = [
    'كانون الثاني',
    'شباط',
    'آذار',
    'نيسان',
    'أيار',
    'حزيران',
    'تموز',
    'آب',
    'أيلول',
    'تشرين الأول',
    'تشرين الثاني',
    'كانون الأول',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();

    // ✅ جلب العنوان التفصيلي الكامل عند فتح النافذة
    _fetchFullAddress();
  }

  Future<void> _fetchFullAddress() async {
    if (widget.lat == 0.0) {
      setState(() {
        _fullAddress = 'تعذر تحديد الموقع. يرجى تفعيل GPS.';
        _isLoadingAddress = false;
      });
      return;
    }
    try {
      String address = await LocationService.getAddressFromCoordinates(
          widget.lat, widget.lng);
      if (mounted) {
        setState(() {
          _fullAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fullAddress = 'تعذر جلب العنوان التفصيلي';
          _isLoadingAddress = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _time =>
      '${widget.now.hour.toString().padLeft(2, '0')}:'
      '${widget.now.minute.toString().padLeft(2, '0')}:'
      '${widget.now.second.toString().padLeft(2, '0')}';

  String get _date =>
      '${_weekdays[widget.now.weekday - 1]}، ${widget.now.day} '
      '${_months[widget.now.month - 1]} ${widget.now.year}';

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navyDark,
                AppColors.royalBlue.withValues(alpha: 0.85),
                AppColors.navyDark,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: const Border(
              top: BorderSide(color: AppColors.crystalBlue, width: 2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مؤشر السحب
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.crystalBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),

              // العنوان
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_circle,
                      color: AppColors.crystalBlue, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'تفاصيل الوقت والطقس',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ═══ الساعة الكبيرة ═══
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.crystalBlue.withValues(alpha: 0.25),
                      AppColors.crystalBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AppColors.crystalBlue.withValues(alpha: 0.6),
                      width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crystalBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'الوقت الحالي',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _time,
                      style: const TextStyle(
                        color: AppColors.crystalBlue,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _date,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ═══ الموقع (ديناميكي الآن) ═══
              _isLoadingAddress
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.crystalBlue)),
                    )
                  : _detailCard(
                      icon: Icons.location_on,
                      color: AppColors.crystalBlue,
                      title: 'الموقع الحالي المباشر',
                      value: widget.city,
                      subtitle: _fullAddress,
                    ),
              const SizedBox(height: 12),

              // ═══ الطقس ═══
              _detailCard(
                icon: Icons.wb_sunny,
                color: Colors.amberAccent,
                title: 'حالة الطقس',
                value: 'مشمس - 24°م',
                subtitle: 'الرطوبة: 45% | سرعة الرياح: 12 كم/س',
              ),
              const SizedBox(height: 25),

              // زر الإغلاق
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.crystalBlue.withValues(alpha: 0.3),
                        AppColors.crystalBlue.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.crystalBlue, width: 1.5),
                  ),
                  child: const Text(
                    'إغلاق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}