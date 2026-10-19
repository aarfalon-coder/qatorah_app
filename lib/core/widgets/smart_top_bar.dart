import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:qatorah_app/services/location_service.dart';
import 'package:qatorah_app/services/weather_service.dart';

class SmartTopBar extends StatefulWidget {
  const SmartTopBar({super.key});

  @override
  State<SmartTopBar> createState() => _SmartTopBarState();
}

class _SmartTopBarState extends State<SmartTopBar> {
  String _time = '--:--';
  String _fullLocation = 'جاري تحديد الموقع...';
  String _shortLocation = 'الموقع';
  String _weatherDesc = '...';
  String _temp = '--°C';
  String _humidity = '--%';
  String _wind = '-- كم/س';

  double _lat = 0.0;
  double _lng = 0.0;

  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _startClock();
    _fetchRealData();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchRealData();
    });
  }

  void _startClock() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final now = DateTime.now();
      final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.hour >= 12 ? 'م' : 'ص';
      setState(() {
        _time = '$hour:$minute $period';
      });
    });
  }

  Future<void> _fetchRealData() async {
    try {
      Position position = await LocationService.getCurrentPosition();
      String address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Weather? weather = await WeatherService.getCurrentWeather(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
          _fullLocation = address;
          // ✅ أخذ أول جزأين فقط (الشارع والحي) بدون تكرار
          final parts = address.split('،').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          _shortLocation = parts.length >= 2 ? '${parts[0]}، ${parts[1]}' : (parts.isNotEmpty ? parts[0] : 'الموقع');
          _weatherDesc = weather?.weatherDescription ?? 'صافٍ';
          _temp = '${weather?.temperature?.celsius?.toStringAsFixed(0) ?? '--'}°C';
          _humidity = '${weather?.humidity?.toStringAsFixed(0) ?? '--'}%';
          _wind = '${weather?.windSpeed?.toStringAsFixed(0) ?? '--'} كم/س';
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحديث الموقع: $e');
    }
  }

  void _showDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetailsSheet(
        time: _time,
        fullLocation: _fullLocation,
        temp: _temp,
        weatherDesc: _weatherDesc,
        humidity: _humidity,
        wind: _wind,
      ),
    );
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('✅ تم الضغط على الشريط!');
        _showDetails();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: InfiniteMarquee(
                duration: const Duration(seconds: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 25),

                    const Icon(Icons.location_on, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _shortLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 25),

                    const Icon(Icons.wb_sunny, color: Colors.amber, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '$_temp - $_weatherDesc',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 25),

                    const Icon(Icons.water_drop, color: Colors.blue, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'الرطوبة: $_humidity',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 25),

                    const Icon(Icons.air, color: Colors.teal, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'الرياح: $_wind',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  ويدجت Marquee دائري حقيقي
// ═══════════════════════════════════════════════════
class InfiniteMarquee extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const InfiniteMarquee({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 12),
  });

  @override
  State<InfiniteMarquee> createState() => _InfiniteMarqueeState();
}

class _InfiniteMarqueeState extends State<InfiniteMarquee> with SingleTickerProviderStateMixin {
  final GlobalKey _contentKey = GlobalKey();
  late AnimationController _controller;
  double _contentWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          setState(() {
            _contentWidth = renderBox.size.width;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // ✅ الحل الجذري: OverflowBox بيمنع الـ Row من عمل Overflow أثناء الحركة
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        maxWidth: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-_contentWidth * _controller.value, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KeyedSubtree(key: _contentKey, child: widget.child),
                  widget.child,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  النافذة المنبثقة
// ═══════════════════════════════════════════════════
class _DetailsSheet extends StatelessWidget {
  final String time;
  final String fullLocation;
  final String temp;
  final String weatherDesc;
  final String humidity;
  final String wind;

  const _DetailsSheet({
    required this.time,
    required this.fullLocation,
    required this.temp,
    required this.weatherDesc,
    required this.humidity,
    required this.wind,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                fullLocation.isNotEmpty ? fullLocation : 'الموقع الحالي',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                _getArabicDate(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getWeatherIcon(weatherDesc),
                    color: Colors.amber,
                    size: 50,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    temp.isNotEmpty ? temp : '--°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                weatherDesc.isNotEmpty ? weatherDesc : 'غير متوفر',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _detailRow(Icons.thermostat, 'درجة الحرارة', temp.isNotEmpty ? temp : '--'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.water_drop, 'الرطوبة', humidity.isNotEmpty ? humidity : '--'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.air, 'سرعة الرياح', wind.isNotEmpty ? wind : '--'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.explore, 'اتجاه الرياح', 'شمال غربي'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.compress, 'الضغط الجوي', '1013 hPa'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.visibility, 'مدى الرؤية', '10 كم'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.wb_sunny, 'الأشعة فوق البنفسجية', 'متوسط'),
                    const SizedBox(height: 8),
                    _detailRow(Icons.cloud, 'الحالة العامة', weatherDesc.isNotEmpty ? weatherDesc : '--'),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'إغلاق',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String weatherDesc) {
    if (weatherDesc.isEmpty) return Icons.wb_sunny;
    final desc = weatherDesc.toLowerCase();
    if (desc.contains('مطر') || desc.contains('rain')) return Icons.water_drop;
    if (desc.contains('غيوم') || desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('شمس') || desc.contains('clear') || desc.contains('صاف')) return Icons.wb_sunny;
    if (desc.contains('ثلج') || desc.contains('snow')) return Icons.ac_unit;
    return Icons.wb_sunny;
  }

  String _getArabicDate() {
    final now = DateTime.now();
    const weekdays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${weekdays[now.weekday - 1]}، ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}