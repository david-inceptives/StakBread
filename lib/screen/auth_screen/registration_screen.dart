import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/common/widget/privacy_policy_text.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/auth_screen/auth_screen_controller.dart';
import 'package:stakBread/screen/auth_screen/login_screen.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthScreenController>();

    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: LKey.register.tr,
              bgColor: ColorRes.whitePure,
              iconColor: ColorRes.textDarkGrey,
              rowWidget: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorRes.borderLight),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 22,
                    color: ColorRes.textDarkGrey,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    Text(
                      LKey.createYourAccount.tr,
                      style: TextStyleCustom.unboundedExtraBold800(
                        fontSize: 28,
                        color: ColorRes.textDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LKey.registerNowDesc.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 15,
                        color: ColorRes.textLightGrey,
                      ),
                    ),
                    const SizedBox(height: 28),
                    RegTextField(
                      hintText: LKey.enterFullName.tr,
                      controller: controller.fullNameController,
                    ),
                    const SizedBox(height: 16),
                    RegTextField(
                      hintText: LKey.enterYourEmail.tr,
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    RegTextField(
                      isPasswordField: true,
                      hintText: LKey.enterPassword.tr,
                      controller: controller.passwordController,
                    ),
                    const SizedBox(height: 16),
                    RegTextField(
                      isPasswordField: true,
                      hintText: LKey.reTypePassword.tr,
                      controller: controller.confirmPassController,
                    ),
                    const SizedBox(height: 28),
                    TextButtonCustom(
                      onTap: controller.onCreateAccount,
                      title: LKey.createAccount.tr,
                      btnHeight: 54,
                      horizontalMargin: 0,
                      backgroundColor: ColorRes.themeAccentSolid,
                      titleColor: ColorRes.whitePure,
                      radius: 14,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                                height: 1,
                                color: ColorRes.borderLight)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            LKey.orRegisterWith.tr,
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 14,
                              color: ColorRes.textLightGrey,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                                height: 1, color: ColorRes.borderLight)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (Platform.isIOS) ...[
                          SocialBtn(
                            onTap: controller.onAppleTap,
                            icon: AssetRes.icApple,
                          ),
                          const SizedBox(width: 16),
                        ],
                        SocialBtn(
                          onTap: controller.onGoogleTap,
                          icon: AssetRes.icGoogle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    PrivacyPolicyText(
                      regularTextColor: ColorRes.textLightGrey,
                      boldTextColor: ColorRes.textDarkGrey,
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () => Get.back(),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: '${LKey.alreadyHaveAccount.tr} ',
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 15,
                              color: ColorRes.textLightGrey,
                            ),
                            children: [
                              TextSpan(
                                text: LKey.logIn.tr,
                                style: TextStyleCustom.outFitSemiBold600(
                                  fontSize: 15,
                                  color: ColorRes.textDarkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegTextField extends StatefulWidget {
  final bool isPasswordField;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const RegTextField({
    super.key,
    this.isPasswordField = false,
    required this.hintText,
    required this.controller,
    this.keyboardType,
  });

  @override
  State<RegTextField> createState() => _RegTextFieldState();
}

class _RegTextFieldState extends State<RegTextField> {
  bool isHide = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorRes.borderLight, width: 1),
      ),
      child: TextField(
        controller: widget.controller,
        style: TextStyleCustom.outFitRegular400(
          color: ColorRes.textDarkGrey,
          fontSize: 16,
        ),
        onTapOutside: (event) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        obscureText: widget.isPasswordField && isHide,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: widget.hintText,
          hintStyle: TextStyleCustom.outFitRegular400(
            color: ColorRes.textLightGrey,
            fontSize: 16,
          ),
          filled: false,
          suffixIcon: widget.isPasswordField
              ? InkWell(
                  onTap: () {
                    isHide = !isHide;
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isHide
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 22,
                      color: ColorRes.textLightGrey,
                    ),
                  ),
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
        cursorColor: ColorRes.themeAccentSolid,
      ),
    );
  }
}
