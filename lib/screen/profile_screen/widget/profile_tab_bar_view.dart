import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/profile_screen/profile_screen_controller.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

import '../../../common/manager/session_manager.dart';
import '../../../model/user_model/user_model.dart';

class ProfileTabs extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfileTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    User? user = controller.profileController.user;
    bool isMe = user?.id == SessionManager.instance.getUserID();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  controller.userData.value?.checkIsBlocked(() {
                    controller.onTabChanged(0);
                    controller.pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Obx(() {
                        final selected = controller.selectedTabIndex.value == 0;
                        return Text(
                          isMe? LKey.posts.tr: LKey.reels.tr,
                          style: TextStyleCustom.unboundedSemiBold600(
                            fontSize: 15,
                            color: selected
                                ? ColorRes.textDarkGrey
                                : ColorRes.textLightGrey,
                          ),
                        );
                      }),
                    ),
                    Obx(() => Container(
                          height: controller.selectedTabIndex.value == 0 ? 3 : 0,
                          color: ColorRes.textDarkGrey,
                        )),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  controller.userData.value?.checkIsBlocked(() {
                    controller.onTabChanged(1);
                    controller.pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Obx(() {
                        final selected = controller.selectedTabIndex.value == 1;
                        return Text(
                          isMe? LKey.reels.tr: LKey.shop.tr,
                          style: TextStyleCustom.unboundedSemiBold600(
                            fontSize: 15,
                            color: selected
                                ? ColorRes.textDarkGrey
                                : ColorRes.textLightGrey,
                          ),
                        );
                      }),
                    ),
                    Obx(() => Container(
                          height: controller.selectedTabIndex.value == 1 ? 3 : 0,
                          color: ColorRes.textDarkGrey,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(height: 1, color: ColorRes.borderLight),
      ],
    );
  }
}
