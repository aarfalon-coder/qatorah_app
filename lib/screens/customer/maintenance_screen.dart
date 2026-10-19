import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/models/technician_model.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  TechnicianSpecialty? _selectedSpecialty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedSpecialty == null
              ? 'مركز الصيانة'
              : _selectedSpecialty!.arabicName,
          style: const TextStyle(
              color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        leading: _selectedSpecialty != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.goldLight),
                onPressed: () => setState(() => _selectedSpecialty = null),
              )
            : null,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: _selectedSpecialty == null
              ? _buildSpecialtiesGrid()
              : _buildTechniciansList(),
        ),
      ),
    );
  }

  Widget _buildSpecialtiesGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('اختر نوع الصيانة',
              style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text('فنيون معتمدون ومقيّمون لخدمتك',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: TechnicianSpecialty.values.map((spec) {
                return GlassCard(
                  glowColor: spec.color,
                  onTap: () => setState(() => _selectedSpecialty = spec),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              spec.color.withValues(alpha: 0.5),
                              spec.color.withValues(alpha: 0.2)
                            ]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: spec.color.withValues(alpha: 0.5),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Icon(spec.icon, size: 32, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          spec.arabicName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniciansList() {
    final technicians = TechnicianCatalog.bySpecialty(_selectedSpecialty!);
    if (technicians.isEmpty) {
      return const Center(
          child: Text('لا يوجد فنيون متاحون حالياً',
              style: TextStyle(color: Colors.white70, fontSize: 16)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: technicians.length,
      itemBuilder: (context, index) {
        final t = technicians[index];
        return _buildTechnicianCard(t);
      },
    );
  }

  Widget _buildTechnicianCard(TechnicianModel t) {
    final spec = t.specialty;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          spec.color.withValues(alpha: 0.15),
          spec.color.withValues(alpha: 0.05)
        ]),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: spec.color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: spec.color.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(color: spec.color, width: 2),
              ),
              child: Icon(spec.icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: AppColors.goldLight, size: 16),
                      const SizedBox(width: 4),
                      Text('${t.rating}',
                          style: const TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('(${t.reviewCount} تقييم)',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.white.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text('${t.distanceKm} كم',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                      const SizedBox(width: 10),
                      Icon(t.isAvailable ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: t.isAvailable
                              ? AppColors.refillGreen
                              : AppColors.plumberRed),
                      const SizedBox(width: 4),
                      Text(t.isAvailable ? 'متاح' : 'غير متاح',
                          style: TextStyle(
                              color: t.isAvailable
                                  ? AppColors.refillGreen
                                  : AppColors.plumberRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('الاتصال بـ ${t.name}: ${t.phone}'),
                      backgroundColor: AppColors.refillGreen,
                      behavior: SnackBarBehavior.floating),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.refillGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.refillGreen, width: 1.5),
                ),
                child: const Icon(Icons.phone,
                    color: AppColors.refillGreen, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
