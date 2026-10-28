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

class GasScreen extends StatefulWidget {
  const GasScreen({super.key});

  @override
  State<GasScreen> createState() => _GasScreenState();
}

class _GasScreenState extends State<GasScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(32.5556, 35.8500);
  String _currentAddress = 'جاري تحديد موقعك...';
  bool _isLoading = true;
  bool _isRequesting = false;
  bool _driverAssigned = false;

  int _quantity = 1;
  final double _unitPrice = 7.25;
  String _paymentMethod = 'cash';

  // 🆕 بيانات مؤقتة احترافية بدلاً من البيانات الوهمية
  final Map<String, dynamic> _driverData = {
    'name': 'جاري تعيين أقرب مزود...',
    'phone': '---',
    'car': '---',
    'rating': 0.0,
    'distance': 0.0,
    'etaMinutes': 0,
  };

  List<Marker> _truckMarkers = [];
  Timer? _addressDebounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _addressDebounce?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      Position pos = await LocationService.getCurrentPosition();
      String addr = await LocationService.getAddressFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _currentAddress = addr;
        _isLoading = false;
      });
      _generateNearbyTrucks();
    } catch (e) {
      debugPrint('تعذر تحديد الموقع: $e');
      if (!mounted) return;
      setState(() {
        _currentAddress = 'تعذر تحديد الموقع - حرك الخريطة';
        _isLoading = false;
      });
    }
  }

  void _generateNearbyTrucks() {
    _truckMarkers = [
      Marker(
        point: LatLng(_currentLocation.latitude + 0.008,
            _currentLocation.longitude + 0.006),
        width: 40,
        height: 40,
        child: const Icon(Icons.local_shipping,
            color: AppColors.goldLight, size: 35),
      ),
      Marker(
        point: LatLng(_currentLocation.latitude - 0.005,
            _currentLocation.longitude - 0.007),
        width: 40,
        height: 40,
        child: const Icon(Icons.local_shipping,
            color: AppColors.crystalBlue, size: 35),
      ),
    ];
  }

  void _onMapPositionChanged(MapCamera position, bool hasGesture) {
    if (hasGesture) {
      _addressDebounce?.cancel();
      _addressDebounce = Timer(const Duration(milliseconds: 800), () {
        if (!context.mounted) return;
        setState(() {
          _currentLocation = position.center;
          _currentAddress = 'جاري جلب العنوان...';
        });
        LocationService.getAddressFromCoordinates(
          position.center.latitude,
          position.center.longitude,
        ).then((addr) {
          if (context.mounted) {
            setState(() => _currentAddress = addr);
          }
        }).catchError((_) {
          if (mounted) {
            setState(() => _currentAddress = 'موقع محدد على الخريطة');
          }
        });
      });
    }
  }

  double get _totalPrice => _unitPrice * _quantity;

  Future<void> _requestGas() async {
    setState(() => _isRequesting = true);

    try {
      final newOrder = OrderModel(
        id: '',
        // ✅ استخدام بيانات AuthManager الحقيقية مباشرة
        customerId: AuthManager.firebaseUid ?? '',
        customerName:
            AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'عميل',
        customerPhone: AuthManager.phone.isNotEmpty ? AuthManager.phone : '',
        serviceType: 'gas',
        details: {
          'item': 'أسطوانة غاز 12 كغم',
          'quantity': _quantity,
          'unitPrice': _unitPrice,
          'totalPrice': _totalPrice,
          'paymentMethod': _paymentMethod,
        },
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        address: _currentAddress,
        locationLabel: 'موقع GPS',
        notes: 'طلب مباشر من الخريطة',
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
              '✅ تم إرسال طلب الغاز بنجاح! (رقم: ${orderId.substring(0, 8)}...)'),
          backgroundColor: AppColors.refillGreen,
        ),
      );

      // محاكاة تعيين سائق (سيتم استبدالها لاحقاً بـ Stream من Firebase)
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isRequesting = false;
          _driverAssigned = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRequesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ فشل إرسال الطلب: $e'),
          backgroundColor: AppColors.plumberRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('طلب غاز منزلي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.goldLight))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 16.0,
                    onPositionChanged: _onMapPositionChanged,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.qatorah.app',
                    ),
                    MarkerLayer(markers: _truckMarkers),
                  ],
                ),
          if (!_isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_pin,
                      color: AppColors.plumberRed, size: 50),
                  SizedBox(height: 8),
                ],
              ),
            ),
          if (!_isLoading && !_driverAssigned)
            Positioned(
              right: 16,
              bottom: 320,
              child: FloatingActionButton(
                heroTag: 'myLocation',
                backgroundColor: AppColors.crystalBlue,
                onPressed: () async {
                  try {
                    Position pos = await LocationService.getCurrentPosition();
                    String addr =
                        await LocationService.getAddressFromCoordinates(
                            pos.latitude, pos.longitude);
                    if (!mounted) return;
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
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _driverAssigned
                ? _buildDriverAssignedPanel()
                : _buildRequestPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1A),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    color: AppColors.plumberRed, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentAddress,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('عدد الأسطوانات',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppColors.plumberRed),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text('$_quantity',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.refillGreen),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = 'cash'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _paymentMethod == 'cash'
                          ? AppColors.goldLight.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _paymentMethod == 'cash'
                              ? AppColors.goldLight
                              : Colors.transparent),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.money, color: Colors.white70, size: 20),
                        SizedBox(width: 8),
                        Text('كاش',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = 'wallet'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _paymentMethod == 'wallet'
                          ? AppColors.crystalBlue.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _paymentMethod == 'wallet'
                              ? AppColors.crystalBlue
                              : Colors.transparent),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet,
                            color: Colors.white70, size: 20),
                        SizedBox(width: 8),
                        Text('المحفظة',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('أسطوانة غاز 12 كغم',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text('السعر الإجمالي: ${_totalPrice.toStringAsFixed(2)} د.أ',
                      style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.goldLight.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.local_fire_department,
                    color: AppColors.goldLight, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isRequesting ? null : _requestGas,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.refillGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isRequesting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 10),
                          Text('جاري إرسال الطلب...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ])
                  : const Text('تأكيد طلب الغاز',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverAssignedPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1A),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
                color: AppColors.refillGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle, color: AppColors.refillGreen, size: 20),
              SizedBox(width: 8),
              Text('تم قبول الطلب - جاري تعيين المزود',
                  style: TextStyle(
                      color: AppColors.refillGreen,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: AppColors.navyDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldLight, width: 2)),
                child: const Icon(Icons.person,
                    color: AppColors.goldLight, size: 35),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_driverData['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_driverData['car'],
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    if (_driverData['rating'] > 0)
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppColors.goldLight, size: 16),
                          const SizedBox(width: 4),
                          Text('${_driverData['rating']} تقييم',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        ],
                      ),
                  ],
                ),
              ),
              if (_driverData['phone'] != '---')
                IconButton(
                  icon: const Icon(Icons.phone,
                      color: AppColors.refillGreen, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'جاري الاتصال بـ ${_driverData['phone']}...')));
                  },
                ),
            ],
          ),
          if (_driverData['distance'] > 0) ...[
            const Divider(color: Colors.white24, height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoBox(
                    'المسافة', '${_driverData['distance']} كم', Icons.route),
                _infoBox('الوقت المتوقع', '${_driverData['etaMinutes']} دقائق',
                    Icons.access_time),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.crystalBlue, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
