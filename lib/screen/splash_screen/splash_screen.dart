import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_shimmer_fill_text.dart';
import 'package:stakBread/common/widget/theme_blur_bg.dart';
import 'package:stakBread/screen/splash_screen/splash_screen_controller.dart';
import 'package:stakBread/utilities/app_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/theme_res.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenController());
    return Scaffold(
      body: Stack(
        children: [
          const ThemeBlurBg(),
          Align(
            alignment: Alignment.center,
            child: CustomShimmerFillText(
              text: AppRes.appName.toUpperCase(),
              baseColor: whitePure(context),
              textStyle: TextStyleCustom.unboundedBlack900(
                  color: whitePure(context), fontSize: 30),
              finalColor: whitePure(context),
              shimmerColor: themeAccentSolid(context),
            ),
          )
        ],
      ),
    );
  }
}
