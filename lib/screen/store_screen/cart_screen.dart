import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/screen/store_screen/cart_controller.dart';
import 'package:stakBread/screen/store_screen/order_confirmed_screen.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../../common/widget/custom_app_bar.dart';

Widget _cartProductImage(StoreProduct product, double width, double height) {
  if (product.isNetworkImage && product.imageUrl != null && product.imageUrl!.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: product.imageUrl!.addBaseURL(),
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(width: width, height: height, color: ColorRes.borderLight),
      errorWidget: (_, __, ___) => Container(width: width, height: height, color: ColorRes.borderLight),
    );
  }
  final imagePath = product.imagePath ?? '';
  if (imagePath.isNotEmpty) {
    return Image.asset(imagePath, width: width, height: height, fit: BoxFit.cover);
  }
  return Container(width: width, height: height, color: ColorRes.borderLight);
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _applyingCoupon = false;
  List<StoreProduct> _featureProducts = [];
  bool _loadingFeatureProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        _refreshCartFromServer(),
        _loadFeatureProducts(),
      ]);
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _refreshCartFromServer() async {
    Get.put(CartController());
    try {
      final list = await StoreService.instance.fetchCartItems();
      Get.find<CartController>().replaceAllFromServer(list);
    } catch (_) {}
  }

  Future<void> _loadFeatureProducts() async {
    if (!mounted) return;
    setState(() => _loadingFeatureProducts = true);
    try {
      final list = await StoreService.instance.fetchFeatureProducts();
      if (mounted) setState(() => _featureProducts = list);
    } catch (_) {
      if (mounted) setState(() => _featureProducts = []);
    } finally {
      if (mounted) setState(() => _loadingFeatureProducts = false);
    }
  }

  Future<void> _onIncrementQuantity(CartController cart, String productId, int? variantId) async {
    final i = cart.items.indexWhere(
      (e) => e.product.id == productId && e.variantId == variantId,
    );
    if (i < 0) return;
    final serverId = cart.items[i].serverCartId;
    final isNet = cart.items[i].product.isNetworkImage;
    cart.incrementQuantity(productId, variantId: variantId);
    if (!isNet || serverId == null) return;
    final j = cart.items.indexWhere(
      (e) => e.product.id == productId && e.variantId == variantId,
    );
    if (j < 0) return;
    try {
      await StoreService.instance.updateCart(
        cartId: serverId,
        quantity: cart.items[j].quantity,
      );
    } catch (e) {
      BaseController.share.showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _onDecrementQuantity(CartController cart, String productId, int? variantId) async {
    final i = cart.items.indexWhere(
      (e) => e.product.id == productId && e.variantId == variantId,
    );
    if (i < 0) return;
    final serverId = cart.items[i].serverCartId;
    final isNet = cart.items[i].product.isNetworkImage;
    final nextQty = cart.items[i].quantity - 1;
    cart.decrementQuantity(productId, variantId: variantId);
    if (!isNet || serverId == null) return;
    try {
      if (nextQty <= 0) {
        await StoreService.instance.deleteFromCart(cartId: serverId);
      } else {
        await StoreService.instance.updateCart(
          cartId: serverId,
          quantity: nextQty,
        );
      }
    } catch (e) {
      BaseController.share.showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _applyCoupon(CartController cart) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      BaseController.share.showSnackBar(LKey.enterCouponCode.tr);
      return;
    }
    setState(() => _applyingCoupon = true);
    try {
      final r = await StoreService.instance.applyCoupon(code: code);
      if (!mounted) return;
      if (!r.success) {
        BaseController.share.showSnackBar(r.message ?? LKey.somethingWentWrong.tr);
        return;
      }
      cart.setAppliedCoupon(code, r.discountAmount);
      BaseController.share.showSnackBar(
        r.message ?? LKey.couponApplied.tr,
        second: 2,
      );
    } catch (e) {
      BaseController.share.showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _applyingCoupon = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.put(CartController());
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: LKey.cart.tr,
              titleStyle: TextStyleCustom.unboundedSemiBold600(fontSize: 15, color: ColorRes.textDarkGrey),
              bgColor: const Color(0xFFF5F6F8),

            ),
            Expanded(
              child: Obx(() {
                if (cart.items.isEmpty) {
                  return _buildEmptyCartContent();
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildCartItems(cart),
                      const SizedBox(height: 16),
                      _buildDelivery(),
                      _buildDivider(),
                      _buildAddress(),
                      _buildDivider(),
                      _buildPayment(),
                      _buildDivider(),
                      const SizedBox(height: 12),
                      _buildCoupon(cart),
                      const SizedBox(height: 20),
                      _buildTotal(cart),
                      const SizedBox(height: 16),
                      _buildCheckOutButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildEmptyCartIllustration(),
          const SizedBox(height: 28),
          Text(
            LKey.yourCartIsEmpty.tr,
            style: TextStyleCustom.unboundedBold700(fontSize: 22, color: ColorRes.textDarkGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            LKey.yourCartIsEmptySubtext.tr,
            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: ColorRes.green,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      LKey.startShopping.tr,
                      style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.whitePure),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              LKey.productsYouMayLike.tr,
              style: TextStyleCustom.unboundedBold700(fontSize: 18, color: ColorRes.textDarkGrey),
            ),
          ),
          const SizedBox(height: 16),
          _buildProductsYouMayLike(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyCartIllustration() {
    return SizedBox(
      height: 200,
      child: Image.asset(
        AssetRes.emptyCart,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildProductsYouMayLike() {
    if (_loadingFeatureProducts) {
      return const SizedBox(
        height: 268,
        child: Center(
          child: CircularProgressIndicator(color: ColorRes.green),
        ),
      );
    }
    if (_featureProducts.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 268,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featureProducts.length,
        itemBuilder: (context, index) {
          final product = _featureProducts[index];
          return _EmptyCartProductCard(product: product);
        },
      ),
    );
  }

  Widget _buildCartItems(CartController cart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cart.items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: ColorRes.borderLight),
        itemBuilder: (context, index) {
          final item = cart.items[index];
          final product = item.product;
          final variant = item.variantText ??
              (product.isNetworkImage
                  ? 'Standard'
                  : (product.id == '2' ? '${LKey.sizeLabel.tr}: M' : '${LKey.colorLabel.tr}: Black'));
          final price = product.price ?? '\$0';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _cartProductImage(product, 72, 72),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: TextStyleCustom.outFitSemiBold600(fontSize: 15, color: ColorRes.textDarkGrey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        variant,
                        style: TextStyleCustom.outFitRegular400(fontSize: 13, color: ColorRes.textLightGrey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            price,
                            style: TextStyleCustom.outFitSemiBold600(fontSize: 15, color: ColorRes.textDarkGrey),
                          ),
                          _quantityControl(cart, product.id, item.quantity, item.variantId),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quantityControl(CartController cart, String productId, int quantity, int? variantId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorRes.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _onDecrementQuantity(cart, productId, variantId),
            customBorder: const CircleBorder(),
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: ColorRes.textLightGrey, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.remove, size: 16, color: ColorRes.whitePure),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              quantity.toString().padLeft(2, '0'),
              style: TextStyleCustom.outFitSemiBold600(fontSize: 14, color: ColorRes.textDarkGrey),
            ),
          ),
          InkWell(
            onTap: () => _onIncrementQuantity(cart, productId, variantId),
            customBorder: const CircleBorder(),
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: ColorRes.green, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.add, size: 16, color: ColorRes.whitePure),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelivery() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LKey.delivery.tr,
                        style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.textDarkGrey),
                      ),
                    ),

                  ],
                ),
                Text(
                  LKey.regularDelivery.tr,
                  style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
                ),
                Text(
                  LKey.deliveryDays.tr,
                  style: TextStyleCustom.outFitRegular400(fontSize: 13, color: ColorRes.textLightGrey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(top: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  LKey.edit.tr,
                  style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
                ),
              ),
              Text(
                '\$10',
                style: TextStyleCustom.outFitSemiBold600(fontSize: 15, color: ColorRes.textDarkGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddress() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LKey.address.tr,
            style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.textDarkGrey),
          ),
          const SizedBox(height: 6),
          Text(
            '95 Kelampok Kasri 4037 Milan, Italy',
            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildPayment() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                LKey.payment.tr,
                style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.textDarkGrey),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  LKey.edit.tr,
                  style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
                ),
              ),
            ],
          ),
          Text(
            LKey.mastercard.tr,
            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
          ),
          Text(
            '9432 **** **** ****',
            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
          ),
          const SizedBox(height: 4),
          Text(
            LKey.cardholderName.tr,
            style: TextStyleCustom.outFitSemiBold600(fontSize: 13, color: ColorRes.textDarkGrey),
          ),
          Text(
            'Mariah Johana',
            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: ColorRes.borderLight, thickness: 1);
  }

  Widget _buildCoupon(CartController cart) {
    final applied = cart.appliedCouponCode.value.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorRes.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LKey.couponCode.tr,
            style: TextStyleCustom.outFitSemiBold600(fontSize: 14, color: ColorRes.textDarkGrey),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  enabled: !_applyingCoupon,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
                  decoration: InputDecoration(
                    hintText: LKey.yourCode.tr,
                    hintStyle: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _applyingCoupon ? null : () => _applyCoupon(cart),
                style: TextButton.styleFrom(
                  backgroundColor: ColorRes.green,
                  foregroundColor: ColorRes.whitePure,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _applyingCoupon
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: ColorRes.whitePure),
                      )
                    : Text(
                        LKey.applyCouponButton.tr,
                        style: TextStyleCustom.outFitSemiBold600(fontSize: 14, color: ColorRes.whitePure),
                      ),
              ),
            ],
          ),
          if (applied) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${LKey.couponApplied.tr}: ${cart.appliedCouponCode.value}',
                    style: TextStyleCustom.outFitRegular400(fontSize: 12, color: ColorRes.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    cart.clearCoupon();
                    _couponController.clear();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    LKey.cancel.tr,
                    style: TextStyleCustom.outFitRegular400(fontSize: 12, color: ColorRes.textLightGrey),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotal(CartController cart) {
    final discount = cart.couponDiscountAmount.value;
    final totalStr = '\$${cart.total.toStringAsFixed(0)}';
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (discount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LKey.discount.tr,
                  style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
                ),
                Text(
                  '-\$${discount.toStringAsFixed(0)}',
                  style: TextStyleCustom.outFitSemiBold600(fontSize: 14, color: ColorRes.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LKey.totalPrice.tr,
                      style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.textDarkGrey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LKey.includeTaxes.tr,
                      style: TextStyleCustom.outFitRegular400(fontSize: 13, color: ColorRes.textLightGrey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalStr,
                    style: TextStyleCustom.outFitSemiBold600(fontSize: 20, color: ColorRes.textDarkGrey),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      LKey.paymentDetails.tr,
                      style: TextStyleCustom.outFitRegular400(fontSize: 13, color: ColorRes.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckOutButton() {
    final cart = Get.find<CartController>();
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: ColorRes.green,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            cart.items.clear();
            Get.to(() => const OrderConfirmedScreen());
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                LKey.checkOut.tr,
                style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.whitePure),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCartProductCard extends StatelessWidget {
  final StoreProduct product;

  const _EmptyCartProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
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
                child: _cartProductImage(product, 160, 130),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2232),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: ColorRes.orange),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating}',
                        style: TextStyleCustom.outFitSemiBold600(fontSize: 11, color: ColorRes.whitePure),
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
