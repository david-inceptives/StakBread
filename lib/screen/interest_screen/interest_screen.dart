import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/interest_screen/interest_screen_controller.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class InterestScreen extends StatelessWidget {
  final User? myUser;

  const InterestScreen({super.key, this.myUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InterestScreenController(myUser: myUser));
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      LKey.selectTopicThatInterestYou.tr,
                      style: TextStyleCustom.unboundedSemiBold600(
                        fontSize: 22,
                        color: ColorRes.textDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LKey.chooseInterestsDescription.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 15,
                        color: ColorRes.textLightGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildChipGrid(controller),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(InterestScreenController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => controller.onMaybeLater(),
                icon: const Icon(Icons.arrow_back_ios_new, color: ColorRes.textDarkGrey, size: 22),
              ),
              Expanded(
                child: Text(
                  LKey.interest.tr,
                  style: TextStyleCustom.outFitSemiBold600(
                    fontSize: 18,
                    color: ColorRes.textDarkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const int currentStep = InterestScreenController.currentStep;
    const int totalSteps = InterestScreenController.totalSteps;
    return Row(
      children: List.generate(totalSteps, (index) {
        final isFilled = index < currentStep;
        final isCurrent = index == currentStep - 1;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isFilled
                  ? (isCurrent ? ColorRes.themeAccentSolid.withValues(alpha: 0.5) : ColorRes.themeAccentSolid)
                  : ColorRes.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChipGrid(InterestScreenController controller) {
    return GetBuilder<InterestScreenController>(
      builder: (_) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: controller.interestItems.map((item) {
            final selected = controller.isSelected(item.id);
            return _InterestChip(
              item: item,
              selected: selected,
              onTap: () => controller.toggleSelection(item.id),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBottomButtons(InterestScreenController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorRes.themeAccentSolid,
                foregroundColor: ColorRes.whitePure,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                LKey.continueText.tr,
                style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.whitePure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: controller.onMaybeLater,
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorRes.textDarkGrey,
                side: BorderSide(color: ColorRes.borderLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                LKey.maybeLater.tr,
                style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.textDarkGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final InterestItem item;
  final bool selected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? ColorRes.themeAccentSolid : ColorRes.borderLight,
              width: selected ? 1 : 1,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.imagePath != null)
                Image.asset(
                  item.imagePath!,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  colorBlendMode: selected ? BlendMode.srcIn : null,
                )
              else if (item.icon != null)
                Icon(
                  item.icon,
                  size: 20,
                  color:   ColorRes.textDarkGrey,
                ),
              if (item.imagePath != null || item.icon != null) const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 14,
                  color:   ColorRes.textDarkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
