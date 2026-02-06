import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:stakBread/screen/discover_screen/discover_screen_controller.dart';
import 'package:stakBread/screen/feed_screen/feed_screen.dart';
import 'package:stakBread/screen/home_screen/home_screen.dart';
import 'package:stakBread/screen/message_screen/message_screen.dart';
import 'package:stakBread/screen/notification_screen/notification_screen.dart';
import 'package:stakBread/screen/search_screen/search_screen.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

import '../../utilities/asset_res.dart';

class DiscoverScreen extends StatelessWidget {
  final User? myUser;

  const DiscoverScreen({super.key, this.myUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DiscoverScreenController());
    int notifCount = 0;
    int messageCount = 0;
    if (Get.isRegistered<DashboardScreenController>()) {
      final dash = Get.find<DashboardScreenController>();
      notifCount = dash.requestUnReadCount.value;
      messageCount = dash.unReadCount.value;
    }
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(notifCount, messageCount),
            _buildTabs(controller),
            Expanded(
              child: FeedScreen(myUser: myUser),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(int notifCount, int messageCount) {
    return Container(
      color: ColorRes.whitePure,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            icon: AssetRes.icNotification,
            count: notifCount,
            onTap: () => Get.to(() => const NotificationScreen()),
          ),
          const SizedBox(width: 8),
          _NotificationIcon(
            icon: AssetRes.icMessage,
            count: messageCount,
            onTap: () => Get.to(() => const MessageScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(DiscoverScreenController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => controller.onTabChanged(0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Obx(() {
                    final selected = controller.selectedTabIndex.value == 0;
                    return Column(
                      children: [
                        Text(
                          LKey.home.tr,
                          style: TextStyleCustom.unboundedSemiBold600(
                            fontSize: 15,
                            color: selected
                                ? ColorRes.textDarkGrey
                                : ColorRes.textLightGrey,
                          ),
                        ),
                        Container(
                          height: selected ? 3 : 0,
                          margin: const EdgeInsets.only(top: 6),
                          color: ColorRes.textDarkGrey,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => Get.to(() => const HomeScreen()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      Text(
                        LKey.reels.tr,
                        style: TextStyleCustom.unboundedSemiBold600(
                          fontSize: 15,
                          color: ColorRes.textLightGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
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

