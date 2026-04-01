import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/service/navigation/navigate_with_controller.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/common/widget/cancel_order_reason_dialog.dart';
import 'package:stakBread/common/widget/product_review_dialog.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/order/sold_order_model.dart';
import 'package:stakBread/screen/product_purchased/model/purchased_order_model.dart';

class ProductPurchasedController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxList<SoldOrder> purchasedOrders = <SoldOrder>[].obs;
  final RxBool loading = true.obs;
  final RxnString loadError = RxnString();

  static const List<PurchasedOrderStatus> tabStatuses = [
    PurchasedOrderStatus.pending,
    PurchasedOrderStatus.toShip,
    PurchasedOrderStatus.completed,
    PurchasedOrderStatus.cancelled,
    PurchasedOrderStatus.rejected,
  ];

  PurchasedOrderStatus get currentStatus => tabStatuses[selectedTabIndex.value];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    loading.value = true;
    loadError.value = null;
    try {
      final list = await StoreService.instance.fetchMyPurchasedOrders();
      purchasedOrders.assignAll(list);
    } catch (e) {
      loadError.value = e.toString().replaceFirst('Exception: ', '');
      purchasedOrders.clear();
    } finally {
      loading.value = false;
    }
  }

  List<PurchasedOrderModel> ordersForStatus(PurchasedOrderStatus status) {
    return purchasedOrders
        .where((o) => purchasedOrderStatusFromApi(o.statusRaw) == status)
        .map(PurchasedOrderModel.fromSoldOrder)
        .toList();
  }

  void onTabTapped(int index) {
    if (index < 0 || index >= tabStatuses.length) return;
    selectedTabIndex.value = index;
  }

  Future<void> onCancelOrder(PurchasedOrderModel order) async {
    final reason = await Get.dialog<String?>(
      const CancelOrderReasonDialog(),
      barrierDismissible: false,
    );

    if (reason == null) return;
    if (reason.isEmpty) {
      BaseController.share.showSnackBar(LKey.fieldRequired.tr);
      return;
    }

    BaseController.share.showLoader();
    try {
      final res = await StoreService.instance.cancelOrder(
        orderId: order.id,
        cancelReason: reason,
      );
      BaseController.share.stopLoader();
      if (res.status == true) {
        BaseController.share.showSnackBar(
          (res.message != null && res.message!.isNotEmpty)
              ? res.message
              : LKey.orderCancelledSuccess.tr,
        );
        await loadOrders();
      } else {
        BaseController.share.showSnackBar(
            res.message ?? LKey.somethingWentWrong.tr);
      }
    } catch (e) {
      BaseController.share.stopLoader();
      BaseController.share.showSnackBar(
          e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void onChat(PurchasedOrderModel order) {
    final uid = order.sellerUserId;
    if (uid == null || uid <= 0) {
      BaseController.share.showSnackBar(LKey.somethingWentWrong.tr);
      return;
    }
    NavigationService.shared.openChatWithUser(
      User(
        id: uid,
        fullname: order.sellerFullname,
        username: order.sellerUsername,
      ),
    );
  }

  Future<void> onReport(PurchasedOrderModel order) async {
    final pid = order.primaryProductId?.trim();
    if (pid == null || pid.isEmpty) {
      BaseController.share.showSnackBar(LKey.somethingWentWrong.tr);
      return;
    }

    final reason = await Get.dialog<String?>(
      CancelOrderReasonDialog(
        titleText: LKey.report.tr,
        hintText: LKey.provideReportReason.tr,
      ),
      barrierDismissible: false,
    );

    if (reason == null) return;
    if (reason.isEmpty) {
      BaseController.share.showSnackBar(LKey.fieldRequired.tr);
      return;
    }

    BaseController.share.showLoader();
    try {
      final res = await StoreService.instance.reportOrderProduct(
        productId: pid,
        reason: reason,
      );
      BaseController.share.stopLoader();
      if (res.status == true) {
        BaseController.share.showSnackBar(
          (res.message != null && res.message!.isNotEmpty)
              ? res.message
              : LKey.reportSubmitted.tr,
        );
      } else {
        BaseController.share.showSnackBar(
            res.message ?? LKey.somethingWentWrong.tr);
      }
    } catch (e) {
      BaseController.share.stopLoader();
      BaseController.share.showSnackBar(
          e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> onReview(PurchasedOrderModel order) async {
    final pid = order.primaryProductId?.trim();
    if (pid == null || pid.isEmpty) {
      BaseController.share.showSnackBar(LKey.somethingWentWrong.tr);
      return;
    }

    final result = await Get.dialog<ProductReviewDialogResult?>(
      const ProductReviewDialog(),
      barrierDismissible: false,
    );
    if (result == null) return;

    BaseController.share.showLoader();
    try {
      final res = await StoreService.instance.addProductReview(
        productId: pid,
        rating: result.rating,
        review: result.reviewText,
      );
      BaseController.share.stopLoader();
      if (res.status == true) {
        BaseController.share.showSnackBar(
          (res.message != null && res.message!.isNotEmpty)
              ? res.message
              : LKey.reviewSubmittedSuccess.tr,
        );
        await loadOrders();
      } else {
        BaseController.share.showSnackBar(
            res.message ?? LKey.somethingWentWrong.tr);
      }
    } catch (e) {
      BaseController.share.stopLoader();
      BaseController.share.showSnackBar(
          e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
