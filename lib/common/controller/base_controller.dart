import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/loader_widget.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class BaseController extends FullLifeCycleController {
  RxBool isLoading = false.obs;
  static final share = BaseController();

  void showLoader({bool barrierDismissible = true}) async {
    if (isLoading.value) return;
    if (Get.isSnackbarOpen) {
      Get.back();
    }
    isLoading.value = true;
    await Get.dialog(const LoaderWidget(),
        barrierDismissible: barrierDismissible);
    isLoading.value = false;
  }

  /// Pops only the loader dialog. Avoids [Get.back] here so we don’t hit GetX snackbar
  /// assertions when a snackbar was just shown or disposed.
  void stopLoader() {
    if (Get.isDialogOpen != true) return;
    try {
      final ctx = Get.overlayContext;
      if (ctx != null) {
        final nav = Navigator.of(ctx, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
          return;
        }
      }
    } catch (_) {}
    if (Get.isDialogOpen == true) {
      Get.back(closeOverlays: false);
    }
  }

  void showSnackBar(String? title, {int second = 2}) {
    if (Get.isSnackbarOpen) {
      return;
    }

    Get.rawSnackbar(
      backgroundColor: ColorRes.blackPure,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(15),
      borderRadius: 10,
      isDismissible: true,
      duration: Duration(seconds: second),
      snackPosition: SnackPosition.TOP,
      messageText: Text(title?.capitalizeFirst?.tr ?? '',
          style: TextStyleCustom.outFitRegular400(
              color: ColorRes.whitePure, fontSize: 17)),
    );
  }

  /// Compact white pill, centered, rounded border — for subtle confirmations (e.g. refreshed).
  void showSmallCenterToast(String? message, {int second = 1}) {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
    final ctx = Get.context;
    final topInset = ctx != null ? MediaQuery.paddingOf(ctx).top + 8 : 48.0;

    Get.rawSnackbar(
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.only(top: topInset, left: 24, right: 24),
      padding: EdgeInsets.zero,
      isDismissible: true,
      duration: Duration(seconds: second),
      snackPosition: SnackPosition.TOP,
      messageText: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: ColorRes.whitePure,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ColorRes.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message?.capitalizeFirst?.tr ?? '',
            textAlign: TextAlign.center,
            style: TextStyleCustom.outFitRegular400(
              color: ColorRes.textDarkGrey,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void stopSnackBar() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }
}
