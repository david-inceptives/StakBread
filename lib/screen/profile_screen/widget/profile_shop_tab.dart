import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/store/store_product_model.dart';
import 'package:stakBread/screen/profile_screen/profile_screen_controller.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Other user's profile — Shop tab: GET `productByUserId/:id`.
class ProfileShopTab extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfileShopTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isShopLoading.value && controller.shopProducts.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: ColorRes.green),
        );
      }
      if (controller.shopProducts.isEmpty) {
        return RefreshIndicator(
          color: ColorRes.green,
          onRefresh: controller.fetchShopProducts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
              Center(
                child: Text(
                  LKey.noData.tr,
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
      return RefreshIndicator(
        color: ColorRes.green,
        onRefresh: controller.fetchShopProducts,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: controller.shopProducts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = controller.shopProducts[index];
            return _ProfileShopProductCard(product: product);
          },
        ),
      );
    });
  }
}

class _ProfileShopProductCard extends StatelessWidget {
  final StoreProduct product;

  const _ProfileShopProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final networkUrl = product.isNetworkImage &&
            product.imageUrl != null &&
            product.imageUrl!.isNotEmpty
        ? product.imageUrl!.addBaseURL()
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => ProductDetailScreen(product: product)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: networkUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: networkUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 72,
                          height: 72,
                          color: ColorRes.borderLight,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: ColorRes.borderLight,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_outlined,
                            color: ColorRes.textLightGrey,
                          ),
                        ),
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: ColorRes.borderLight,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_outlined,
                          color: ColorRes.textLightGrey,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyleCustom.outFitSemiBold600(
                        fontSize: 15,
                        color: ColorRes.textDarkGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 12,
                        color: ColorRes.textLightGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.price ?? '',
                      style: TextStyleCustom.unboundedSemiBold600(
                        fontSize: 16,
                        color: ColorRes.themeAccentSolid,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: ColorRes.textLightGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
