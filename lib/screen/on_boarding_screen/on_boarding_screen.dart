import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/on_boarding_screen/on_boarding_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  static const List<String> _imageAssets = [
    AssetRes.onboarding1,
    AssetRes.onboarding2,
    AssetRes.onboarding3,
  ];

  static List<String> get _titles => [
        LKey.onboardingTitle.tr,
        LKey.onboardingTitle2.tr,
        LKey.onboardingTitle3.tr,
      ];

  static List<String> get _descriptions => [
        LKey.onboardingDesc.tr,
        LKey.onboardingDesc2.tr,
        LKey.onboardingDesc3.tr,
      ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingScreenController());
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Top: Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [

                  Image.asset(
                    AssetRes.icLogo,
                    fit: BoxFit.contain,
                    height: 35,
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: controller.onSkipTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: ColorRes.whitePure,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ColorRes.borderLight),
                      ),
                      child: Text(
                        LKey.skip.tr,
                        style: TextStyleCustom.outFitSemiBold600(
                          fontSize: 14,
                          color: ColorRes.textDarkGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content with blink (fade) transition
            Expanded(
              child: Obx(() {
                final index = controller.selectedPage.value;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Column(
                    key: ValueKey<int>(index),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            _imageAssets[index],
                            fit: BoxFit.contain,
                            height: 280,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              height: 280,
                              color: ColorRes.borderLight,
                              child: const Icon(Icons.image_not_supported, size: 48),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _titles[index],
                          style: TextStyleCustom.unboundedBlack900(
                            fontSize: 22,
                            color: ColorRes.textDarkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _descriptions[index],
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 15,
                            color: ColorRes.textLightGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: controller.onGetStartedTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorRes.green,
                        foregroundColor: ColorRes.whitePure,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        LKey.getStarted.tr,
                        style: TextStyleCustom.outFitSemiBold600(
                          fontSize: 16,
                          color: ColorRes.whitePure,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton(
                      onPressed: controller.onLoginTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorRes.textDarkGrey,
                        side: const BorderSide(color: ColorRes.textLightGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        LKey.logIn.tr,
                        style: TextStyleCustom.outFitSemiBold600(
                          fontSize: 16,
                          color: ColorRes.textDarkGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
