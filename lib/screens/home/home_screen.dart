import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/ads/ad_carousel_widget.dart';
import 'package:qatorah_app/managers/advertisement_manager.dart';
import 'package:qatorah_app/models/advertisement_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قطوره',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              // لاحقاً: الملف الشخصي أو تبديل الدور
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Consumer<AdvertisementManager>(
            builder: (context, mgr, _) {
              if (mgr.isLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.goldLight));
              }

              // 1. فلتر إعلانات قطوره (كل المملكة)
              final qatorahAds = mgr.allAds
                  .where((a) => a.type == AdType.qatorah && a.isDisplayable)
                  .toList();

              // 2. فلتر إعلانات البريميوم (المحافظات)
              final premiumAds = mgr.allAds
                  .where((a) => a.type == AdType.premium && a.isDisplayable)
                  .toList();

              // 3. فلتر الإعلانات المجانية (للسوق)
              final freeAds = mgr.allAds
                  .where((a) => a.type == AdType.free && a.isDisplayable)
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً بك في قطوره 👋',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اختر الخدمة التي تحتاجها، وسنوصلك بأقرب مقدم خدمة.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // ═══ الشريط العلوي: إعلانات قطوره ═══
                    if (qatorahAds.isNotEmpty) ...[
                      AdCarouselWidget(
                        ads: qatorahAds,
                        title: '🏢 إعلانات قطوره (كل المملكة)',
                        accentColor: AppColors.crystalBlue,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ═══ الشريط الأوسط: إعلانات البريميوم ═══
                    if (premiumAds.isNotEmpty) ...[
                      AdCarouselWidget(
                        ads: premiumAds,
                        title: '⭐ إعلانات مميزة (بريميوم)',
                        accentColor: AppColors.goldLight,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ═══ شبكة الخدمات الأساسية ═══
                    const Text(
                      'خدماتنا الأساسية',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true, // مهم جداً داخل SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // منع التمرير الداخلي
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildServiceCard(context, '🚰 مياه', 'طلب مياه من محطة أو مصنع', 'water'),
                        _buildServiceCard(context, '🔧 صيانة', 'سباك أو كهربائي أو فني', 'maintenance'),
                        _buildServiceCard(context, '🚛 تنك مياه', 'طلب تنك مياه متنقل', 'tanker'),
                        _buildServiceCard(context, '🔥 غاز', 'طلب أسطوانة غاز للمنزل', 'gas'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ═══ خانة السوق: الإعلانات المجانية ═══
                    const Text(
                      '🛒 السوق (خدمات مجانية)',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (freeAds.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'لا توجد إعلانات مجانية متاحة حالياً',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      )
                    else
                      ...freeAds.map((ad) => _buildFreeAdCard(ad)),

                    const SizedBox(height: 80), // مساحة فارغة في الأسفل عشان الشريط السفلي ما يغطي آخر عنصر
                  ],
                ),
              );
            },
          ),
        ),
      ),
      // شريط سفلي لمقدمي الخدمة (يظهر فقط إذا كان المستخدم مقدم خدمة)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D1430),
        selectedItemColor: AppColors.goldLight,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store), label: 'لوحة عملي'), // لمقدمي الخدمة فقط
        ],
        onTap: (index) {
          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('سيتم فتح لوحة تحكم مقدم الخدمة')),
            );
            // لاحقاً: Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderHomeScreen()));
          }
        },
      ),
    );
  }

  // ═══ ودجت بطاقة الخدمة الأساسية ═══
  Widget _buildServiceCard(
      BuildContext context, String title, String subtitle, String serviceType) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('جاري البحث عن أقرب $title...')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ ودجت بطاقة الإعلان المجاني في السوق ═══
  Widget _buildFreeAdCard(AdvertisementModel ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(ad.category.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ad.title,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.crystalBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'مجاني',
                  style: TextStyle(color: AppColors.crystalBlue, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ad.description,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(ad.region.displayName, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const Spacer(),
              Text('${ad.remainingDays} يوم متبقي', style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}