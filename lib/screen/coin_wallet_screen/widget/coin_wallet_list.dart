import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/coin_wallet_screen/coin_wallet_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class CoinWalletList extends StatelessWidget {
  final CoinWalletScreenController controller;

  const CoinWalletList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(
        () {
          return ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            itemCount: controller.coinPlans.length,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              CoinPlan data = controller.coinPlans[index];
              return Container(
                height: 70,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                        side: BorderSide(
                          color: ColorRes.textLightGrey.withValues(alpha: .2),
                        )),
                    color: ColorRes.bgLightGrey),
                child: Row(
                  children: [
                    Image.asset(AssetRes.icCoin, width: 34, height: 34),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${data.coin} ${LKey.coins.tr}',
                            style: TextStyleCustom.unboundedMedium500(
                                color: ColorRes.textDarkGrey, fontSize: 15)),
                        Text('${data.priceString} ${LKey.only.tr}',
                            style: TextStyleCustom.outFitRegular400(color: ColorRes.textLightGrey)),
                      ],
                    )),
                    TextButtonCustom(
                        onTap: () => controller.onPurchase(data),
                        title: LKey.purchase.tr,
                        backgroundColor: ColorRes.themeAccentSolid,
                        btnHeight: 40,
                        fontSize: 15,
                        titleColor: ColorRes.whitePure,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        horizontalMargin: 0)
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
