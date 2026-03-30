import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/model/store/product_review_model.dart';
import 'package:stakBread/model/store/store_product_model.dart';
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
  late StoreProduct _product;
  bool _loadingDetail = false;
  /// Full-screen shimmer until detail + reviews + cart APIs finish (network products only).
  late bool _initialDataLoading;
  List<ProductReview> _reviews = [];
  bool _loadingReviews = false;
  int selectedThumbIndex = 0;
  bool hasAddedToCart = false;
  bool _addingToCart = false;
  int cartQuantity = 1;

  static const Color _shimmerBase = Color(0xFFE8E8E8);
  static const Color _shimmerHighlight = Color(0xFFF5F6F8);

  /// API product listed by the logged-in user — hide add-to-cart.
  bool get _isOwnListing {
    if (!_product.isNetworkImage) return false;
    final me = SessionManager.instance.getUserID();
    if (me <= 0) return false;
    final sid = _product.sellerUserId;
    return sid != null && sid == me;
  }

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _reviews = List<ProductReview>.from(_product.reviews);
    _initialDataLoading = _product.isNetworkImage;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cart = Get.isRegistered<CartController>() ? Get.find<CartController>() : Get.put(CartController());
      _syncFromCartIfNeeded();
      if (_product.isNetworkImage) {
        try {
          await _loadProductDetail(showProgressBar: false);
          await _loadReviews();
          if (!mounted) return;
          try {
            final list = await StoreService.instance.fetchCartItems();
            cart.replaceAllFromServer(list);
          } catch (_) {}
          if (!mounted) return;
          _syncFromCartIfNeeded();
        } finally {
          if (mounted) setState(() => _initialDataLoading = false);
        }
      }
    });
  }

  void _syncFromCartIfNeeded() {
    if (_isOwnListing) {
      if (mounted) {
        setState(() {
          hasAddedToCart = false;
          cartQuantity = 1;
        });
      }
      return;
    }
    if (!Get.isRegistered<CartController>()) return;
    final cart = Get.find<CartController>();
    final idx = cart.items.indexWhere(
      (e) => e.product.id == _product.id && e.variantId == _product.variantId,
    );
    if (idx >= 0 && mounted) {
      setState(() {
        hasAddedToCart = true;
        final q = cart.items[idx].quantity;
        final s = _product.stock;
        cartQuantity = (s != null && s > 0 && q > s) ? s : q;
      });
    } else if (mounted) {
      setState(() {
        hasAddedToCart = false;
        cartQuantity = 1;
      });
    }
  }

  Future<void> _loadReviews() async {
    if (!_product.isNetworkImage) return;
    setState(() => _loadingReviews = true);
    try {
      final list = await StoreService.instance.fetchProductReviews(_product.id);
      if (!mounted) return;
      setState(() => _reviews = list);
    } catch (_) {
      // Keep reviews from list/detail payload if dedicated reviews API fails.
    } finally {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  String _formatReviewDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      return DateFormat('dd-MMM-yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return '';
    }
  }

  Color? _parseHexColor(String input) {
    var s = input.trim();
    if (!s.startsWith('#')) return null;
    s = s.substring(1);
    if (s.length == 3) {
      s = s.split('').map((c) => '$c$c').join();
    }
    if (s.length != 6 && s.length != 8) return null;
    final v = int.tryParse(s, radix: 16);
    if (v == null) return null;
    if (s.length == 6) return Color(0xFF000000 | v);
    return Color(v);
  }

  Widget _attributeValueChip(StoreProductAttributeValue av) {
    final hex = _parseHexColor(av.value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorRes.textLightGrey.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hex != null) ...[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: hex,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            av.value,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 13,
              color: ColorRes.textDarkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProductDetail({bool showProgressBar = true}) async {
    if (showProgressBar) setState(() => _loadingDetail = true);
    try {
      final detail = await StoreService.instance.fetchProductDetail(_product.id);
      if (!mounted) return;
      if (detail != null) {
        setState(() {
          _product = detail;
          selectedThumbIndex = 0;
          if (detail.reviews.isNotEmpty) {
            _reviews = List<ProductReview>.from(detail.reviews);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (showProgressBar && mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<void> _syncCartQuantity() async {
    if (!Get.isRegistered<CartController>()) return;
    final cart = Get.find<CartController>();
    final i = cart.items.indexWhere(
      (e) => e.product.id == _product.id && e.variantId == _product.variantId,
    );
    if (i < 0) return;
    final serverId = cart.items[i].serverCartId;
    cart.updateQuantity(_product.id, cartQuantity, variantId: _product.variantId);
    if (!_product.isNetworkImage || serverId == null) return;
    try {
      await StoreService.instance.updateCart(cartId: serverId, quantity: cartQuantity);
    } catch (e) {
      if (mounted) {
        BaseController.share.showSnackBar(
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  /// Removes this product line from cart (server + local). Used when quantity goes to 0.
  Future<void> _removeProductFromCart() async {
    if (!Get.isRegistered<CartController>()) return;
    final cart = Get.find<CartController>();
    final i = cart.items.indexWhere(
      (e) => e.product.id == _product.id && e.variantId == _product.variantId,
    );
    if (i < 0) {
      if (mounted) {
        setState(() {
          hasAddedToCart = false;
          cartQuantity = 1;
        });
      }
      return;
    }
    final serverId = cart.items[i].serverCartId;
    if (_product.isNetworkImage && serverId != null) {
      try {
        await StoreService.instance.deleteFromCart(cartId: serverId);
      } catch (e) {
        if (mounted) {
          BaseController.share.showSnackBar(
            e.toString().replaceFirst('Exception: ', ''),
          );
        }
        return;
      }
    }
    cart.removeItem(_product.id, variantId: _product.variantId);
    if (mounted) {
      setState(() {
        hasAddedToCart = false;
        cartQuantity = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    var thumbnails = product.effectiveThumbnailSources;
    if (thumbnails.isEmpty) {
      final mainImage = product.imagePath ?? '';
      if (mainImage.isNotEmpty) {
        thumbnails = [mainImage, mainImage, mainImage, mainImage];
      } else {
        thumbnails = [''];
      }
    }
    final displayImage = selectedThumbIndex < thumbnails.length
        ? thumbnails[selectedThumbIndex]
        : (thumbnails.isNotEmpty ? thumbnails.first : '');
    final descriptionText = product.id == '1'
        ? LKey.productDetailDescription.tr
        : (product.detailDescription ?? product.description);
    final price = product.price ?? '\$0';
    final isOwnListing = _isOwnListing;
    final stock = product.stock;
    final isOutOfStock = stock != null && stock <= 0;

    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: LKey.productDetails.tr,
              titleStyle: TextStyleCustom.unboundedSemiBold600(fontSize: 15, color: ColorRes.textDarkGrey),

            ),
            if (!_initialDataLoading && _loadingDetail)
              const LinearProgressIndicator(
                minHeight: 2,
                color: ColorRes.green,
                backgroundColor: Color(0xFFF5F6F8),
              ),
            Expanded(
              child: _initialDataLoading
                  ? _buildProductDetailShimmer()
                  : RefreshIndicator(
                color: ColorRes.green,
                onRefresh: () async {
                  if (_product.isNetworkImage) {
                    final cart = Get.isRegistered<CartController>() ? Get.find<CartController>() : Get.put(CartController());
                    await Future.wait([
                      _loadProductDetail(showProgressBar: false),
                      _loadReviews(),
                    ]);
                    try {
                      final list = await StoreService.instance.fetchCartItems();
                      cart.replaceAllFromServer(list);
                    } catch (_) {}
                    if (mounted) _syncFromCartIfNeeded();
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main product image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _detailHeroImage(product, displayImage),
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
                                    thumbnails.length,
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
                                            child: product.isNetworkImage
                                                ? CachedNetworkImage(
                                                    imageUrl: thumbnails[i].addBaseURL(),
                                                    fit: BoxFit.cover,
                                                    width: 44,
                                                    height: 44,
                                                    errorWidget: (_, __, ___) => Icon(Icons.image, size: 32, color: ColorRes.textLightGrey),
                                                  )
                                                : Image.asset(
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
                    if (product.isNetworkImage && product.attributeValues.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LKey.productAttributes.tr,
                              style: TextStyleCustom.unboundedBold700(
                                fontSize: 15,
                                color: ColorRes.textDarkGrey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...product.attributeValuesByGroup.entries.expand((e) {
                              return [
                                Text(
                                  e.key,
                                  style: TextStyleCustom.outFitMedium500(
                                    fontSize: 13,
                                    color: ColorRes.textLightGrey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: e.value.map(_attributeValueChip).toList(),
                                ),
                                const SizedBox(height: 14),
                              ];
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
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
                    if (stock != null) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          isOutOfStock
                              ? LKey.outOfStock.tr
                              : LKey.inStockCount.trParams({'count': '$stock'}),
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 13,
                            color: isOutOfStock ? ColorRes.likeRed : ColorRes.green,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Price + Add to Cart
                    // Add to Cart / Quantity + View Cart
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isOwnListing
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              decoration: BoxDecoration(
                                color: ColorRes.disabledGrey.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: ColorRes.borderLight),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    price,
                                    style: TextStyleCustom.unboundedBold700(
                                      fontSize: 18,
                                      color: ColorRes.textDarkGrey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      LKey.ownProductNoAddToCart.tr,
                                      textAlign: TextAlign.end,
                                      style: TextStyleCustom.outFitMedium500(
                                        fontSize: 14,
                                        color: ColorRes.textLightGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : hasAddedToCart
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
                                          onTap: () async {
                                            if (cartQuantity <= 1) {
                                              await _removeProductFromCart();
                                            } else {
                                              setState(() => cartQuantity--);
                                              await _syncCartQuantity();
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
                                          onTap: () async {
                                            if (stock != null && stock > 0 && cartQuantity >= stock) {
                                              BaseController.share.showSnackBar(
                                                LKey.stockLimitReached.trParams({'count': '$stock'}),
                                              );
                                              return;
                                            }
                                            setState(() => cartQuantity++);
                                            await _syncCartQuantity();
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
                                onTap: _addingToCart
                                    ? null
                                    : () async {
                                        if (isOutOfStock) {
                                          BaseController.share.showSnackBar(LKey.outOfStock.tr);
                                          return;
                                        }
                                        final cart = Get.put(CartController());
                                        if (product.isNetworkImage) {
                                          final vid = product.variantId;
                                          if (vid == null) {
                                            BaseController.share.showSnackBar(
                                              LKey.somethingWentWrong.tr,
                                            );
                                            return;
                                          }
                                          setState(() => _addingToCart = true);
                                          try {
                                            final cartId = await StoreService.instance.addToCart(
                                              productId: product.id,
                                              quantity: 1,
                                              variantId: vid,
                                            );
                                            if (!mounted) return;
                                            cart.addItem(
                                              product,
                                              quantity: 1,
                                              variantText: 'Standard',
                                              serverCartId: cartId,
                                              variantId: vid,
                                            );
                                            setState(() {
                                              hasAddedToCart = true;
                                              cartQuantity = 1;
                                              _addingToCart = false;
                                            });
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() => _addingToCart = false);
                                              BaseController.share.showSnackBar(
                                                e.toString().replaceFirst('Exception: ', ''),
                                              );
                                            }
                                          }
                                        } else {
                                          cart.addItem(
                                            product,
                                            quantity: 1,
                                            variantText: product.id == '2'
                                                ? '${LKey.sizeLabel.tr}: M'
                                                : '${LKey.colorLabel.tr}: Black',
                                          );
                                          setState(() {
                                            hasAddedToCart = true;
                                            cartQuantity = 1;
                                          });
                                        }
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
                            '${LKey.allReviews.tr} (${product.isNetworkImage ? _reviews.length : 1})',
                            style: TextStyleCustom.outFitRegular400(fontSize: 15, color: ColorRes.textLightGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (product.isNetworkImage) ...[
                      if (_loadingReviews && _reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(color: ColorRes.green),
                          ),
                        )
                      else if (!_loadingReviews && _reviews.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            LKey.noData.tr,
                            textAlign: TextAlign.center,
                            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
                          ),
                        )
                      else
                        ..._reviews.map(
                          (r) => Padding(
                            key: ValueKey(r.id),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: _ApiReviewCard(
                              review: r,
                              formattedDate: _formatReviewDate(r.displayDateRaw),
                            ),
                          ),
                        ),
                    ] else
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
                                "Alex Was Incredibly Professional And Fixed Our Leaking Issue In No Time. Highly Recommend!",
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
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailShimmer() {
    Widget bar(double w, double h, [double radius = 8]) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: ColorRes.whitePure,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: bar(double.infinity, 280, 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          4,
                          (i) => Padding(
                            padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                            child: bar(44, 44, 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: List.generate(5, (_) => bar(18, 18, 4)),
                      ),
                      const SizedBox(height: 6),
                      bar(52, 14, 4),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              bar(MediaQuery.sizeOf(context).width * 0.65, 18, 6),
              const SizedBox(height: 10),
              bar(double.infinity, 12, 4),
              const SizedBox(height: 8),
              bar(double.infinity, 12, 4),
              const SizedBox(height: 8),
              bar(MediaQuery.sizeOf(context).width * 0.45, 12, 4),
              const SizedBox(height: 22),
              bar(double.infinity, 56, 15),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      bar(42, 42, 10),
                      const SizedBox(width: 8),
                      bar(160, 18, 6),
                    ],
                  ),
                  bar(120, 14, 4),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorRes.whitePure,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorRes.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            bar(48, 48, 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  bar(120, 14, 4),
                                  const SizedBox(height: 8),
                                  bar(90, 12, 4),
                                ],
                              ),
                            ),
                            bar(72, 14, 4),
                          ],
                        ),
                        const SizedBox(height: 12),
                        bar(double.infinity, 12, 4),
                        const SizedBox(height: 6),
                        bar(double.infinity, 12, 4),
                        const SizedBox(height: 6),
                        bar(200, 12, 4),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailHeroImage(StoreProduct product, String displaySrc) {
    if (displaySrc.isEmpty) return _placeholder();
    if (product.isNetworkImage) {
      return CachedNetworkImage(
        height: 40.h,
        imageUrl: displaySrc.addBaseURL(),
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => Container(
          height: 40.h,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: ColorRes.green),
        ),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return Image.asset(
      displaySrc,
      fit: BoxFit.contain,
      width: double.infinity,
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8E0F0),
      child: Icon(Icons.image_outlined, size: 72, color: ColorRes.textLightGrey),
    );
  }
}

class _ApiReviewCard extends StatelessWidget {
  final ProductReview review;
  final String formattedDate;

  const _ApiReviewCard({
    required this.review,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final u = review.user;
    final fn = u?.fullname?.trim();
    final un = u?.username?.trim();
    final displayName = (fn != null && fn.isNotEmpty)
        ? fn
        : (un != null && un.isNotEmpty)
            ? un
            : 'User';
    final photo = u?.profilePhoto;

    final starCount = review.rating.clamp(0, 5);

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: photo != null && photo.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photo.addBaseURL(),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _reviewAvatarFallback(),
                      )
                    : _reviewAvatarFallback(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
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
                    children: List.generate(5, (i) {
                      return Icon(
                        i < starCount ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 18,
                        color: const Color(0xFFFFC107),
                      );
                    }),
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyleCustom.outFitRegular400(fontSize: 12, color: ColorRes.textLightGrey),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.review,
            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
          ),
        ],
      ),
    );
  }

  Widget _reviewAvatarFallback() {
    return Container(
      width: 48,
      height: 48,
      color: ColorRes.borderLight,
      alignment: Alignment.center,
      child: Icon(Icons.person, size: 28, color: ColorRes.textLightGrey),
    );
  }
}
