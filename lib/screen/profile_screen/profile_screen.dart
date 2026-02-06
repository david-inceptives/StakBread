import 'dart:ui';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/widget/custom_back_button.dart';
import 'package:stakBread/common/widget/my_refresh_indicator.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:stakBread/screen/message_screen/message_screen.dart';
import 'package:stakBread/screen/notification_screen/notification_screen.dart';
import 'package:stakBread/screen/profile_screen/profile_screen_controller.dart';
import 'package:stakBread/screen/profile_screen/widget/profile_page_view.dart';
import 'package:stakBread/screen/profile_screen/widget/profile_tab_bar_view.dart';
import 'package:stakBread/screen/profile_screen/widget/profile_user_header.dart';
import 'package:stakBread/screen/search_screen/search_screen.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

import '../../utilities/asset_res.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  final bool isTopBarVisible;
  final bool isDashBoard;
  final Function(User? user)? onUserUpdate;

  const ProfileScreen(
      {super.key,
      this.user,
      this.isTopBarVisible = true,
      this.isDashBoard = false,
      this.onUserUpdate});

  @override
  Widget build(BuildContext context) {
    ProfileScreenController controller = Get.put(
        ProfileScreenController(user.obs, onUserUpdate),
        tag: isDashBoard
            ? ProfileScreenController.tag
            : "${DateTime.now().millisecondsSinceEpoch}");

    return Scaffold(
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          controller.adsController
              .showInterstitialAdIfAvailable(isPopScope: true);
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              isTopBarVisible
                  ? Obx(() => _TopViewForOtherUser(
                      user: controller.userData.value,
                      controller: controller))
                  : _ProfileTopBar(controller: controller),
              Expanded(
                child: Stack(
                  children: [
                    DefaultTabController(
                      length: 2,
                      child: MyRefreshIndicator(
                        depth: 2,
                        onRefresh: controller.onRefresh,
                        child: NestedScrollView(
                          headerSliverBuilder: (context, _) {
                            return [
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  ProfileUserHeader(controller: controller)
                                ]),
                              ),
                            ];
                          },
                          body: Column(
                            children: [
                              ProfileTabs(controller: controller),
                              ProfilePageView(controller: controller)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      User? user = controller.userData.value;
                      if (user?.isFreez != 1) {
                        return const SizedBox();
                      }
                      return Container(
                        color: ColorRes.whitePure
                            .withValues(alpha: 0.4),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_person_rounded,
                                    size: 80, color: ColorRes.textLightGrey),
                                const SizedBox(height: 20),
                                Text(
                                  LKey.profileUnavailable.tr,
                                  style: TextStyleCustom.unboundedSemiBold600(
                                      color: ColorRes.textLightGrey,
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30.0),
                                  child: Text(
                                    LKey.profileTemporarilyFrozen.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyleCustom.outFitMedium500(
                                        color: ColorRes.textLightGrey,
                                        fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Obx(() {
                                  bool isModerator = SessionManager
                                          .instance.isModerator.value ==
                                      1;
                                  if (!isModerator) {
                                    return const SizedBox();
                                  }
                                  return TextButtonCustom(
                                    onTap: () =>
                                        controller.freezeUnfreezeUser(true),
                                    title: LKey.unFreeze.tr,
                                    titleColor: ColorRes.whitePure,
                                    backgroundColor: ColorRes.textDarkGrey,
                                  );
                                })
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopViewForOtherUser extends StatelessWidget {
  final User? user;
  final ProfileScreenController controller;

  const _TopViewForOtherUser({this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomBackButton(
          onTap: () {
            controller.adsController.showInterstitialAdIfAvailable();
          },
          padding: const EdgeInsets.all(15),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              user?.username ?? '',
              style: TextStyleCustom.unboundedMedium500(
                  color: ColorRes.textDarkGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 18 + 30),
      ],
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  final ProfileScreenController controller;

  const _ProfileTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    int notifCount = 0;
    int messageCount = 0;
    if (Get.isRegistered<DashboardScreenController>()) {
      final dash = Get.find<DashboardScreenController>();
      notifCount = dash.requestUnReadCount.value;
      messageCount = dash.unReadCount.value;
    }
    return Container(
      color: ColorRes.whitePure,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Get.to(() => const SearchScreen()),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF5F6F8),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(cornerRadius: 12),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          LKey.search.tr,
                          style: TextStyleCustom.outFitRegular400(
                            color: ColorRes.textLightGrey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: ColorRes.textLightGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _NotificationIcon(
              icon:  AssetRes.icNotification,
              count: notifCount,
              onTap: () => Get.to(() => const NotificationScreen()),
            ),
            const SizedBox(width: 8),
            _NotificationIcon(
              icon:  AssetRes.icMessage,
              count: messageCount,
              onTap: () => Get.to(() => const MessageScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final String icon;
  final int count;
  final VoidCallback onTap;

  const _NotificationIcon({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Image.asset(
                icon,
                height: 26,
                width: 26,
                fit: BoxFit.contain,
                color: ColorRes.textDarkGrey
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorRes.likeRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: TextStyleCustom.outFitRegular400(
                      color: ColorRes.whitePure,
                      fontSize: 10,
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
