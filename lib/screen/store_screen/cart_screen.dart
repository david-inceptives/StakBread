import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/store_screen/cart_controller.dart';
import 'package:stakBread/screen/store_screen/order_confirmed_screen.dart';
import 'package:stakBread/screen/store_screen/product_detail_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../../common/widget/custom_app_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
              titleStyle: TextStyleCustom.unboundedSemiBold600(fontSize: 18, color: ColorRes.textDarkGrey),
              bgColor: const Color(0xFFF5F6F8),
              rowWidget: IconButton(
                icon: Icon(Icons.more_horiz, color: ColorRes.textDarkGrey, size: 24),
                onPressed: () {},
              ),
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
                      _buildCoupon(),
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
    final store = Get.isRegistered<StoreScreenController>() ? Get.find<StoreScreenController>() : null;
    final products = store?.productsForYou ?? [];
    if (products.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 268,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
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
          final imagePath = product.imagePath ?? '';
          final variant = item.variantText ?? (product.id == '2' ? '${LKey.sizeLabel.tr}: M' : '${LKey.colorLabel.tr}: Black');
          final price = product.price ?? '\$0';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imagePath.isNotEmpty
                      ? Image.asset(imagePath, width: 72, height: 72, fit: BoxFit.cover)
                      : Container(width: 72, height: 72, color: ColorRes.borderLight),
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
                          _quantityControl(cart, product.id, item.quantity),
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

  Widget _quantityControl(CartController cart, String productId, int quantity) {
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
            onTap: () => cart.decrementQuantity(productId),
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
            onTap: () => cart.incrementQuantity(productId),
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

  Widget _buildCoupon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorRes.borderLight),
      ),
      child: Row(
        children: [
          Text(
            LKey.couponCode.tr,
            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textDarkGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              LKey.yourCode.tr,
              style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(CartController cart) {
    final totalStr = '\$${cart.total.toStringAsFixed(0)}';
    return Container(
      color: Colors.transparent,
      child: Row(
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
                    : Container(width: 160, height: 130, color: ColorRes.borderLight, child: const Icon(Icons.image_outlined, size: 40, color: ColorRes.textLightGrey)),
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
