import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/screen/camera_edit_screen/text_story/story_text_view_controller.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class StoryTextFontStyle extends StatelessWidget {
  const StoryTextFontStyle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoryTextViewController>();
    return Container(
      color: ColorRes.blackPure,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              controller.alignList.length,
              (index) {
                FontAlign align = controller.alignList[index];
                return InkWell(
                  onTap: () {
                    controller.selectedAlignment.value = align;
                  },
                  child: Obx(
                    () {
                      bool isSelected = controller.selectedAlignment.value == align;
                      return Icon(
                        align.icon,
                        color: isSelected ? ColorRes.whitePure : ColorRes.textLightGrey,
                        size: 30,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Align'.toUpperCase(),
            style: TextStyleCustom.outFitRegular400(color: ColorRes.whitePure, fontSize: 12),
          )
        ],
      ),
    );
  }
}
