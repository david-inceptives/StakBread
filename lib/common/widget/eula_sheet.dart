import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/widget/eula_policy_for_apple.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/utilities/color_res.dart';

class EulaSheet extends StatelessWidget {
  const EulaSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2),
      decoration: ShapeDecoration(
          color: ColorRes.whitePure,
          shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.vertical(
                  top: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1)))),
      child: Column(
        children: [
          const Expanded(
              child: ClipRRect(
                  borderRadius: SmoothBorderRadius.vertical(
                      top: SmoothRadius(cornerRadius: 30, cornerSmoothing: 1)),
                  child: EulaPolicyForApple())),
          SafeArea(
            top: false,
            child: TextButtonCustom(
              onTap: () {
                SessionManager.instance.setOpenEulaSheet(false);
                Get.back();
              },
              title: LKey.accept.tr,
              titleColor: ColorRes.whitePure,
              backgroundColor: ColorRes.themeColor,
            ),
          )
        ],
      ),
    );
  }
}
