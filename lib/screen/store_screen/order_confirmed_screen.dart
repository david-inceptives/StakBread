import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

import '../../common/widget/custom_app_bar.dart';
import '../../utilities/asset_res.dart';

class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: LKey.orderConfirmed.tr,
              titleStyle: TextStyleCustom.unboundedSemiBold600(fontSize: 18, color: ColorRes.textDarkGrey),
              bgColor: ColorRes.whitePure,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Color(0xffF5F6F8),

                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetRes.icSuccess,
                        fit: BoxFit.cover,
                        width: 120,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        LKey.yourOrderIsConfirmed.tr,
                        style: TextStyleCustom.unboundedMedium500(fontSize: 18, color: ColorRes.textDarkGrey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        LKey.orderConfirmedSubtext.tr,
                        style: TextStyleCustom.outFitRegular400(fontSize: 14, color: ColorRes.textLightGrey),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: ColorRes.green,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => Get.back(),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  LKey.done.tr,
                                  style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.whitePure),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
