import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/store_screen/cart_controller.dart';
import 'package:stakBread/screen/store_screen/cart_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../../common/widget/custom_app_bar.dart';
import '../../utilities/asset_res.dart';

class ProductDetailScreen extends StatefulWidget {
  final StoreProduct product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedThumbIndex = 0;
  bool hasAddedToCart = false;
  int cartQuantity = 1;

  void _syncCartQuantity() {
    if (!Get.isRegistered<CartController>()) return;
    Get.find<CartController>().updateQuantity(widget.product.id, cartQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final mainImage = product.imagePath ?? '';
    final thumbnails = product.thumbnailPaths ?? [mainImage, mainImage, mainImage, mainImage].where((e) => e.isNotEmpty).toList();
    if (thumbnails.isEmpty) thumbnails.add(mainImage);
    final displayImage = selectedThumbIndex < thumbnails.length ? thumbnails[selectedThumbIndex] : mainImage;
    final descriptionText = product.id == '1'
        ? LKey.productDetailDescription.tr
        : (product.detailDescription ?? product.description);
    final price = product.price ?? '\$0';

    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: LKey.productDetails.tr,
              titleStyle: TextStyleCustom.unboundedSemiBold600(fontSize: 15, color: ColorRes.textDarkGrey),
              rowWidget: IconButton(
                icon: Icon(Icons.more_horiz, color: ColorRes.textDarkGrey, size: 24),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main product image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: displayImage.isNotEmpty
                            ? Image.asset(
                          displayImage,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        )
                            : _placeholder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Thumbnails + Rating
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width:200,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    thumbnails.length > 4 ? 4 : thumbnails.length,
                                        (i) {
                                      final isSelected = selectedThumbIndex == i;
                                      return GestureDetector(
                                        onTap: () => setState(() => selectedThumbIndex = i),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          margin: const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected ? ColorRes.textDarkGrey : ColorRes.borderLight,
                                              width: isSelected ? 2.5 : 1.5,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(11),
                                            child: Image.asset(
                                              thumbnails[i],
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Icon(Icons.image, size: 32, color: ColorRes.textLightGrey),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  ...List.generate(5, (i) {
                                    final r = product.rating;
                                    final filled = i < r.floor();
                                    final half = i == r.floor() && r - r.floor() >= 0.5;
                                    return Icon(
                                      filled ? Icons.star_rounded : (half ? Icons.star_half_rounded : Icons.star_outline_rounded),
                                      size: 22,
                                      color: const Color(0xFFFFC107),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${product.rating} / 5',
                                style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.blackPure),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        product.title,
                        style: TextStyleCustom.unboundedBold700(fontSize: 16, color: ColorRes.textDarkGrey),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        descriptionText,
                        style: TextStyleCustom.outFitRegular400(fontSize: 12, color: ColorRes.textLightGrey, opacity: 0.95),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Price + Add to Cart
                    // Add to Cart / Quantity + View Cart
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: hasAddedToCart
                          ? Row(
                              children: [
                                // Quantity selector: light green bg, dark green border
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: ColorRes.green.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: ColorRes.green, width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (cartQuantity > 1) {
                                              setState(() {
                                                cartQuantity--;
                                                _syncCartQuantity();
                                              });
                                            }
                                          },
                                          customBorder: const CircleBorder(),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: ColorRes.green,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(Icons.remove, size: 18, color: ColorRes.whitePure),
                                          ),
                                        ),
                                        Text(
                                          cartQuantity.toString().padLeft(2, '0'),
                                          style: TextStyleCustom.unboundedBold700(fontSize: 16, color: ColorRes.green),
                                        ),
                                        InkWell(
                                          onTap: () => setState(() {
                                            cartQuantity++;
                                            _syncCartQuantity();
                                          }),
                                          customBorder: const CircleBorder(),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: ColorRes.green,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(Icons.add, size: 18, color: ColorRes.whitePure),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // View Cart button
                                Expanded(
                                  child: Material(
                                    color: ColorRes.green,
                                    borderRadius: BorderRadius.circular(14),
                                    child: InkWell(
                                      onTap: () => Get.to(() => const CartScreen()),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              LKey.viewCart.tr,
                                              style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.whitePure),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(Icons.arrow_forward_rounded, size: 20, color: ColorRes.whitePure),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Material(
                              color: ColorRes.green,
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                onTap: () {
                                  final cart = Get.put(CartController());
                                  cart.addItem(product, quantity: 1, variantText: product.id == '2' ? '${LKey.sizeLabel.tr}: M' : '${LKey.colorLabel.tr}: Black');
                                  setState(() {
                                    hasAddedToCart = true;
                                    cartQuantity = 1;
                                  });
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        price,
                                        style: TextStyleCustom.unboundedBold700(fontSize: 18, color: ColorRes.whitePure),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            LKey.addToCart.tr,
                                            style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.whitePure),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(Icons.arrow_forward_rounded, size: 18, color: ColorRes.whitePure),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),
                    // Reviews & Ratings
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                AssetRes.icRating,
                                fit: BoxFit.cover,
                                width: 42,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                LKey.reviewsAndRatings.tr,
                                style: TextStyleCustom.unboundedBold700(fontSize: 16, color: ColorRes.textDarkGrey),
                              ),
                            ],
                          ),
                          Text(
                            '${LKey.allReviews.tr} (125)',
                            style: TextStyleCustom.outFitRegular400(fontSize: 15, color: ColorRes.textLightGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Review card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: ColorRes.whitePure,
                          border: Border.all(color: ColorRes.borderLight),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: ColorRes.borderLight,
                                  child: Icon(Icons.person, size: 28, color: ColorRes.textLightGrey),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lisa Lin',
                                        style: TextStyleCustom.outFitSemiBold600(fontSize: 17, color: ColorRes.textDarkGrey),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: ColorRes.green.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_rounded, size: 13, color: ColorRes.green),
                                            const SizedBox(width: 5),
                                            Text(
                                              LKey.verifiedCustomer.tr,
                                              style: TextStyleCustom.outFitSemiBold600(fontSize: 12, color: ColorRes.green),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: List.generate(4, (_) => Icon(Icons.star_rounded, size: 18, color: const Color(0xFFFFC107))),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '18-Feb-2022',
                                      style: TextStyleCustom.outFitRegular400(fontSize: 12, color: ColorRes.textLightGrey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Skincare Essentials set is Incredibly Essential And Fixed Our Skin Issues In No Time. Highly Recommend!",
                              style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8E0F0),
      child: Icon(Icons.image_outlined, size: 72, color: ColorRes.textLightGrey),
    );
  }
}
