import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/screen/splash_screen/splash_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenController());
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: Center(
        child: Image.asset(
          AssetRes.splash,
          fit: BoxFit.contain,
          width: 220,
          height: 220,
          errorBuilder: (_, __, ___) => const SizedBox(),
        ),
      ),
    );
  }
}
