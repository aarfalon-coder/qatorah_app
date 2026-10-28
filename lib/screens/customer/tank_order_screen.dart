import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/models/order_model.dart';
import 'package:qatorah_app/services/location_service.dart';
import 'package:qatorah_app/services/order_service.dart';

class TankOrderScreen extends StatefulWidget {
  const TankOrderScreen({super.key});

  @override
  State<TankOrderScreen> createState() => _TankOrderScreenState();
}

class _TankOrderScreenState extends State<TankOrderScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(32.5556, 35.8500);
  String _currentAddress = 'جاري تحديد موقعك...';
  bool _isLoading = true;
  bool _isRequesting = false;

  String _waterType = 'صالحة للشرب';
  String _tankSize = '6 متر';
  double _tankPrice = 19.0; // 🆕 السعر الافتراضي
  final TextEditingController _notesController = TextEditingController();

  List<Marker> _truckMarkers = [];
  Timer? _addressDebounce;

  //  قائمة التنكات مع الأسعار
  final List<Map<String, dynamic>> _tankOptions = [
    {'size': '3 متر', 'price': 10.0},
    {'size': '4 متر', 'price': 13.0},
    {'size': '6 متر', 'price': 19.0},
    {'size': '8 متر', 'price': 25.0},
    {'size': '10 متر', 'price': 31.0},
    {'size': '20 متر', 'price': 61.0},
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _addressDebounce?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      Position pos = await LocationService.getCurrentPosition();
      String addr = await LocationService.getAddressFromCoordinates(
          pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _currentAddress = addr;
        _isLoading = false;
      });
      _mapController.move(_currentLocation, 16.0);
      _generateNearbyTrucks();
    } catch (e) {
      setState(() {
        _currentAddress = 'تعذر تحديد الموقع - يرجى تحريك الخريطة';
        _isLoading = false;
      });
    }
  }

  void _generateNearbyTrucks() {
    _truckMarkers = [
      Marker(
          point: LatLng(_currentLocation.latitude + 0.01,
              _currentLocation.longitude + 0.008),
          width: 40,
          height: 40,
          child: const Icon(Icons.local_shipping,
              color: AppColors.tankCyan, size: 35)),
      Marker(
          point: LatLng(_currentLocation.latitude - 0.007,
              _currentLocation.longitude - 0.009),
          width: 40,
          height: 40,
          child: const Icon(Icons.local_shipping,
              color: AppColors.crystalBlue, size: 35)),
    ];
  }

  void _onMapPositionChanged(MapCamera position, bool hasGesture) {
    if (hasGesture) {
      _addressDebounce?.cancel();
      _addressDebounce = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _currentLocation = position.center;
          _currentAddress = 'جاري جلب العنوان...';
        });
        LocationService.getAddressFromCoordinates(
                position.center.latitude, position.center.longitude)
            .then((addr) {
          if (mounted) setState(() => _currentAddress = addr);
        }).catchError((_) {
          if (mounted) {
            setState(() => _currentAddress = 'موقع محدد على الخريطة');
          }
        });
      });
    }
  }

  Future<void> _requestTank() async {
    setState(() => _isRequesting = true);
    try {
      final newOrder = OrderModel(
        id: '',
        customerId: AuthManager.firebaseUid ?? 'guest_user',
        customerName: AuthManager.firstName.isNotEmpty
            ? AuthManager.firstName
            : 'عميل قطوره',
        customerPhone:
            AuthManager.phone.isNotEmpty ? AuthManager.phone : '0790000000',
        serviceType: 'water_tank',
        details: {
          'water_type': _waterType,
          'tank_size': _tankSize,
          'tank_price': _tankPrice, // 🆕 حفظ السعر
          'notes': _notesController.text.trim(),
        },
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        address: _currentAddress,
        locationLabel: 'موقع GPS',
        notes: _notesController.text.trim(),
        timestamp: DateTime.now(),
      );

      final orderId = await OrderService.createOrder(newOrder).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('انتهت مهلة الاتصال'),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '✅ تم إرسال طلب التنك بنجاح! (رقم: ${orderId.substring(0, 8)}...)'),
            backgroundColor: AppColors.refillGreen),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('⚠️ فشل إرسال الطلب: $e'),
            backgroundColor: AppColors.plumberRed),
      );
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('طلب تنك مياه',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          // 1️⃣ الخريطة
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.tankCyan))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 16.0,
                      onPositionChanged: _onMapPositionChanged),
                  children: [
                    TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.qatorah.app'),
                    MarkerLayer(markers: _truckMarkers),
                  ],
                ),

          // 2️ الدبوس
          if (!_isLoading)
            Positioned(
              top: screenHeight * 0.35,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: 40,
                        height: 10,
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20))),
                    const Icon(Icons.location_on,
                        color: AppColors.plumberRed, size: 65),
                    const Icon(Icons.circle, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),

          // 3️⃣ زر موقعي
          if (!_isLoading)
            Positioned(
              right: 16,
              top: screenHeight * 0.25,
              child: FloatingActionButton(
                heroTag: 'myLocation',
                mini: true,
                backgroundColor: AppColors.crystalBlue,
                onPressed: () async {
                  try {
                    Position pos = await LocationService.getCurrentPosition();
                    String addr =
                        await LocationService.getAddressFromCoordinates(
                            pos.latitude, pos.longitude);
                    if (!context.mounted) return;
                    setState(() {
                      _currentLocation = LatLng(pos.latitude, pos.longitude);
                      _currentAddress = addr;
                    });
                    _mapController.move(_currentLocation, 16.0);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذر تحديد الموقع')));
                    }
                  }
                },
                child: const Icon(Icons.my_location,
                    color: Colors.white, size: 20),
              ),
            ),

          // 4️⃣ اللوحة السفلية القابلة للسحب
          if (!_isLoading)
            DraggableScrollableSheet(
              initialChildSize: 0.40,
              minChildSize: 0.25,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A0E1A),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 15,
                          offset: Offset(0, -5))
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // مقبض السحب
                      Center(
                        child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.circular(2))),
                      ),
                      const SizedBox(height: 16),

                      // العنوان
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.plumberRed, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_currentAddress,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // تلميح السحب
                      const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swipe_up,
                                color: AppColors.tankCyan, size: 20),
                            SizedBox(width: 6),
                            Text('اسحب للأعلى لإكمال الطلب',
                                style: TextStyle(
                                    color: AppColors.tankCyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🆕 نوع المياه (Chips)
                      const Text('نوع المياه:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildChip(
                            label: '💧 صالحة للشرب',
                            isSelected: _waterType == 'صالحة للشرب',
                            onTap: () =>
                                setState(() => _waterType = 'صالحة للشرب'),
                          ),
                          const SizedBox(width: 8),
                          _buildChip(
                            label: '💧 غير صالحة للشرب',
                            isSelected: _waterType == 'غير صالحة للشرب',
                            onTap: () =>
                                setState(() => _waterType = 'غير صالحة للشرب'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🆕 حجم التنك مع الأسعار (Grid)
                      const Text('اختر حجم التنك:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tankOptions.map((tank) {
                          final size = tank['size'] as String;
                          final price = tank['price'] as double;
                          final isSelected = _tankSize == size;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _tankSize = size;
                                _tankPrice = price;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.tankCyan
                                    : const Color(0xFF1A1F2E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.tankCyan
                                      : AppColors.tankCyan
                                          .withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '$size - $price د.أ',
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.black : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // 🆕 ملخص السعر
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  AppColors.goldLight.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الإجمالي:',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text('$_tankPrice د.أ',
                                style: const TextStyle(
                                    color: AppColors.goldLight,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // الملاحظات
                      const Text('ملاحظات للسائق (اختياري):',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _notesController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'مثال: الرجاء الاتصال قبل الوصول...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF1A1F2E),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // زر الإرسال
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isRequesting ? null : _requestTank,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tankCyan,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: _isRequesting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 2)),
                                      SizedBox(width: 10),
                                      Text('جاري الإرسال...',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold))
                                    ])
                              : Text('تأكيد الطلب - $_tankPrice د.أ',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 🆕 دالة بناء Chip أنيق
  Widget _buildChip(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tankCyan : const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.tankCyan
                  : AppColors.tankCyan.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
