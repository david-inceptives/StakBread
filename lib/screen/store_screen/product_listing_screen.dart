import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/store_screen/cart_controller.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../../common/widget/custom_app_bar.dart';

class ProductListingScreen extends StatefulWidget {
  final String title;
  final List<StoreProduct> products;

  /// When true, the list follows [StoreScreenController.productsForYou] so pull-to-refresh updates the list.
  final bool useStoreProductsForYou;

  /// When true, the list follows [StoreScreenController.topSelling] so pull-to-refresh updates the list.
  final bool useStoreTopSelling;

  /// When set, loads from GET [productsByCategory/:id] (ignores [useStoreProductsForYou] / [useStoreTopSelling]).
  final String? categoryId;

  const ProductListingScreen({
    super.key,
    required this.title,
    required this.products,
    this.useStoreProductsForYou = false,
    this.useStoreTopSelling = false,
    this.categoryId,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  List<StoreProduct> _categoryProducts = [];
  bool _loadingCategory = false;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.categoryId != null) {
        _loadCategoryProducts();
      } else {
        _fetchFullListOnOpen();
      }
    });
  }

  Future<void> _loadCategoryProducts() async {
    final id = widget.categoryId;
    if (id == null || !mounted) return;
    setState(() {
      _loadingCategory = true;
      _categoryError = null;
    });
    try {
      final list = await StoreService.instance.fetchProductsByCategory(id);
      if (!mounted) return;
      setState(() {
        _categoryProducts = list;
        _loadingCategory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCategory = false;
        _categoryError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  /// View All should hit the API again so the list has the full response, not only what was loaded on the store home.
  Future<void> _fetchFullListOnOpen() async {
    if (!mounted) return;
    if (!Get.isRegistered<StoreScreenController>()) return;
    final c = Get.find<StoreScreenController>();
    if (widget.useStoreProductsForYou) {
      await c.loadProductsForYou(silent: true);
    } else if (widget.useStoreTopSelling) {
      await c.loadTopSellingProducts(silent: true);
    }
  }

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

  Future<void> _onRefresh() async {
    if (widget.categoryId != null) {
      await _loadCategoryProducts();
      return;
    }
    if (!Get.isRegistered<StoreScreenController>()) return;
    final c = Get.find<StoreScreenController>();
    if (widget.useStoreProductsForYou) {
      await c.loadProductsForYou(silent: true);
    } else if (widget.useStoreTopSelling) {
      await c.loadTopSellingProducts(silent: true);
    } else {
      await c.refreshStoreHome();
    }
  }

  Widget _productList(List<StoreProduct> list) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final product = list[index];
        return _ListingProductCard(
          product: product,
          imageTint: _cardImageTint(index),
          onTap: () => Get.to(() => ProductDetailScreen(product: product)),
          onAddToCart: () async {
            final cart = Get.isRegistered<CartController>()
                ? Get.find<CartController>()
                : Get.put(CartController());
            await StoreService.instance.replaceCartIfDifferentSeller(
              cart: cart,
              product: product,
            );
            cart.addItem(
              product,
              quantity: 1,
              variantText: product.isNetworkImage
                  ? 'Standard'
                  : (product.id == '2' ? 'Size: M' : 'Color: Black'),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyList() {
      if (widget.categoryId != null) {
        if (_loadingCategory && _categoryProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: ColorRes.green));
        }
        if (_categoryError != null && _categoryProducts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _categoryError!,
                    textAlign: TextAlign.center,
                    style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadCategoryProducts,
                    child: Text(LKey.retry.tr, style: TextStyleCustom.outFitSemiBold600(color: ColorRes.green)),
                  ),
                ],
              ),
            ),
          );
        }
        if (_categoryProducts.isEmpty) {
          return Center(
            child: Text(
              LKey.noData.tr,
              style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
            ),
          );
        }
        return RefreshIndicator(
          color: ColorRes.green,
          onRefresh: _onRefresh,
          child: _productList(_categoryProducts),
        );
      }
      if (widget.useStoreProductsForYou && Get.isRegistered<StoreScreenController>()) {
        final c = Get.find<StoreScreenController>();
        return Obx(() {
          final list = c.productsForYou.toList();
          return RefreshIndicator(
            color: ColorRes.green,
            onRefresh: _onRefresh,
            child: _productList(list),
          );
        });
      }
      if (widget.useStoreTopSelling && Get.isRegistered<StoreScreenController>()) {
        final c = Get.find<StoreScreenController>();
        return Obx(() {
          final list = c.topSelling.toList();
          return RefreshIndicator(
            color: ColorRes.green,
            onRefresh: _onRefresh,
            child: _productList(list),
          );
        });
      }
      return RefreshIndicator(
        color: ColorRes.green,
        onRefresh: _onRefresh,
        child: _productList(widget.products),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: widget.title,
              titleStyle: TextStyleCustom.unboundedSemiBold600(fontSize: 18, color: ColorRes.textDarkGrey),
              bgColor: const Color(0xFFF5F6F8),
            ),
            Expanded(child: bodyList()),
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
    final networkUrl = product.isNetworkImage && product.imageUrl != null && product.imageUrl!.isNotEmpty
        ? product.imageUrl!.addBaseURL()
        : '';
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
                    child: networkUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: networkUrl,
                            fit: BoxFit.cover,
                            width: 66,
                            height: 66,
                            placeholder: (_, __) => Container(color: imageTint),
                            errorWidget: (_, __, ___) =>
                                Icon(Icons.image_outlined, size: 40, color: ColorRes.textLightGrey),
                          )
                        : imagePath.isNotEmpty
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
