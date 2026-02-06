import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class StoryTextFontOpacity extends StatelessWidget {
  final RxDouble progressValue;
  final double min;
  final double max;

  const StoryTextFontOpacity(
      {super.key, required this.progressValue, required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.blackPure,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Obx(
        () => Column(
          children: [
            Text(
              '${(((progressValue.value - min) / (max - min)) * 100).toInt()}%',
              style: TextStyleCustom.outFitRegular400(color: ColorRes.whitePure, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Slider(
              value: progressValue.value,
              min: min,
              max: max,
              activeColor: ColorRes.whitePure,
              inactiveColor: ColorRes.textDarkGrey,
              onChanged: (value) {
                progressValue.value = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
