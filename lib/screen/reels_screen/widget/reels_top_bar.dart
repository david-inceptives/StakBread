import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/widget/custom_back_button.dart';
import 'package:stakBread/screen/reels_screen/reels_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';

class ReelsTopBar extends StatelessWidget {
  final ReelsScreenController controller;
  final Widget? widget;

  const ReelsTopBar({super.key, required this.controller, this.widget});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (canPop || !controller.isHomePage)
                  CustomBackButton(
                    color: ColorRes.whitePure,
                    height: 30,
                    width: 30,
                    padding: EdgeInsets.zero,
                    image: AssetRes.icBackArrow_1,
                  )
                else
                  const SizedBox(width: 30, height: 30),
                if (widget != null) Flexible(child: widget!),
                Obx(() {
                  final reels = controller.reels;
                  final index = controller.currentIndex.value;
                  if (reels.isEmpty || index < 0 || index >= reels.length) {
                    return const SizedBox(width: 30, height: 30);
                  }
                  bool reportVisible =
                      reels[index].userId != SessionManager.instance.getUserID();
                  return Visibility(
                    visible: reportVisible,
                    replacement: const SizedBox(width: 30, height: 30),
                    child: InkWell(
                      onTap: controller.onReportTap,
                      child: Image.asset(
                        AssetRes.icAlert,
                        width: 30,
                        height: 30,
                        color: ColorRes.whitePure,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
