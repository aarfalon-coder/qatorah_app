import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qatorah_app/models/region_model.dart';
import 'package:qatorah_app/screens/marketplace/ad_details_screen.dart';
import 'package:qatorah_app/screens/marketplace/add_machine_listing.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedTab = 0; // 0: معروض للبيع, 1: مطلوب للشراء
  Governorate? _selectedGov;

  // 🎨 لوحة الألوان - مشمشي مطفي مريح للعين
  static const Color apricotBg = Color(0xFFFDEBD0); // مشمشي مطفي هادئ (خلفية)
  static const Color deepBlue = Color(0xFF1E3A5F); // أزرق غامق للبطاقات
  static const Color royalBurgundy = Color(0xFF8A1C36); // بيرغندي للإطارات
  static const Color goldAccent = Color(0xFFD4AF37); // ذهبي للأسعار
  static const Color lightApricot = Color(0xFFFFF5E6); // مشمشي فاتح جداً للتفاصيل

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: apricotBg, // ✅ مشمشي مطفي مريح
      appBar: AppBar(
        backgroundColor: apricotBg,
        elevation: 0,
        title: const Text('سوق قطوره', style: TextStyle(color: royalBurgundy, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Tajawal')),
        iconTheme: const IconThemeData(color: royalBurgundy),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: deepBlue, size: 30),
            tooltip: 'إضافة إعلان جديد',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMachineListing()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. أزرار التبويب
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: lightApricot,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: royalBurgundy.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton(0, 'معروض للبيع', Icons.storefront)),
                Expanded(child: _buildTabButton(1, 'مطلوب للشراء', Icons.shopping_cart_checkout)),
              ],
            ),
          ),

          // 2. فلتر المحافظة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildGovFilter(),
          ),
          const SizedBox(height: 16),

          // 3. قائمة الإعلانات
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('marketplace_ads')
                  .where('type', isEqualTo: _selectedTab == 0 ? 'for_sale' : 'wanted')
                  .where('status', isEqualTo: 'active')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: royalBurgundy));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 70, color: royalBurgundy.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          _selectedTab == 0 ? 'لا توجد معروضات حالياً' : 'لا توجد طلبات شراء حالياً',
                          style: const TextStyle(color: deepBlue, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                var ads = snapshot.data!.docs;
                if (_selectedGov != null) {
                  ads = ads.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['governorate'] == _selectedGov!.displayName;
                  }).toList();
                }

                if (ads.isEmpty) {
                  return Center(
                    child: Text('لا توجد إعلانات في هذه المحافظة', style: TextStyle(color: deepBlue.withValues(alpha: 0.7))),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final doc = ads[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildAdCard(context, doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? deepBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? royalBurgundy : deepBlue.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: royalBurgundy.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))] 
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : deepBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : deepBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: lightApricot,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: royalBurgundy.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [BoxShadow(color: deepBlue.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Governorate?>(
          value: _selectedGov,
          isExpanded: true,
          dropdownColor: lightApricot,
          style: const TextStyle(color: deepBlue, fontSize: 14, fontWeight: FontWeight.bold),
          icon: const Icon(Icons.expand_more, color: royalBurgundy),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Row(children: [Icon(Icons.public, size: 16, color: royalBurgundy), SizedBox(width: 8), Text('كل المحافظات', style: TextStyle(fontWeight: FontWeight.bold))]),
            ),
            ...Governorate.values.map((g) => DropdownMenuItem(value: g, child: Text(g.displayName, style: const TextStyle(fontWeight: FontWeight.bold)))),
          ],
          onChanged: (v) => setState(() => _selectedGov = v),
        ),
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, String adId, Map<String, dynamic> data) {
    final List<dynamic> images = data['images'] ?? [];
    final String imageUrl = images.isNotEmpty ? images.first : '';
    final bool isGuaranteed = data['isGuaranteed'] ?? false;
    final int views = data['views'] ?? 0;
    final int likes = data['likes'] ?? 0;
    final String price = data['price'] != null ? '${data['price']} د.أ' : 'قابل للتفاوض';

    return GestureDetector(
      onTap: () {
        FirebaseFirestore.instance.collection('marketplace_ads').doc(adId).update({'views': FieldValue.increment(1)});
        Navigator.push(context, MaterialPageRoute(builder: (_) => AdDetailsScreen(adId: adId, initialData: data)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: deepBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: royalBurgundy, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: royalBurgundy.withValues(alpha: 0.2), 
              blurRadius: 8, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: goldAccent))),
                          errorWidget: (context, url, error) => Container(height: 180, color: Colors.grey.shade800, child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 40)),
                        )
                      : Container(height: 180, color: Colors.grey.shade800, child: const Icon(Icons.image, color: Colors.white54, size: 40)),
                  
                  if (isGuaranteed)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: apricotBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: goldAccent, width: 1.5),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user, color: royalBurgundy, size: 16),
                            SizedBox(width: 4),
                            Text('كفالة قطوره', style: TextStyle(color: royalBurgundy, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: royalBurgundy, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('${images.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'بدون عنوان',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(color: goldAccent, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['description'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(data['governorate'] ?? 'الأردن', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.visibility, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text('$views', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.favorite_border, size: 14, color: apricotBg),
                          const SizedBox(width: 4),
                          Text('$likes', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}