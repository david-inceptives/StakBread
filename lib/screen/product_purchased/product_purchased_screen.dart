import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/product_purchased/model/purchased_order_model.dart';
import 'package:stakBread/screen/product_purchased/product_purchased_controller.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// My Orders (product purchased) screen with tabs: Pending, To Ship, Completed, Cancelled, Rejected.
/// Uses app colors only (ColorRes). Separate folder under order management concept.
class ProductPurchasedScreen extends StatelessWidget {
  const ProductPurchasedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductPurchasedController());
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(
              title: LKey.myOrders.tr,
              titleStyle: TextStyleCustom.unboundedBold700(
                fontSize: 18,
                color: ColorRes.textDarkGrey,
              ),
              bgColor: ColorRes.whitePure,
              iconColor: ColorRes.textDarkGrey,
            ),
            _PurchasedOrderTabs(controller: controller),
            Expanded(
              child: Obx(() {
                final status = controller.currentStatus;
                final orders = controller.ordersForStatus(status);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) => _PurchasedOrderCard(
                    order: orders[index],
                    controller: controller,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchasedOrderTabs extends StatelessWidget {
  final ProductPurchasedController controller;

  const _PurchasedOrderTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final labels = [
      LKey.pending.tr,
      LKey.toShip.tr,
      LKey.completed.tr,
      LKey.cancelled.tr,
      LKey.rejected.tr,
    ];
    return Obx(() {
      final index = controller.selectedTabIndex.value;
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (i) {
                final isSelected = i == index;
                return SizedBox(
                  width: 72,
                  child: InkWell(
                    onTap: () => controller.onTabTapped(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        children: [
                          Text(
                            labels[i],
                            style: TextStyleCustom.outFitSemiBold600(
                              fontSize: 13,
                              color: isSelected
                                  ? ColorRes.themeAccentSolid
                                  : ColorRes.textLightGrey,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ColorRes.themeAccentSolid
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            height: 1,
            color: ColorRes.borderLight,
          ),
        ],
      );
    });
  }
}

class _PurchasedOrderCard extends StatelessWidget {
  final PurchasedOrderModel order;
  final ProductPurchasedController controller;

  const _PurchasedOrderCard({
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorRes.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  order.productImagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: ColorRes.borderLight,
                    child: const Icon(
                      Icons.image_outlined,
                      color: ColorRes.textLightGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyleCustom.outFitSemiBold600(
                                fontSize: 14,
                                color: ColorRes.textDarkGrey,
                              ),
                              children: [
                                TextSpan(text: '${order.productName} '),
                                TextSpan(
                                  text: order.storeName,
                                  style: TextStyleCustom.outFitRegular400(
                                    fontSize: 14,
                                    color: ColorRes.textDarkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PurchasedStatusChip(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.description,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 12,
                        color: ColorRes.textLightGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((order.status == PurchasedOrderStatus.cancelled ||
                            order.status == PurchasedOrderStatus.rejected) &&
                        order.isReimbursed) ...[
                      const SizedBox(height: 6),
                      Text(
                        LKey.reimbursed.tr,
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 12,
                          color: ColorRes.textLightGrey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.price,
                          style: TextStyleCustom.outFitSemiBold600(
                            fontSize: 15,
                            color: ColorRes.textDarkGrey,
                          ),
                        ),
                        Text(
                          '${LKey.placedOn.tr} ${order.placedDate}',
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 11,
                            color: ColorRes.textLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.status == PurchasedOrderStatus.pending) ...[
            const SizedBox(height: 12),
            Text(
              LKey.pendingForApproval.tr,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 12,
                color: ColorRes.textLightGrey,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: LKey.reject.tr,
                    onPressed: () => controller.onReject(order),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: LKey.accept.tr,
                    onPressed: () => controller.onAccept(order),
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
          if (order.status == PurchasedOrderStatus.toShip) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: LKey.cancel.tr,
                    onPressed: () => controller.onCancelOrder(order),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: LKey.chat.tr,
                    onPressed: () => controller.onChat(order),
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
          if (order.status == PurchasedOrderStatus.completed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: LKey.report.tr,
                    onPressed: () => controller.onReport(order),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: LKey.review.tr,
                    onPressed: () => controller.onReview(order),
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PurchasedStatusChip extends StatelessWidget {
  final PurchasedOrderStatus status;

  const _PurchasedStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;
    switch (status) {
      case PurchasedOrderStatus.pending:
        label = LKey.pending.tr;
        bgColor = ColorRes.orange.withValues(alpha: 0.2);
        textColor = ColorRes.orange;
        break;
      case PurchasedOrderStatus.toShip:
        label = LKey.toShip.tr;
        bgColor = ColorRes.orange.withValues(alpha: 0.25);
        textColor = ColorRes.orange;
        break;
      case PurchasedOrderStatus.completed:
        label = LKey.received.tr;
        bgColor = ColorRes.green.withValues(alpha: 0.2);
        textColor = ColorRes.green;
        break;
      case PurchasedOrderStatus.cancelled:
        label = LKey.cancelled.tr;
        bgColor = ColorRes.likeRed.withValues(alpha: 0.25);
        textColor = ColorRes.likeRed;
        break;
      case PurchasedOrderStatus.rejected:
        label = LKey.rejected.tr;
        bgColor = ColorRes.likeRed.withValues(alpha: 0.25);
        textColor = ColorRes.likeRed;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyleCustom.outFitSemiBold600(
          fontSize: 11,
          color: textColor,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? ColorRes.themeAccentSolid : ColorRes.whitePure,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: filled ? null : Border.all(color: ColorRes.themeAccentSolid),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyleCustom.outFitSemiBold600(
                fontSize: 13,
                color: filled ? ColorRes.whitePure : ColorRes.themeAccentSolid,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
