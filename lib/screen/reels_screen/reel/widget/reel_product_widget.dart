import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Product overlay on reel: semi-transparent card with product icon, title, price and cart icon.
/// Uses app colors. Shown on left side of reel; tap opens product or adds to cart.
class ReelProductWidget extends StatelessWidget {
  final ReelController controller;

  /// Optional product for opening product detail. If null, resolved from [productId] via store.
  final StoreProduct? product;

  /// Optional product title from API (e.g. from Post.reelProductTitle). If null, placeholder is used.
  final String? productTitle;

  /// Optional price from API (e.g. from Post.reelProductPrice). If null, placeholder is used.
  final String? productPrice;

  /// Optional image path or URL. If null, gift icon is used.
  final String? productImagePath;

  /// Optional product id for navigation to product detail when [product] is null.
  final String? productId;

  const ReelProductWidget({
    super.key,
    required this.controller,
    this.product,
    this.productTitle,
    this.productPrice,
    this.productImagePath,
    this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final title = productTitle?.trim().isNotEmpty == true
        ? productTitle!
        : (product?.title ?? 'Mystery Gifts For You');
    final price = productPrice?.trim().isNotEmpty == true
        ? productPrice!
        : (product?.price ?? '\$ 19.99');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onProductTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            color: ColorRes.blackPure.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorRes.whitePure.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorRes.blackPure.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: productImagePath != null && productImagePath!.isNotEmpty
                    ? Image.asset(
                        productImagePath!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : _buildGiftBoxImage(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 12,
                        color: ColorRes.whitePure,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price,
                      style: TextStyleCustom.outFitSemiBold600(
                        fontSize: 13,
                        color: ColorRes.whitePure,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: ColorRes.borderLight,
              ),
              InkWell(
                onTap: _onCartTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    AssetRes.icStore,
                    width: 22,
                    height: 22,
                    color: ColorRes.whitePure,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGiftBoxImage() {
    return Image.asset(
      AssetRes.reelProductGift,
      width: 44,
      height: 44,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ColorRes.themeAccentSolid.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          AssetRes.icStore,
          width: 26,
          height: 26,
          color: ColorRes.themeAccentSolid,
        ),
      ),
    );
  }

  StoreProduct? _resolveProduct() {
    if (product != null) return product;
    if (productId == null || productId!.isEmpty) return null;
    final store = Get.isRegistered<StoreScreenController>()
        ? Get.find<StoreScreenController>()
        : Get.put(StoreScreenController());
    for (final p in store.productsForYou) {
      if (p.id == productId) return p;
    }
    for (final p in store.topSelling) {
      if (p.id == productId) return p;
    }
    return null;
  }

  void _onProductTap() {
    final p = _resolveProduct();
    if (p != null) {
      Get.to(() => ProductDetailScreen(product: p));
    }
  }

  void _onCartTap() {
    final p = _resolveProduct();
    if (p != null) {
      Get.to(() => ProductDetailScreen(product: p));
    }
  }
}
