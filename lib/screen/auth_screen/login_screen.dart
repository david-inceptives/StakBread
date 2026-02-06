import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/common/widget/privacy_policy_text.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/auth_screen/auth_screen_controller.dart';
import 'package:stakBread/screen/auth_screen/forget_password_sheet.dart';
import 'package:stakBread/screen/auth_screen/registration_screen.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthScreenController());
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: LKey.logIn.tr,
              bgColor: ColorRes.whitePure,
              iconColor: ColorRes.textDarkGrey,
              rowWidget: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox()
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
                      LKey.welcomeBack.tr,
                      style: TextStyleCustom.unboundedExtraBold800(
                        fontSize: 28,
                        color: ColorRes.textDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LKey.welcomeBackDesc.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 15,
                        color: ColorRes.textLightGrey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    LoginSheetTextField(
                      hintText: LKey.emailOrUsername.tr,
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    LoginSheetTextField(
                      isPasswordField: true,
                      hintText: LKey.enterPassword.tr,
                      controller: controller.passwordController,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () =>
                              controller.rememberMe.toggle(),
                          child: Row(
                            children: [
                              Obx(
                                () => SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: controller.rememberMe.value,
                                    onChanged: (_) =>
                                        controller.rememberMe.toggle(),
                                    activeColor: ColorRes.themeAccentSolid,
                                    side: BorderSide(
                                        color: ColorRes.textLightGrey,
                                        width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                LKey.rememberMe.tr,
                                style: TextStyleCustom.outFitRegular400(
                                  fontSize: 14,
                                  color: ColorRes.textLightGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.bottomSheet(const ForgetPasswordSheet(),
                                    isScrollControlled: true)
                                .then((_) =>
                                    controller.forgetEmailController.clear());
                          },
                          child: Text(
                            LKey.forgetPassword.tr,
                            style: TextStyleCustom.outFitSemiBold600(
                              fontSize: 14,
                              color: ColorRes.textDarkGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    TextButtonCustom(
                      onTap: controller.onLogin,
                      title: LKey.logIn.tr,
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
                            LKey.orSignInWith.tr,
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
                      onTap: () {
                        controller.fullNameController.clear();
                        controller.emailController.clear();
                        controller.passwordController.clear();
                        controller.confirmPassController.clear();
                        Get.to(() => const RegistrationScreen());
                      },
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: '${LKey.dontHaveAccount.tr} ',
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 15,
                              color: ColorRes.textLightGrey,
                            ),
                            children: [
                              TextSpan(
                                text: LKey.createAccount.tr,
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

class LoginSheetTextField extends StatefulWidget {
  final bool isPasswordField;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const LoginSheetTextField({
    super.key,
    this.isPasswordField = false,
    required this.hintText,
    required this.controller,
    this.keyboardType,
  });

  @override
  State<LoginSheetTextField> createState() => _LoginSheetTextFieldState();
}

class _LoginSheetTextFieldState extends State<LoginSheetTextField> {
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
                      isHide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 22,
                      color: ColorRes.textLightGrey,
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
        cursorColor: ColorRes.themeAccentSolid,
      ),
    );
  }
}

class SocialBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final double? size;
  final double? iconSize;

  const SocialBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? 56.0;
    final i = iconSize ?? 28.0;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: s,
        width: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorRes.whitePure,
          border: Border.all(color: ColorRes.borderLight, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Image.asset(icon, height: i, width: i),
      ),
    );
  }
}
