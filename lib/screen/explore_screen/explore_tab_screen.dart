import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/explore_screen/explore_tab_controller.dart';
import 'package:stakBread/screen/explore_screen/resume_view_screen.dart';
import 'package:stakBread/screen/search_screen/search_screen.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../store_screen/product_listing_screen.dart';

/// Standalone Explore tab screen matching the design:
/// Search bar, Trending Reels (category chips + horizontal reels),
/// Trending Creators (horizontal cards), Top Selling Products (horizontal cards).
class ExploreTabScreen extends StatelessWidget {
  const ExploreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ExploreTabController());
    if (!Get.isRegistered<StoreScreenController>()) {
      Get.put(StoreScreenController());
    }
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildTrendingReelsSection()),
            SliverToBoxAdapter(child: _buildTrendingCreatorsSection()),
            SliverToBoxAdapter(child: _buildTopSellingSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    );
  }

  Widget _buildTrendingReelsSection() {
    return GetBuilder<ExploreTabController>(
      builder: (ctrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              LKey.trendingReels.tr,
              LKey.viewAll.tr,
              onViewAll: () => ctrl.onTrendingReelsViewAll(),
            ),
            _buildReelsHorizontalList(ctrl),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    String title,
    String viewAll, {
    VoidCallback? onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyleCustom.unboundedMedium500(
              fontSize: 16,
              color: ColorRes.textDarkGrey,
            ),
          ),
          InkWell(
            onTap: onViewAll,
            child: Text(
              viewAll,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 14,
                color: ColorRes.textLightGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildReelsHorizontalList(ExploreTabController ctrl) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        itemCount: ctrl.reelItems.length,
        itemBuilder: (context, index) {
          final item = ctrl.reelItems[index];
          return _ReelThumbnailCard(
            item: item,
            onTap: () => ctrl.onReelTap(item),
          );
        },
      ),
    );
  }

  Widget _buildTrendingCreatorsSection() {
    return GetBuilder<ExploreTabController>(
      builder: (ctrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              LKey.trendingCreators.tr,
              LKey.viewAll.tr,
              onViewAll: () => ctrl.onTrendingCreatorsViewAll(),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ctrl.creatorItems.length,
                itemBuilder: (context, index) {
                  final creator = ctrl.creatorItems[index];
                  return _CreatorCard(
                    creator: creator,
                    onProfileTap: () => ctrl.onCreatorTap(creator),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopSellingSection() {
    final storeCtrl = Get.find<StoreScreenController>();
    final products = storeCtrl.topSelling;
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          LKey.topSellingProducts.tr,
          LKey.viewAll.tr,
          onViewAll: () {
            Get.to(() => ProductListingScreen(title: LKey.topSellingProducts.tr, products: products));

          },
        ),
        SizedBox(
          height: 248,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ExploreProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }
}

class _ReelCategory {
  final String label;
  final String imagePath;
  const _ReelCategory({required this.label, required this.imagePath});
}

class _ReelThumbnailCard extends StatelessWidget {
  final ExploreReelItem item;
  final VoidCallback? onTap;

  const _ReelThumbnailCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: ColorRes.borderLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imagePath != null && item.imagePath!.isNotEmpty
                  ? Image.asset(item.imagePath!, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFE8E8E8),
                      child: Icon(Icons.videocam_outlined, size: 36, color: ColorRes.textLightGrey),
                    ),
            ),
         /* Positioned(
            left: 8,
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, size: 18, color: ColorRes.whitePure),
                const SizedBox(width: 4),
                Text(
                  item.viewCount,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 12,
                    color: ColorRes.whitePure,
                  ),
                ),
              ],
            ),
          ),*/
          ],
        ),
      ),
    );
  }
}

class _CreatorCard extends StatelessWidget {
  final ExploreCreatorItem creator;
  final VoidCallback? onProfileTap;

  const _CreatorCard({required this.creator, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorRes.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(36),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: ColorRes.borderLight,
                    backgroundImage: creator.avatarPath != null && creator.avatarPath!.isNotEmpty
                        ? AssetImage(creator.avatarPath!) as ImageProvider
                        : null,
                    child: creator.avatarPath == null || creator.avatarPath!.isEmpty
                        ? Image.asset(AssetRes.icUserPlaceholder, width: 48, height: 48, fit: BoxFit.cover)
                        : null,
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.close, size: 18, color: ColorRes.textLightGrey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onProfileTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    creator.name,
                    style: TextStyleCustom.outFitSemiBold600(
                      fontSize: 14,
                      color: ColorRes.textDarkGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (creator.verified) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.verified, size: 14, color: ColorRes.themeAccentSolid),
                ],
              ],
            ),
          ),
          const SizedBox(height: 2),
          InkWell(
            onTap: onProfileTap,
            child: Text(
              creator.profession,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 12,
                color: ColorRes.textLightGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: ColorRes.themeAccentSolid,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => Get.to(() => ResumeViewScreen(creator: creator)),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      LKey.viewResume.tr,
                      style: TextStyleCustom.outFitSemiBold600(
                        fontSize: 12,
                        color: ColorRes.whitePure,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreProductCard extends StatelessWidget {
  final StoreProduct product;

  const _ExploreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imagePath = product.imagePath ?? '';
    return InkWell(
      onTap: () => Get.to(() => ProductDetailScreen(product: product)),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
                      ? Image.asset(
                          imagePath,
                          width: 160,
                          height: 130,
                          fit: BoxFit.cover,
                        )
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
                      color: const Color(0xFFE8F4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 12, color: ColorRes.orange),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: TextStyleCustom.outFitSemiBold600(
                            fontSize: 11,
                            color: ColorRes.textDarkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyleCustom.outFitSemiBold600(
                      fontSize: 13,
                      color: ColorRes.textDarkGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 11,
                      color: ColorRes.textLightGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
