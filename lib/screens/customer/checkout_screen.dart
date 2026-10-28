import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/managers/auth_manager.dart';
import 'package:qatorah_app/managers/cart_manager.dart';
import 'package:qatorah_app/managers/providers_router.dart';
import 'package:qatorah_app/models/order_model.dart';
import 'package:qatorah_app/screens/customer/customer_qr_screen.dart';
import 'package:qatorah_app/services/location_service.dart';
import 'package:qatorah_app/services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedStationId;
  bool _isProcessing = false;
  
  String _selectedAddress = 'لم يتم تحديد الموقع بعد';
  double _latitude = 0.0;
  double _longitude = 0.0;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectLocation() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0A0E1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'اختر موقع التوصيل',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _locationOption(Icons.home, 'العناوين المحفوظة (البيت/الشغل)', () {
              Navigator.pop(modalCtx);
              setState(() {
                _selectedAddress = 'البيت - إربد، شارع الجامعة';
                _latitude = 32.5556;
                _longitude = 35.8500;
              });
            }),
            const SizedBox(height: 12),
            _locationOption(Icons.my_location, 'موقعي الحالي (GPS)', () async {
              Navigator.pop(modalCtx);
              try {
                Position pos = await LocationService.getCurrentPosition();
                String addr = await LocationService.getAddressFromCoordinates(
                  pos.latitude,
                  pos.longitude,
                );
                if (!mounted) return;
                setState(() {
                  _selectedAddress = addr;
                  _latitude = pos.latitude;
                  _longitude = pos.longitude;
                });
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تعذر الحصول على الموقع')),
                );
              }
            }),
            const SizedBox(height: 12),
            _locationOption(Icons.map, 'اختيار من الخريطة', () {
              Navigator.pop(modalCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم فتح شاشة الخريطة قريباً')),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _locationOption(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.navyDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.goldDark.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.crystalBlue, size: 24),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _confirmOrder() async {
    if (_selectedAddress == 'لم يتم تحديد الموقع بعد') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد موقع التوصيل أولاً'),
          backgroundColor: AppColors.plumberRed,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final newOrder = OrderModel(
        id: '',
        customerId: AuthManager.firebaseUid ?? 'guest_user',
        customerName: AuthManager.firstName.isNotEmpty ? AuthManager.firstName : 'عميل قطورة',
        customerPhone: AuthManager.phone.isNotEmpty ? AuthManager.phone : '0790000000',
        serviceType: 'water',
        details: {
          'items': CartManager.items
              .map((e) => {'name': e.name, 'qty': e.quantity, 'total': e.total})
              .toList(),
          'selectedStationId': _selectedStationId ?? 'auto_routed',
        },
        latitude: _latitude,
        longitude: _longitude,
        address: _selectedAddress,
        locationLabel: 'موقع مخصص',
        notes: _notesCtrl.text.trim(),
        timestamp: DateTime.now(),
      );

      final orderId = await OrderService.createOrder(newOrder);

      if (!mounted) return;

      CartManager.clear();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F2E),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.refillGreen),
              SizedBox(width: 10),
              Text('تم إرسال الطلب!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'طلبك في الطريق إلى المزود.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Text(
                'رقم الطلب: ${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length)}...',
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'احتفظ بكود الدفع (QR) لعرضه للمزود عند التسليم.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Future.microtask(() {
                  if (!mounted) return;
                  Navigator.popUntil(context, (route) => route.isFirst);
                });
              },
              child: const Text('لاحقاً', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => const CustomerQrScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code, size: 20),
              label: const Text('عرض كود الدفع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.refillGreen,
              ),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ حدث خطأ أثناء حفظ الطلب: $e'),
          backgroundColor: AppColors.plumberRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligibleStations = ProvidersRouter.eligibleStations();
    final items = CartManager.items;
    final total = items.fold<double>(0, (sum, item) => sum + item.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تأكيد الطلب',
          style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: _isProcessing
              ? const Center(child: CircularProgressIndicator(color: AppColors.goldLight))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملخص الطلب',
                        style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      GlassCard(
                        glowColor: AppColors.crystalBlue,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Text(
                                'عدد الأصناف: ${CartManager.totalItems}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'الإجمالي: ${total.toStringAsFixed(2)} دينار',
                                style: const TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      const Text(
                        'موقع التوصيل',
                        style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      GlassCard(
                        glowColor: AppColors.crystalBlue,
                        child: ListTile(
                          leading: const Icon(Icons.location_on, color: AppColors.crystalBlue),
                          title: Text(
                            _selectedAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          subtitle: const Text(
                            'اضغط لتغيير الموقع',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.edit, color: AppColors.goldLight, size: 20),
                          onTap: _selectLocation,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'ملاحظات للسائق (اختياري)',
                        style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'مثال: اترك الطلب عند الباب، أو اتصل قبل الوصول',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: AppColors.navyDark.withValues(alpha: 0.5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.goldDark.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      const Text(
                        'طريقة توجيه المزود',
                        style: TextStyle(color: AppColors.goldLight, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => setState(() => _selectedStationId = null),
                        child: _buildOptionCard(
                          isSelected: _selectedStationId == null,
                          title: '🤖 التطبيق يختار الأقرب (موصى به)',
                          subtitle: 'سيتم توجيه طلبك تلقائياً لأقرب محطة نشطة.',
                        ),
                      ),
                      const SizedBox(height: 15),
                      ...eligibleStations.map((station) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStationId = station.id),
                          child: _buildOptionCard(
                            isSelected: _selectedStationId == station.id,
                            title: '👤 ${station.name}',
                            subtitle: 'المسافة: ${station.distanceKm} كم | التقييم: ⭐ ${station.rating}',
                          ),
                        );
                      }),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _confirmOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldLight,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'تأكيد وإرسال الطلب',
                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required bool isSelected,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.crystalBlue.withValues(alpha: 0.2)
            : AppColors.navyDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.goldLight
              : AppColors.goldDark.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected ? AppColors.goldLight : Colors.white54,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}