import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/auth_screen/auth_screen_controller.dart';
import 'package:stakBread/screen/auth_screen/login_screen.dart';
import 'package:stakBread/screen/auth_screen/registration_screen.dart';
import 'package:stakBread/screen/term_and_privacy_screen/term_and_privacy_screen.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class SignUpOptionsScreen extends StatelessWidget {
  const SignUpOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
             SizedBox(height: 100,),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Image.asset(
                      AssetRes.splash,
                      fit: BoxFit.contain,
                      height: 80,
                      errorBuilder: (_, __, ___) => const SizedBox(height: 80),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      LKey.signUpIntroText.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 15,
                        color: ColorRes.textLightGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.put(AuthScreenController());
                          Get.to(() => const RegistrationScreen());
                        },
                        icon: Icon(Icons.mail_outline_rounded, size: 22, color: ColorRes.whitePure),
                        label: Text(
                          LKey.useEmail.tr,
                          style: TextStyleCustom.outFitSemiBold600(
                            fontSize: 16,
                            color: ColorRes.whitePure,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorRes.green,
                          foregroundColor: ColorRes.whitePure,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      LKey.orText.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 14,
                        color: ColorRes.textLightGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SocialOptionBtn(
                      icon: AssetRes.icGoogle,
                      label: LKey.continueWithGoogle.tr,
                      onTap: () {
                        Get.put(AuthScreenController());
                        Get.find<AuthScreenController>().onGoogleTap();
                      },
                    ),
                    const SizedBox(height: 12),
                    if (Platform.isIOS)
                      _SocialOptionBtn(
                        icon: AssetRes.icApple,
                        label: LKey.continueWithApple.tr,
                        onTap: () {
                          Get.put(AuthScreenController());
                          Get.find<AuthScreenController>().onAppleTap();
                        },
                      ),
                    if (Platform.isIOS) const SizedBox(height: 12),
                    const SizedBox(height: 24),
                    _TermsText(),
                    const SizedBox(height: 28),
                    RichText(
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
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.to(() => const LoginScreen()),
                          ),
                        ],
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

class _SocialOptionBtn extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SocialOptionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorRes.textDarkGrey,
          side: const BorderSide(color: ColorRes.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyleCustom.outFitSemiBold600(
                fontSize: 16,
                color: ColorRes.textDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '${LKey.agreeToPolicyContinue.tr} ',
          style: TextStyleCustom.outFitRegular400(
            fontSize: 13,
            color: ColorRes.textLightGrey,
          ),
          children: [
            TextSpan(
              text: LKey.termsOfUse.tr,
              style: TextStyleCustom.outFitSemiBold600(
                fontSize: 13,
                color: ColorRes.textDarkGrey,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.to(() => const TermAndPrivacyScreen(
                        type: TermAndPrivacyType.termAndCondition,
                      ));
                },
            ),
            TextSpan(
              text: ' ${LKey.andText.tr} ',
              style: TextStyleCustom.outFitRegular400(
                fontSize: 13,
                color: ColorRes.textLightGrey,
              ),
            ),
            TextSpan(
              text: LKey.privacyPolicy.tr,
              style: TextStyleCustom.outFitSemiBold600(
                fontSize: 13,
                color: ColorRes.textDarkGrey,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Get.to(() => const TermAndPrivacyScreen(
                        type: TermAndPrivacyType.privacyPolicy,
                      ));
                },
            ),
          ],
        ),
      ),
    );
  }
}
