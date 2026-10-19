import 'package:flutter/material.dart';
import 'package:qatorah_app/core/theme/app_theme.dart';
import 'package:qatorah_app/core/widgets/auth_gate.dart';
import 'package:qatorah_app/core/widgets/glass_widgets.dart';
import 'package:qatorah_app/core/widgets/quantity_sheet.dart';
import 'package:qatorah_app/managers/cart_manager.dart';
import 'package:qatorah_app/models/cart_item.dart';
import 'package:qatorah_app/models/product_model.dart';
import 'package:qatorah_app/screens/customer/cart_screen.dart';

class ProductsView extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const ProductsView({super.key, required this.title, required this.products});

  void _addToCart(BuildContext context, ProductModel product) {
    AuthGate.requireAuth(
      context,
      message: 'سجّل دخولك لإضافة ${product.name} إلى السلة 💧',
      action: () async {
        final qty = await QuantitySheet.show(
          context,
          title: product.name,
          subtitle: product.unit,
          icon: product.icon,
          color: product.color,
          unitPrice: product.price,
        );
        if (qty == null || qty < 1) return;

        CartManager.addItem(CartItem(
          name: product.name,
          type: product.category,
          quantity: qty,
          price: product.price,
          color: product.color,
          icon: product.icon,
        ));

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة $qty × ${product.name} إلى السلة 🛒'),
            backgroundColor: AppColors.refillGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
              color: AppColors.goldLight, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.goldLight),
        actions: [
          GestureDetector(
            onTap: () => AuthGate.requireAuth(
              context,
              action: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.shopping_cart,
                      color: AppColors.goldLight, size: 26),
                ),
                if (CartManager.totalItems > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: AppColors.plumberRed, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        CartManager.totalItems.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  _buildCard(context, products[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ProductModel product) {
    return GlassCard(
      glowColor: product.color,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    product.color.withValues(alpha: 0.5),
                    product.color.withValues(alpha: 0.2)
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                    color: product.color.withValues(alpha: 0.7), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: product.color.withValues(alpha: 0.5),
                      blurRadius: 12)
                ],
              ),
              child: Icon(product.icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              product.unit,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${product.price.toStringAsFixed(2)} دينار',
              style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _addToCart(context, product),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: AppGradients.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart,
                        size: 15, color: Colors.black),
                    SizedBox(width: 6),
                    Text(
                      'أضف للسلة',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
