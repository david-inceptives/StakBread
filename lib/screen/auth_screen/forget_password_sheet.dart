import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/bottom_sheet_top_view.dart';
import 'package:stakBread/common/widget/privacy_policy_text.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/common/widget/text_field_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/auth_screen/auth_screen_controller.dart';
import 'package:stakBread/utilities/color_res.dart';

class ForgetPasswordSheet extends StatelessWidget {
  const ForgetPasswordSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthScreenController>();
    return Container(
      height: 400,
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2.5),
      decoration: ShapeDecoration(
          shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.vertical(
                  top: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1))),
          color: ColorRes.whitePure),
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            BottomSheetTopView(title: LKey.forgetPassword.tr),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextFieldCustom(
                      controller: controller.forgetEmailController,
                      title: LKey.email.tr,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextButtonCustom(
                        onTap: controller.forgetPassword,
                        title: LKey.forgetPassword.tr,
                        backgroundColor: ColorRes.green,
                        titleColor: ColorRes.whitePure,
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 15)),
                    const PrivacyPolicyText(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
