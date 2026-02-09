import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';
import 'package:stakBread/common/widget/banner_ads_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/camera_screen/camera_screen.dart';
import 'package:stakBread/screen/create_feed_screen/create_feed_screen.dart';
import 'package:stakBread/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:stakBread/screen/discover_screen/discover_screen.dart';
import 'package:stakBread/screen/profile_screen/profile_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen.dart';
import 'package:stakBread/utilities/style_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class DashboardScreen extends StatelessWidget {
  final User? myUser;

  const DashboardScreen({super.key, this.myUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardScreenController());
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      resizeToAvoidBottomInset: true,
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: ProsteIndexedStack(
                index: controller.selectedPageIndex.value,
                children: [
                  IndexedStackChild(child: DiscoverScreen(myUser: myUser), preload: true),
                  IndexedStackChild(child: Container(), preload: false),
                  IndexedStackChild(child: Container(), preload: false),
                  IndexedStackChild(child: const StoreScreen(), preload: true),
                  IndexedStackChild(child: ProfileScreen(isDashBoard: false, user: myUser, isTopBarVisible: false), preload: true)
                ],
              ),
            ),
            if (controller.selectedPageIndex.value != 0)
              const BannerAdsCustom(),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNavigationBar(context, controller),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, DashboardScreenController controller) {
    return Obx(() {
      PostUploadingProgress postUpload = controller.postProgress.value;
      bool isPostUploading =
          postUpload.uploadType == UploadType.none ? false : true;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: ColorRes.whitePure,
          border: Border(top: BorderSide(color: ColorRes.borderLight, width: 1)),
        ),
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                controller.bottomIconList.length,
                (index) {
                  final isAddButton = index == 2;
                  return _buildBottomNavItem(
                    context,
                    controller,
                    index,
                    isPostUploading,
                    isAddButton: isAddButton,
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              bottom: isPostUploading ? true : false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: isPostUploading ? 30 : 0,
                margin: Platform.isAndroid || !isPostUploading
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(bottom: 20, top: 5),
                color: Colors.white,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(height: 30, decoration: BoxDecoration(gradient: StyleRes.themeGradient)),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: LayoutBuilder(builder: (context, constraints) {
                        double progress = (constraints.maxWidth * postUpload.progress) / 100;
                        return AnimatedContainer(
                          height: 30,
                          width: constraints.maxWidth - progress,
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(color: ColorRes.textDarkGrey),
                        );
                      }),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (postUpload.uploadType != UploadType.error)
                            Text('${postUpload.progress.toInt()}%',
                                style: TextStyleCustom.outFitMedium500(
                                  color: ColorRes.whitePure,
                                  fontSize: 16,
                                )),
                          Text(' ${postUpload.uploadType.title(postUpload.type)}',
                              style: TextStyleCustom.outFitLight300(color: ColorRes.whitePure, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  void _showUploadOptionsSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: ColorRes.whitePure,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        margin: const EdgeInsets.fromLTRB(140, 0, 140, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Get.back();
                Get.to(() => CreateFeedScreen(createType: CreateFeedType.feed));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined, size: 24, color: ColorRes.textDarkGrey),
                    const SizedBox(width: 5),
                    Text(
                      LKey.feed.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 16,
                        color: ColorRes.textDarkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: ColorRes.borderLight),
            InkWell(
              onTap: () {
                Get.back();
                Get.to(() => const CameraScreen(cameraType: CameraScreenType.post));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 24, color: ColorRes.textDarkGrey),
                    const SizedBox(width: 5),
                    Text(
                      LKey.reels.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 16,
                        color: ColorRes.textDarkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    DashboardScreenController controller,
    int index,
    bool isPostUploading, {
    bool isAddButton = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPageIndex.value == index;
      final iconColor = isSelected
          ? ColorRes.themeAccentSolid
          : ColorRes.textLightGrey;

      return SafeArea(
        bottom: isPostUploading ? false : true,
        child: InkWell(
          onTap: () {
            if (isAddButton) {
              _showUploadOptionsSheet(context);
            } else {
              controller.onChanged(index);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      iconColor,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      controller.bottomIconList[index],
                      height: 28,
                      width: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (index == 4) _buildUnreadCount(controller, context),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUnreadCount(
      DashboardScreenController controller, BuildContext context) {
    return Obx(() {
      final count = controller.unReadCount.value;
      if (count <= 0) return const SizedBox();
      return Positioned(
        top: 0,
        right: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: ColorRes.themeAccentSolid,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count > 9 ? '9+' : '$count',
            style: TextStyleCustom.outFitRegular400(
              color: ColorRes.whitePure,
              fontSize: 10,
            ),
          ),
        ),
      );
    });
  }
}
