import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/extensions/common_extension.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/common/widget/loader_widget.dart';
import 'package:stakBread/common/widget/no_data_widget.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/gift_wallet/withdraw_model.dart';
import 'package:stakBread/screen/withdrawals_screen/withdrawals_screen_controller.dart';
import 'package:stakBread/utilities/app_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class WithdrawalsScreen extends StatelessWidget {
  const WithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawalsScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.withdrawals.tr),
          Expanded(child: Obx(
            () {
              return controller.isLoading.value && controller.withdraws.isEmpty
                  ? const LoaderWidget()
                  : NoDataView(
                      showShow: !controller.isLoading.value &&
                          controller.withdraws.isEmpty,
                      child: ListView.builder(
                        itemCount: controller.withdraws.length,
                        padding: const EdgeInsets.only(top: 1),
                        itemBuilder: (context, index) {
                          Withdraw withdraw = controller.withdraws[index];
                          Color statusColor = withdraw.status == 0
                              ? ColorRes.orange
                              : withdraw.status == 1
                                  ? ColorRes.green
                                  : ColorRes.likeRed;
                          return Container(
                            color: ColorRes.bgLightGrey,
                            margin: const EdgeInsets.symmetric(vertical: 1),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${AppRes.hash}${withdraw.requestNumber}',
                                              style: TextStyleCustom.unboundedSemiBold600(
                                                color: ColorRes.textDarkGrey,
                                              ),
                                            ),
                                            Text(
                                              '${withdraw.gateway} : ${withdraw.account}',
                                              style: TextStyleCustom.outFitLight300(
                                                  color: ColorRes.textLightGrey,
                                                  fontSize: 13),
                                            ),
                                            Text(
                                              (withdraw.createdAt ?? '')
                                                  .formatDate1,
                                              style: TextStyleCustom.outFitLight300(
                                                  color: ColorRes.textLightGrey,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            (double.parse(
                                                    withdraw.amount ?? '0'))
                                                .currencyFormat,
                                            style:
                                                TextStyleCustom.outFitBold700(
                                                    fontSize: 18,
                                                    color:
                                                        ColorRes.textDarkGrey),
                                          ),
                                          const SizedBox(height: 5),
                                          TextButtonCustom(
                                            onTap: () {},
                                            title: withdraw.status == 0
                                                ? LKey.pending.tr
                                                : withdraw.status == 1
                                                    ? LKey.completed.tr
                                                    : LKey.rejected.tr,
                                            btnHeight: 23,
                                            horizontalMargin: 0,
                                            radius: 5,
                                            fontSize: 12,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            backgroundColor: statusColor
                                                .withValues(alpha: .15),
                                            titleColor: statusColor,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: ColorRes.bgGrey,
                                  height: 29,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                      '${(withdraw.coins?.toInt() ?? 0).numberFormat} ${LKey.coins.tr} '
                                      ':'
                                      ' ${(withdraw.coinValue ?? 0).currencyFormat} / ${LKey.coin.tr}',
                                      style: TextStyleCustom.outFitLight300(
                                          color: ColorRes.textLightGrey)),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    );
            },
          ))
        ],
      ),
    );
  }
}
