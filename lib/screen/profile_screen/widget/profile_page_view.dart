import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/widget/no_data_widget.dart';
import 'package:stakBread/common/widget/post_list.dart';
import 'package:stakBread/common/widget/reel_list.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/profile_screen/profile_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class ProfilePageView extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfilePageView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Obx(() {
      User? user = controller.userData.value;
      bool isMe = user?.id == SessionManager.instance.getUserID();
      bool isUserNotFound = controller.isUserNotFound.value;
      bool isModerator = SessionManager.instance.isModerator.value == 1;
      return isUserNotFound
          ? NoDataView(
              title: LKey.noUserPostsTitle.tr,
              description: LKey.noUserPostsDescription.tr)
          : user?.isBlock == true
              ? const BlockUserView()
              : user?.isFreez == 1
                  ? const FreezeUser()
                  : PageView(
                      controller: controller.pageController,
                      onPageChanged: controller.onTabChanged,
                      children: [

                        isMe?PostList(
                          posts: controller.posts,
                          onFetchMoreData: controller.fetchPost,
                          isLoading: controller.isPostLoading,
                          shouldShowPinOption: true,
                          isMe: isMe,
                        ):ReelList(
                            reels: controller.reels,
                            isLoading: controller.isReelLoading,
                            onFetchMoreData: controller.fetchReel,
                            menus: isMe
                                ? [
                              ContextMenuElement(
                                  title: '',
                                  onTap: controller.onPinUnpinReel),
                              ContextMenuElement(
                                  title: LKey.delete.tr,
                                  onTap: (post) =>
                                      controller.onDeleteReel(post,
                                          isModerator: false))
                            ]
                                : [
                              if (isModerator)
                                ContextMenuElement(
                                    title: LKey.delete.tr,
                                    onTap: (post) =>
                                        controller.onDeleteReel(post,
                                            isModerator: true))
                            ],
                            isPinShow: true),
                        isMe?ReelList(
                            reels: controller.reels,
                            isLoading: controller.isReelLoading,
                            onFetchMoreData: controller.fetchReel,
                            menus: isMe
                                ? [
                                    ContextMenuElement(
                                        title: '',
                                        onTap: controller.onPinUnpinReel),
                                    ContextMenuElement(
                                        title: LKey.delete.tr,
                                        onTap: (post) =>
                                            controller.onDeleteReel(post,
                                                isModerator: false))
                                  ]
                                : [
                                    if (isModerator)
                                      ContextMenuElement(
                                          title: LKey.delete.tr,
                                          onTap: (post) =>
                                              controller.onDeleteReel(post,
                                                  isModerator: true))
                                  ],
                            isPinShow: true): const ProfileDummyProductGrid(),
                      ],
                    );
    }));
  }
}

/// Dummy product grid for other user's profile Shop tab.
class ProfileDummyProductGrid extends StatelessWidget {
  const ProfileDummyProductGrid({super.key});

  static const List<({String imagePath, String title, String price})> _products = [
    (imagePath: AssetRes.product1, title: 'Classic Earbuds', price: '\$129'),
    (imagePath: AssetRes.product2, title: 'Floral Midi Dress', price: '\$89'),
    (imagePath: AssetRes.product3, title: 'Skincare Set', price: '\$45'),
    (imagePath: AssetRes.camera4, title: 'Retro Camera', price: '\$299'),
    (imagePath: AssetRes.reel1, title: 'Style Pack', price: '\$19'),
    (imagePath: AssetRes.reel2, title: 'Gift Box', price: '\$24'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final p = _products[index];
        return Container(
          decoration: BoxDecoration(
            color: ColorRes.bgLightGrey,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ColorRes.blackPure.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    p.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: TextStyleCustom.unboundedSemiBold600(
                        fontSize: 13,
                        color: ColorRes.textDarkGrey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.price,
                      style: TextStyleCustom.unboundedSemiBold600(
                        fontSize: 14,
                        color: ColorRes.themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BlockUserView extends StatelessWidget {
  const BlockUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LKey.youAreBlockThisUser.tr,
        style: TextStyleCustom.outFitRegular400(
            color: ColorRes.textLightGrey, fontSize: 17),
      ),
    );
  }
}

class FreezeUser extends StatelessWidget {
  const FreezeUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LKey.thisUserIsFreeze.tr,
        style: TextStyleCustom.outFitRegular400(
            color: ColorRes.textLightGrey, fontSize: 17),
      ),
    );
  }
}
