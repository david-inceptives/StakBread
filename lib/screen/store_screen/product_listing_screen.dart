import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/screen/store_screen/cart_controller.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../../common/widget/custom_app_bar.dart';

class ProductListingScreen extends StatelessWidget {
  final String title;
  final List<StoreProduct> products;

  const ProductListingScreen({
    super.key,
    required this.title,
    required this.products,
  });

  static Color _cardImageTint(int index) {
    switch (index % 3) {
      case 0:
        return const Color(0xFFE8E4F4); // light lavender
      case 1:
        return const Color(0xFFFFF8E7); // light yellow/cream
      case 2:
        return const Color(0xFFFCE8E0); // light coral/peach
      default:
        return ColorRes.borderLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: title,
              titleStyle: TextStyleCustom.unboundedSemiBold600(fontSize: 18, color: ColorRes.textDarkGrey),
              bgColor: const Color(0xFFF5F6F8),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ListingProductCard(
                    product: product,
                    imageTint: _cardImageTint(index),
                    onTap: () => Get.to(() => ProductDetailScreen(product: product)),
                    onAddToCart: () {
                      if (Get.isRegistered<CartController>()) {
                        Get.find<CartController>().addItem(
                          product,
                          quantity: 1,
                          variantText: product.id == '2' ? 'Size: M' : 'Color: Black',
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingProductCard extends StatelessWidget {
  final StoreProduct product;
  final Color imageTint;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _ListingProductCard({
    required this.product,
    required this.imageTint,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = product.imagePath ?? '';
    final rating = product.rating;
    final filledStars = rating.floor();
    final hasHalfStar = (rating - filledStars) >= 0.3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: imageTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imagePath.isNotEmpty
                        ? Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            width: 66,
                            height: 66,
                          )
                        : Icon(Icons.image_outlined, size: 40, color: ColorRes.textLightGrey),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: TextStyleCustom.outFitSemiBold600(fontSize: 15, color: ColorRes.textDarkGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        style: TextStyleCustom.outFitRegular400(fontSize: 10, color: ColorRes.textLightGrey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            if (i < filledStars) {
                              return Icon(Icons.star_rounded, size: 16, color: ColorRes.orange);
                            }
                            if (i == filledStars && hasHalfStar) {
                              return Icon(Icons.star_half_rounded, size: 16, color: ColorRes.orange);
                            }
                            return Icon(Icons.star_outline_rounded, size: 16, color: ColorRes.orange);
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '${product.rating} / 5',
                            style: TextStyleCustom.outFitRegular400(fontSize: 12, color: ColorRes.textDarkGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: ColorRes.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onAddToCart,
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 66,
                      height: 66,
                      child: Center(
                        child: Image.asset(
                          AssetRes.icStoreFill,
                          fit: BoxFit.contain,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
