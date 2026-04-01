import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/sold_products/model/order_item_model.dart';
import 'package:stakBread/screen/sold_products/order_management_controller.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Orders Management (sold): POST `order/fetchMySoldOrders`, tabs by status.
class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderManagementController());
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(
              title: LKey.ordersManagement.tr,
              titleStyle: TextStyleCustom.unboundedBold700(
                fontSize: 18,
                color: ColorRes.textDarkGrey,
              ),
              bgColor: ColorRes.whitePure,
              iconColor: ColorRes.textDarkGrey,
            ),
            _OrderTabs(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final err = controller.loadError.value;
                if (err != null && err.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            err,
                            textAlign: TextAlign.center,
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 14,
                              color: ColorRes.textLightGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => controller.loadOrders(),
                            child: Text(LKey.retry.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final status = controller.currentStatus;
                final orders = controller.ordersForStatus(status);
                if (orders.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => controller.loadOrders(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  onRefresh: () => controller.loadOrders(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: orders.length,
                    itemBuilder: (context, index) => _OrderCard(
                      order: orders[index],
                      controller: controller,
                    ),
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

class _OrderThumbnail extends StatelessWidget {
  final OrderItemModel order;

  const _OrderThumbnail({required this.order});

  @override
  Widget build(BuildContext context) {
    final url = order.networkImageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 80,
            height: 80,
            color: ColorRes.borderLight,
          ),
          errorWidget: (_, __, ___) => Container(
            width: 80,
            height: 80,
            color: ColorRes.borderLight,
            child: const Icon(Icons.image_outlined, color: ColorRes.textLightGrey),
          ),
        ),
      );
    }
    if (order.productImagePath.isNotEmpty) {
      return ClipRRect(
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
            child: const Icon(Icons.image_outlined, color: ColorRes.textLightGrey),
          ),
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: ColorRes.borderLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shopping_bag_outlined, color: ColorRes.textLightGrey),
    );
  }
}

class _OrderTabs extends StatelessWidget {
  final OrderManagementController controller;

  const _OrderTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    final labels = [
      LKey.pending.tr,
      LKey.toShip.tr,
      LKey.completed.tr,
      LKey.rejected.tr,
      LKey.cancelled.tr,
    ];
    return Obx(() {
      final index = controller.selectedTabIndex.value;
      final n = OrderManagementController.tabStatuses.length;
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(n, (i) {
                final isSelected = i == index;
                return InkWell(
                  onTap: () => controller.onTabTapped(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          labels[i],
                          style: TextStyleCustom.outFitSemiBold600(
                            fontSize: 13,
                            color: isSelected
                                ? ColorRes.themeAccentSolid
                                : ColorRes.textLightGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 3,
                          width: 48,
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

class _OrderCard extends StatelessWidget {
  final OrderItemModel order;
  final OrderManagementController controller;

  const _OrderCard({
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
              _OrderThumbnail(order: order),
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
                        if (order.status == OrderStatus.toShip)
                          _ToShipStatusMenuChip(
                            order: order,
                            controller: controller,
                          )
                        else
                          _StatusChip(status: order.status),
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
                    if (order.status == OrderStatus.rejected && order.isReimbursed) ...[
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
          if (order.status == OrderStatus.pending) ...[
            const SizedBox(height: 12),
            _buildPendingApproval(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FullWidthButton(
                    label: LKey.reject.tr,
                    onPressed: () => controller.onRejectPendingOrder(order),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FullWidthButton(
                    label: LKey.accept.tr,
                    onPressed: () => controller.onAcceptPendingOrder(order),
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
          if (order.status == OrderStatus.toShip) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FullWidthButton(
                    label: LKey.cancel.tr,
                    onPressed: () => controller.onCancelOrder(order),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FullWidthButton(
                    label: LKey.chat.tr,
                    onPressed: () => controller.onChat(order),
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
          if (order.status == OrderStatus.completed) ...[
            const SizedBox(height: 12),
            _FullWidthButton(
              label: LKey.review.tr,
              onPressed: () => controller.onReview(order),
              filled: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingApproval() {
    return Text(
      LKey.pendingForApproval.tr,
      style: TextStyleCustom.outFitRegular400(
        fontSize: 12,
        color: ColorRes.textLightGrey,
      ),
    );
  }
}

/// To Ship row: status chip opens menu with **Complete order** (seller API).
class _ToShipStatusMenuChip extends StatelessWidget {
  final OrderItemModel order;
  final OrderManagementController controller;

  const _ToShipStatusMenuChip({
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        if (value == 'complete') {
          controller.onToShipCompleteOrder(order);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem<String>(
          value: 'complete',
          child: Text(
            LKey.completeOrder.tr,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 15,
              color: ColorRes.textDarkGrey,
            ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: ColorRes.orange.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LKey.toShip.tr,
              style: TextStyleCustom.outFitSemiBold600(
                fontSize: 11,
                color: ColorRes.orange,
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: ColorRes.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;
    switch (status) {
      case OrderStatus.pending:
        label = LKey.pending.tr;
        bgColor = ColorRes.orange.withValues(alpha: 0.2);
        textColor = ColorRes.orange;
        break;
      case OrderStatus.toShip:
        label = LKey.toShip.tr;
        bgColor = ColorRes.orange.withValues(alpha: 0.25);
        textColor = ColorRes.orange;
        break;
      case OrderStatus.completed:
        label = LKey.completed.tr;
        bgColor = ColorRes.green.withValues(alpha: 0.2);
        textColor = ColorRes.green;
        break;
      case OrderStatus.rejected:
        label = LKey.rejected.tr;
        bgColor = ColorRes.likeRed.withValues(alpha: 0.25);
        textColor = ColorRes.likeRed;
        break;
      case OrderStatus.cancelled:
        label = LKey.cancelled.tr;
        bgColor = ColorRes.textLightGrey.withValues(alpha: 0.25);
        textColor = ColorRes.textDarkGrey;
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

class _FullWidthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  const _FullWidthButton({
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
