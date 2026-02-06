import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_toggle.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/create_feed_screen/create_feed_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class FeedCommentToggle extends StatelessWidget {
  const FeedCommentToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateFeedScreenController>();
    return Container(
      height: 47,
      color: ColorRes.bgLightGrey,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Image.asset(AssetRes.icComment, height: 22, width: 22, color: ColorRes.textDarkGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              LKey.allowComments.tr,
              style: TextStyleCustom.outFitLight300(fontSize: 15, color: ColorRes.textDarkGrey),
            ),
          ),
          CustomToggle(
              isOn: controller.canComment,
              onChanged: (value) {
                controller.commentHelper.detectableTextFocusNode.unfocus();
                controller.canComment.value = value;
              })
        ],
      ),
    );
  }
}
