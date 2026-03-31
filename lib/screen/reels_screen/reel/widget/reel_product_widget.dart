import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/model/store/store_product_model.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Product strip on reel: API `product` and/or `owner_products`.
class ReelProductWidget extends StatelessWidget {
  final List<StoreProduct> products;

  const ReelProductWidget({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _ReelProductChip(product: products[i]),
      ),
    );
  }
}

class _ReelProductChip extends StatelessWidget {
  final StoreProduct product;

  const _ReelProductChip({required this.product});

  void _openProduct() {
    Get.to(() => ProductDetailScreen(product: product));
  }

  @override
  Widget build(BuildContext context) {
    final title = product.title.trim().isNotEmpty ? product.title : 'Product';
    final price = product.price?.trim().isNotEmpty == true ? product.price! : '\$0';
    final thumbRaw = product.effectiveThumbnailSources.isNotEmpty
        ? product.effectiveThumbnailSources.first
        : (product.imageUrl ?? '');
    final thumb = thumbRaw.trim().isNotEmpty ? thumbRaw.addBaseURL() : '';
    final hasThumb = thumb.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openProduct,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 220),
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
                child: hasThumb
                    ? CachedNetworkImage(
                        imageUrl: thumb,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _fallbackThumb(),
                      )
                    : _fallbackThumb(),
              ),
              const SizedBox(width: 8),
              Flexible(
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
                onTap: _openProduct,
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

  Widget _fallbackThumb() {
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
}
