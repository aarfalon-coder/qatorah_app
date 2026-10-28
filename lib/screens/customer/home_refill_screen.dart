import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/services/location_service.dart';
import 'supplier_selection_screen.dart';

class HomeRefillScreen extends StatefulWidget {
  // ✅ جعلنا cartItems اختيارياً لتجنب الأخطاء في الشاشات الأخرى
  final Map<String, int> cartItems;
  const HomeRefillScreen({super.key, this.cartItems = const {}});

  @override
  State<HomeRefillScreen> createState() => _HomeRefillScreenState();
}

class _HomeRefillScreenState extends State<HomeRefillScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(32.5556, 35.8500);
  String _currentAddress = 'جاري تحديد موقعك...';
  bool _isLoading = true;
  Timer? _addressDebounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
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
    } catch (e) {
      setState(() {
        _currentAddress = 'تعذر تحديد الموقع - يرجى تحريك الخريطة';
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final totalItems = widget.cartItems.values.fold(0, (a, b) => a + b);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('موقع التوصيل',
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
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.waterBlue))
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
                  ],
                ),
          if (!_isLoading)
            Positioned(
              top: screenHeight * 0.35,
              left: 0,
              right: 0,
              child: const Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.location_pin,
                        color: AppColors.plumberRed, size: 65),
                    Icon(Icons.circle, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
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
          if (!_isLoading)
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.25,
              maxChildSize: 0.75,
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
                      Center(
                          child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swipe_up,
                                color: AppColors.waterBlue, size: 20),
                            SizedBox(width: 6),
                            Text('اسحب للأعلى لمراجعة الطلب',
                                style: TextStyle(
                                    color: AppColors.waterBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.goldLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.goldLight
                                    .withValues(alpha: 0.3))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الأصناف المختارة:',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            Text('$totalItems صنف',
                                style: const TextStyle(
                                    color: AppColors.goldLight,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SupplierSelectionScreen(
                                  cartItems: widget
                                      .cartItems, // ✅ تمرير البيانات بشكل صحيح
                                  latitude: _currentLocation.latitude,
                                  longitude: _currentLocation.longitude,
                                  address: _currentAddress,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.store, color: Colors.black),
                          label: const Text(
                              'البحث عن المحطات القريبة وتأكيد الطلب',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.waterBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
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
}
