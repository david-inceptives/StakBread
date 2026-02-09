import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:stakBread/screen/notification_screen/notification_screen.dart';
import 'package:stakBread/screen/search_screen/search_screen.dart';
import 'package:stakBread/screen/store_screen/cart_controller.dart';
import 'package:stakBread/screen/store_screen/cart_screen.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/screen/store_screen/product_listing_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoreScreenController());
    final cartController = Get.put(CartController());
    int notifCount = 0;
    if (Get.isRegistered<DashboardScreenController>()) {
      final dash = Get.find<DashboardScreenController>();
      notifCount = dash.requestUnReadCount.value;
    }
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildTopBar(notifCount, controller, cartController)),
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: _buildCategories(controller)),
            SliverToBoxAdapter(child: _buildSectionHeader(
              LKey.productsForYou.tr,
              LKey.viewAll.tr,
              onViewAll: () => Get.to(() => ProductListingScreen(title: LKey.productsForYou.tr, products: controller.productsForYou)),
            )),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = controller.productsForYou[index];
                  return _ProductCard(product: product);
                },
                childCount: controller.productsForYou.length,
              ),
            ),
            SliverToBoxAdapter(child: _buildSectionHeader(
              LKey.topSellingProducts.tr,
              LKey.viewAll.tr,
              onViewAll: () => Get.to(() => ProductListingScreen(title: LKey.topSellingProducts.tr, products: controller.topSelling)),
            )),
            SliverToBoxAdapter(child: _buildTopSellingRow(controller)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(int notifCount, StoreScreenController controller, CartController cartController) {
    return Container(
      color: ColorRes.whitePure,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Get.to(() => const SearchScreen()),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF5F6F8),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(cornerRadius: 12),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LKey.search.tr,
                        style: TextStyleCustom.outFitRegular400(
                          color: ColorRes.textLightGrey,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Icon(Icons.search_rounded, size: 22, color: ColorRes.textLightGrey),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _IconWithBadge(
            icon: Icons.notifications_outlined,
            count: notifCount,
            onTap: () => Get.to(() => const NotificationScreen()),
          ),
          const SizedBox(width: 10),
          Obx(() => _IconWithBadge(
                icon: Icons.shopping_cart_outlined,
                count: cartController.totalItemCount,
                onTap: () => Get.to(() => const CartScreen()),
              )),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 160,
      decoration: ShapeDecoration(
        color: ColorRes.green,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 24),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Left: headline, tagline, Buy Now button
            Positioned(
              left: 10,
              top: 20,
              right: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LKey.storeBannerTitle.tr,
                    style: TextStyleCustom.unboundedBold700(
                      fontSize: 15,
                      color: ColorRes.whitePure,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    LKey.storeBannerSubtitle.tr,
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 10,
                      color: ColorRes.whitePure.withValues(alpha: 0.95),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: ColorRes.whitePure,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: ColorRes.green, width: 1.5),
                    ),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          LKey.buyNow.tr,
                          style: TextStyleCustom.outFitSemiBold600(
                            fontSize: 12,
                            color: ColorRes.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Right: model image (overlaps slightly into text area)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 250,
              child: Image.asset(
                AssetRes.storeBannerModel,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(StoreScreenController controller) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final cat = controller.categories[index];
          return GestureDetector(
            onTap: (){
              Get.to(() => ProductListingScreen(title: controller.categories[index].name, products: controller.productsForYou));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorRes.green, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        cat.imagePath,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                        errorBuilder: (_, __, ___) => Container(
                          color: ColorRes.borderLight,
                          child: Icon(Icons.category, color: ColorRes.textLightGrey, size: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 64,
                    child: Text(
                      cat.name,
                      style: TextStyleCustom.outFitRegular400(fontSize: 12, color: ColorRes.textDarkGrey),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String viewAll, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyleCustom.unboundedBlack900(fontSize: 18, color: ColorRes.textDarkGrey),
          ),
          InkWell(
            onTap: onViewAll,
            child: Text(
              viewAll,
              style: TextStyleCustom.outFitSemiBold600(fontSize: 14, color: ColorRes.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingRow(StoreScreenController controller) {
    return SizedBox(
      height: 268,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.topSelling.length,
        itemBuilder: (context, index) {
          final product = controller.topSelling[index];
          return _TopSellingCard(product: product);
        },
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _IconWithBadge({required this.icon, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 26, color: ColorRes.textDarkGrey),
            if (count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: const BoxDecoration(
                    color: ColorRes.likeRed,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: TextStyleCustom.outFitRegular400(color: ColorRes.whitePure, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final StoreProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => ProductDetailScreen(product: product)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
        color: ColorRes.whitePure,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 16),
          side: const BorderSide(color: ColorRes.borderLight),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: product.imagePath != null
                  ? Image.asset(
                      product.imagePath!,
                      fit: BoxFit.cover,
                    )
                  : _buildProductPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: TextStyleCustom.outFitSemiBold600(fontSize: 14, color: ColorRes.textDarkGrey),
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
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                          i < product.rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 14,
                          color: ColorRes.orange,
                        )),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating} / 5',
                      style: TextStyleCustom.outFitRegular400(fontSize: 12, color: ColorRes.textLightGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: ColorRes.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: (){},
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 60,
                height: 60,
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
    );
  }

  Widget _buildProductPlaceholder() {
    return Container(
      color: ColorRes.borderLight,
      child: Image.asset(
        AssetRes.icStoreFill,
        fit: BoxFit.cover,
      )
    );
  }
}

class _TopSellingCard extends StatelessWidget {
  final StoreProduct product;

  const _TopSellingCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imagePath = product.imagePath ?? '';
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: imagePath.isNotEmpty
                    ? Image.asset(imagePath, width: 160, height: 130, fit: BoxFit.cover)
                    : Container(
                        width: 160,
                        height: 130,
                        color: ColorRes.borderLight,
                        child: Icon(Icons.image_outlined, size: 40, color: ColorRes.textLightGrey),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorRes.whitePure,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: ColorRes.orange),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating}',
                        style: TextStyleCustom.outFitSemiBold600(fontSize: 11, color: ColorRes.textDarkGrey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: TextStyleCustom.outFitSemiBold600(fontSize: 13, color: ColorRes.textDarkGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyleCustom.outFitRegular400(fontSize: 11, color: ColorRes.textLightGrey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: ColorRes.green,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => Get.to(() => ProductDetailScreen(product: product)),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            LKey.viewProduct.tr,
                            style: TextStyleCustom.outFitSemiBold600(fontSize: 12, color: ColorRes.whitePure),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
