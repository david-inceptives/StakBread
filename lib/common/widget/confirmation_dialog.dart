import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class ConfirmationSheet extends StatelessWidget {
  final String title;
  final String description;
  final String? description2;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final bool isDismissible;
  final String? positiveText;

  const ConfirmationSheet({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.description2,
    this.positiveText,
    this.onClose,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          decoration: ShapeDecoration(
              shape: const SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.vertical(
                      top: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1))),
              color: ColorRes.whitePure),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        height: 1,
                        width: 100,
                        color: ColorRes.bgGrey,
                        margin: const EdgeInsets.only(top: 10)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(title,
                            style: TextStyleCustom.unboundedMedium500(
                                color: ColorRes.textDarkGrey, fontSize: 15)),
                      ),
                      if (isDismissible)
                        InkWell(
                          onTap: onClose ??
                              () {
                                Get.back();
                              },
                          child: Icon(Icons.close_rounded,
                              color: ColorRes.textDarkGrey, size: 25),
                        )
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    '$description\n\n${description2 ?? LKey.proceedConfirmation.tr}',
                    style: TextStyleCustom.outFitLight300(
                        fontSize: 16, color: ColorRes.textLightGrey),
                  ),
                  const SizedBox(height: 50),
                  TextButtonCustom(
                    onTap: () {
                      Get.back();
                      onTap();
                    },
                    title: positiveText ?? LKey.continueText.tr,
                    backgroundColor: ColorRes.textDarkGrey,
                    margin: EdgeInsets.zero,
                    titleColor: ColorRes.whitePure,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
