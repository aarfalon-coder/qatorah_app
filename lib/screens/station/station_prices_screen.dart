import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/managers/supplier_manager.dart';
import 'package:qatorah_app/models/water_catalog.dart';

class StationPricesScreen extends StatefulWidget {
  const StationPricesScreen({super.key});
  @override
  State<StationPricesScreen> createState() => _StationPricesScreenState();
}

class _StationPricesScreenState extends State<StationPricesScreen> {
  late final WaterStation _myStation;
  final Map<String, TextEditingController> _ctrls = {};
  late final TextEditingController _deliveryCtrl;

  @override
  void initState() {
    super.initState();
    _myStation = SupplierManager.stations.first;
    for (final p in WaterCatalog.products) {
      _ctrls[p.id] = TextEditingController(
          text: SupplierManager.priceAt(_myStation, p.id).toStringAsFixed(2));
    }
    _deliveryCtrl =
        TextEditingController(text: _myStation.deliveryFee.toStringAsFixed(2));
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _deliveryCtrl.dispose();
    super.dispose();
  }

  void _save() {
    _ctrls.forEach((id, ctrl) {
      final v = double.tryParse(ctrl.text);
      if (v != null && v > 0) _myStation.prices[id] = v;
    });
    final d = double.tryParse(_deliveryCtrl.text);
    if (d != null && d >= 0) _myStation.deliveryFee = d;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('✅ تم حفظ الأسعار - ظهرت للزبائن مباشرة'),
          backgroundColor: AppColors.refillGreen,
          behavior: SnackBarBehavior.floating),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أسعار محطتي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.goldDark.withValues(alpha: 0.25),
                    AppColors.goldDark.withValues(alpha: 0.05)
                  ]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.goldLight.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store,
                        color: AppColors.goldLight, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_myStation.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 3),
                          const Text('عدّل أسعارك - تظهر للزبائن فور الحفظ',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.crystalBlue.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping,
                        color: AppColors.crystalBlue, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                        child: Text('رسوم التوصيل',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold))),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _deliveryCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.crystalBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          suffixText: 'د.أ',
                          suffixStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.15))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: AppColors.crystalBlue)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              for (final p in WaterCatalog.products) _priceRow(p),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.goldDark, AppColors.goldLight]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('حفظ الأسعار',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(WaterProduct p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(p.icon, color: p.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text(p.unit,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 10)),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _ctrls[p.id],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                suffixText: 'د.أ',
                suffixStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.goldLight)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
