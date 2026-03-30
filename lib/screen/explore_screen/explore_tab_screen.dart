import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/common/widget/my_refresh_indicator.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/post_story/post_model.dart';
import 'package:stakBread/screen/explore_screen/explore_creator_circle_avatar.dart';
import 'package:stakBread/screen/explore_screen/explore_tab_controller.dart';
import 'package:stakBread/screen/explore_screen/most_viewed_reels_list_screen.dart';
import 'package:stakBread/screen/explore_screen/resume_view_screen.dart';
import 'package:stakBread/screen/explore_screen/trending_creators_list_screen.dart';
import 'package:stakBread/screen/reels_screen/reels_screen.dart';
import 'package:stakBread/common/widget/reel_list.dart';
import 'package:stakBread/screen/search_screen/search_screen.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../store_screen/product_listing_screen.dart';

class _ExploreTabShimmer extends StatelessWidget {
  const _ExploreTabShimmer();

  static const Color _base = Color(0xFFE8E8E8);
  static const Color _highlight = Color(0xFFF5F6F8);

  Widget _bar(double w, double h, [double r = 8]) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }

  Widget _horizontalRow(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 14, bottom: 20),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => _bar(110, 172, 12),
      ),
    );
  }

  Widget _sectionTitleRow(double width) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bar(width * 0.42, 18, 6),
          _bar(52, 14, 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width - 32;
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _bar(double.infinity, 44, 12),
              _sectionTitleRow(w),
              _horizontalRow(context),
              _sectionTitleRow(w),
              _horizontalRow(context),
              _sectionTitleRow(w),
              _horizontalRow(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

void _openExploreMostViewedReel(ExploreTabController ctrl, Post post) {
  final idx = ctrl.mostViewedReelsAll.indexWhere((p) => p.id == post.id);
  final pos = idx < 0 ? 0 : idx;
  Get.to(
    () => ReelsScreen(
      reels: RxList<Post>.from(ctrl.mostViewedReelsAll),
      position: pos,
    ),
    preventDuplicates: false,
  );
}

/// Standalone Explore tab screen matching the design:
/// Search bar, Trending Reels (category chips + horizontal reels),
/// Trending Creators (horizontal cards), Top Selling Products (horizontal cards).
class ExploreTabScreen extends StatelessWidget {
  const ExploreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StoreScreenController>()) {
      Get.put(StoreScreenController());
    }
    if (!Get.isRegistered<ExploreTabController>()) {
      Get.put(ExploreTabController());
    }
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: GetBuilder<ExploreTabController>(
        builder: (ctrl) {
          if (!ctrl.exploreInitialLoadComplete) {
            return const SafeArea(
              bottom: false,
              child: _ExploreTabShimmer(),
            );
          }
          return SafeArea(
            bottom: false,
            child: MyRefreshIndicator(
              onRefresh: () => ctrl.refreshExplore(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
        },
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
        if (ctrl.mostViewedReelsAll.isEmpty) {
          return const SizedBox.shrink();
        }
        final preview = ctrl.mostViewedReelsPreview;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              LKey.trendingReels.tr,
              LKey.viewAll.tr,
              onViewAll: ctrl.showMostViewedReelsViewAll
                  ? () => Get.to(() => const MostViewedReelsListScreen())
                  : null,
            ),
            _buildReelsHorizontalList(ctrl, preview),
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
          if (onViewAll != null)
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



  Widget _buildReelsHorizontalList(ExploreTabController ctrl, List<Post> preview) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        itemCount: preview.length,
        itemBuilder: (context, index) {
          final post = preview[index];
          return _ReelThumbnailCard(
            post: post,
            onTap: () => _openExploreMostViewedReel(ctrl, post),
          );
        },
      ),
    );
  }

  Widget _buildTrendingCreatorsSection() {
    return GetBuilder<ExploreTabController>(
      builder: (ctrl) {
        if (ctrl.trendingCreatorsAll.isEmpty) {
          return const SizedBox.shrink();
        }
        final preview = ctrl.trendingCreatorsPreview;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              LKey.trendingCreators.tr,
              LKey.viewAll.tr,
              onViewAll: ctrl.showTrendingCreatorsViewAll
                  ? () => Get.to(() => const TrendingCreatorsListScreen())
                  : null,
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: preview.length,
                itemBuilder: (context, index) {
                  final creator = preview[index];
                  return _CreatorCard(creator: creator);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopSellingSection() {
    return Obx(() {
      final storeCtrl = Get.find<StoreScreenController>();
      final products = storeCtrl.topSellingPreview;
      if (products.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            LKey.topSellingProducts.tr,
            LKey.viewAll.tr,
            onViewAll: () {
              Get.to(() => ProductListingScreen(
                    title: LKey.topSellingProducts.tr,
                    products: storeCtrl.topSelling.toList(),
                    useStoreTopSelling: true,
                  ));
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
    });
  }
}

class _ReelThumbnailCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _ReelThumbnailCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumb = postThumbnailUrl(post);
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
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumb != null && thumb.isNotEmpty)
              CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover)
            else
              Container(
                color: const Color(0xFFE8E8E8),
                child: Icon(Icons.videocam_outlined, size: 36, color: ColorRes.textLightGrey),
              ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 18, color: ColorRes.whitePure.withValues(alpha: 0.95)),
                  const SizedBox(width: 2),
                  Text(
                    '${post.views ?? 0}',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 12,
                      color: ColorRes.whitePure,
                    ),
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

class _CreatorCard extends StatelessWidget {
  final ExploreCreatorItem creator;

  const _CreatorCard({required this.creator});

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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: ExploreCreatorCircleAvatar(creator: creator, radius: 36),
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
          const SizedBox(height: 10),
          Row(
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
          const SizedBox(height: 2),
          Text(
            creator.profession,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 12,
              color: ColorRes.textLightGrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: creator.resume != null
                  ? ColorRes.themeAccentSolid
                  : ColorRes.borderLight,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: creator.resume != null
                    ? () => Get.to(() => ResumeViewScreen(creator: creator))
                    : null,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      LKey.viewResume.tr,
                      style: TextStyleCustom.outFitSemiBold600(
                        fontSize: 12,
                        color: creator.resume != null
                            ? ColorRes.whitePure
                            : ColorRes.textLightGrey,
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

Widget _exploreTopSellingImage(StoreProduct product) {
  if (product.isNetworkImage && product.imageUrl != null && product.imageUrl!.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: product.imageUrl!.addBaseURL(),
      width: 160,
      height: 130,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: 160,
        height: 130,
        color: ColorRes.borderLight,
      ),
      errorWidget: (_, __, ___) => Container(
        width: 160,
        height: 130,
        color: ColorRes.borderLight,
        child: Icon(Icons.image_outlined, size: 40, color: ColorRes.textLightGrey),
      ),
    );
  }
  final imagePath = product.imagePath ?? '';
  if (imagePath.isNotEmpty) {
    return Image.asset(imagePath, width: 160, height: 130, fit: BoxFit.cover);
  }
  return Container(
    width: 160,
    height: 130,
    color: ColorRes.borderLight,
    child: Icon(Icons.image_outlined, size: 40, color: ColorRes.textLightGrey),
  );
}

class _ExploreProductCard extends StatelessWidget {
  final StoreProduct product;

  const _ExploreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
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
                  child: _exploreTopSellingImage(product),
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
