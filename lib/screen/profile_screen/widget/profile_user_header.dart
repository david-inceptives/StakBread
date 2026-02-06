import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/extensions/common_extension.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/manager/share_manager.dart';
import 'package:stakBread/common/widget/custom_image.dart';
import 'package:stakBread/common/widget/custom_popup_menu_button.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/follow_following_screen/follow_following_screen.dart';
import 'package:stakBread/screen/level_screen/level_screen.dart';
import 'package:stakBread/screen/profile_screen/profile_screen_controller.dart';
import 'package:stakBread/screen/profile_screen/widget/profile_preview_interactive_screen.dart';
import 'package:stakBread/screen/profile_screen/widget/user_link_sheet.dart';
import 'package:stakBread/screen/settings_screen/settings_screen.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/style_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class ProfileUserHeader extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfileUserHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        User? user = controller.userData.value;
        bool isUserNotFound = controller.isUserNotFound.value;

        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileStatsRow(
                userNotFound: isUserNotFound,
                controller: controller,
                user: user,
                stats: [
                  StatItem(value: user?.totalPostLikesCount ?? 0, label: LKey.likes.tr),
                  StatItem(value: user?.followerCount ?? 0, label: LKey.followers.tr),
                  StatItem(value: user?.followingCount ?? 0, label: LKey.following.tr),
                ],
                onTap: (value) {
                  if (isUserNotFound) {
                    return;
                  }
                  switch (value) {
                    case 0:
                      break;
                    case 1:
                      user?.checkIsBlocked(() {
                        // Followers
                        Get.to(() => FollowFollowingScreen(type: FollowFollowingType.follower, user: user));
                      });
                      break;
                    case 2:
                      user?.checkIsBlocked(() {
                        // Following
                        Get.to(() => FollowFollowingScreen(type: FollowFollowingType.following, user: user));
                      });
                      break;
                  }
                },
              ),
              if (!isUserNotFound) ...[
                const SizedBox(height: 16),
                UserNameView(user: user),
                const SizedBox(height: 8),
                UserLinkView(user: user),
                UserBioView(user: user),
              ],
              isUserNotFound ? const NoUserFoundButton() : UserButtonView(user: user, controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class ProfileStatsRow extends StatefulWidget {
  final User? user;
  final List<StatItem> stats;
  final Function(int value) onTap;
  final ProfileScreenController controller;
  final bool userNotFound;

  const ProfileStatsRow({
    super.key,
    required this.user,
    required this.stats,
    required this.onTap,
    required this.controller,
    required this.userNotFound,
  });

  @override
  State<ProfileStatsRow> createState() => _ProfileStatsRowState();
}

class _ProfileStatsRowState extends State<ProfileStatsRow> {
  bool _heroEnable = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final controller = widget.controller;
    final userNotFound = widget.userNotFound;
    final stats = widget.stats;
    final onTap = widget.onTap;

    bool isStoryAvailable = (user?.stories ?? []).isNotEmpty;
    bool isWatch = isStoryAvailable && (user?.stories ?? []).every((element) => element.isWatchedByMe());
    bool isMe = user?.id?.toInt() == SessionManager.instance.getUserID();
    const double profileSize = 96;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture
        if (userNotFound)
          Image.asset(AssetRes.icUserPlaceholder, width: profileSize, height: profileSize, fit: BoxFit.cover)
        else
          GestureDetector(
            onTap: () {
              if (isMe) {
                Get.to(() => SettingsScreen(onUpdateUser: controller.onUpdateUser));
                return;
              }
              controller.onStoryTap(isStoryAvailable);
            },
            onLongPressStart: (_) => setState(() => _heroEnable = true),
            onLongPressEnd: (_) => setState(() => _heroEnable = false),
            onLongPress: () {
              user?.checkIsBlocked(() {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                      opaque: false,
                      barrierColor: Colors.transparent,
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) => ProfilePreviewInteractiveScreen(user: user)),
                );
              });
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: profileSize,
                  height: profileSize,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(cornerRadius: profileSize / 2),
                    ),
                    gradient: isStoryAvailable
                        ? (isWatch ? StyleRes.disabledGreyGradient(opacity: .5) : StyleRes.themeGradient)
                        : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorRes.whitePure,
                    ),
                    child: HeroMode(
                      enabled: _heroEnable,
                      child: Hero(
                        tag: 'profile-${user?.id}',
                        child: CustomImage(
                          size: !isStoryAvailable ? const Size(96, 96) : const Size(86, 86),
                          image: user?.isBlock == true ? '' : user?.profilePhoto?.addBaseURL(),
                          fullName: user?.fullname,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isMe)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: GestureDetector(
                      onTap: () => Get.to(() => SettingsScreen(onUpdateUser: controller.onUpdateUser)),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: ColorRes.themeAccentSolid,
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorRes.whitePure, width: 2),
                        ),
                        child: Icon(Icons.edit_rounded, size: 14, color: ColorRes.whitePure),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(width: userNotFound ? 16 : 20),
        // Stats Columns
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                stats.length,
                (index) => Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => onTap(index),
                        child: StatColumn(
                          value: stats[index].value,
                          label: stats[index].label,
                          valueStyle: TextStyleCustom.unboundedSemiBold600(
                            color: ColorRes.textDarkGrey,
                            fontSize: 18,
                          ),
                          labelStyle: TextStyleCustom.outFitRegular400(
                            color: ColorRes.textLightGrey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (index != stats.length - 1)
                        Container(
                          height: 32,
                          width: 1,
                          color: ColorRes.borderLight,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Individual Stat Column Widget
class StatColumn extends StatelessWidget {
  final num value;
  final String label;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const StatColumn({super.key, required this.value, required this.label, this.labelStyle, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toInt().numberFormat,
          style: valueStyle ??
              TextStyleCustom.unboundedMedium500(
                color: ColorRes.textDarkGrey,
                fontSize: 15,
              ),
        ),
        Text(label.capitalize ?? '',
            style: labelStyle ??
                TextStyleCustom.outFitLight300(
                  color: ColorRes.textLightGrey,
                  fontSize: 15,
                )),
      ],
    );
  }
}

class UserNameView extends StatelessWidget {
  final User? user;

  const UserNameView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user?.fullname ?? '',
                style: TextStyleCustom.unboundedSemiBold600(
                  color: ColorRes.textDarkGrey,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user?.isVerify == 1) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:  ColorRes.themeAccentSolid.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 14, color: ColorRes.themeAccentSolid),
                    const SizedBox(width: 4),
                    Text(
                      LKey.verify.tr,
                      style: TextStyleCustom.outFitSemiBold600(
                        color: ColorRes.themeAccentSolid,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            /*if (user?.getLevel.id != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Get.to(() => LevelScreen(userLevels: user?.getLevel)),
                child: Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: ColorRes.themeAccentSolid.withValues(alpha: 0.15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${LKey.lvl.tr} ${user?.getLevel.level ?? 0}',
                    style: TextStyleCustom.outFitSemiBold600(
                      color: ColorRes.themeAccentSolid,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],*/
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '@${user?.username ?? ''}',
          style: TextStyleCustom.outFitRegular400(
            color: ColorRes.textLightGrey,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class UserLinkView extends StatelessWidget {
  final User? user;

  const UserLinkView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    List<Link> links = user?.links ?? [];
    if (links.isNotEmpty) {
      return InkWell(
        onTap: () {
          user?.checkIsBlocked(() {
            if (links.length > 1) {
              Get.bottomSheet(UserLinkSheet(links: links),
                  isScrollControlled: true, barrierColor: ColorRes.blackPure.withValues(alpha: .7));
            } else {
              (links.first.url ?? '').lunchUrlWithHttps;
            }
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AssetRes.icLink, height: 20, width: 20, color: ColorRes.themeAccentSolid),
            const SizedBox(width: 3),
            Expanded(
              child: Text(shortUrl,
                  style: TextStyleCustom.outFitRegular400(fontSize: 15, color: ColorRes.themeAccentSolid)),
            )
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  String get shortUrl {
    List<Link> links = user?.links ?? [];
    String firstLink = links.first.url ?? '';
    String andMore = '';
    if (firstLink.length >= 40) {
      int endCount = links.length > 1 ? 25 : 35;
      firstLink = '${firstLink.substring(0, endCount)}...';
    }
    if (links.length > 1) {
      andMore = ' & ${links.length - 1} ${LKey.more.tr.toLowerCase()}';
    }
    return '$firstLink$andMore';
  }
}

class UserBioView extends StatelessWidget {
  final User? user;

  const UserBioView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if ((user?.bio ?? '').isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        user?.bio ?? '',
        style: TextStyleCustom.outFitRegular400(
          color: ColorRes.textLightGrey,
          fontSize: 15,
        ),
      ),
    );
  }
}

class UserButtonView extends StatelessWidget {
  final User? user;
  final ProfileScreenController controller;

  const UserButtonView({super.key, required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    User? user = controller.profileController.user;

    bool isMe = user?.id?.toInt() == SessionManager.instance.getUserID();
    bool isBlock = (user?.isBlock == true && user?.id != SessionManager.instance.getUserID());
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 10),
      child: Row(
        children: [
          Expanded(
            child: isBlock
                ? UnblockButton(onTap: () => controller.toggleBlockUnblock(true))
                : RowButton(controller: controller, isMe: isMe, user: user),
          ),
          const SizedBox(width: 8),
          if (isMe)
            InkWell(
              onTap: () {
                ShareManager.shared.showCustomShareSheet(user: user, keys: ShareKeys.user);
              },
              child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: ShapeDecoration(
                    shape:
                        SmoothRectangleBorder(borderRadius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1)),
                    color: ColorRes.bgGrey,
                  ),
                  child: Image.asset(isMe ? AssetRes.icShare1 : AssetRes.icMore, height: 21, width: 21)),
            )
          else
            Obx(
              () => CustomPopupMenuButton(
                  items: [
                    MenuItem(user?.isBlock == true ? LKey.unBlock.tr : LKey.block.tr, () {
                      controller.toggleBlockUnblock(user?.isBlock ?? false);
                    }),
                    MenuItem(LKey.report.tr, () => controller.reportUser(user)),
                    if (SessionManager.instance.isModerator.value == 1)
                      MenuItem(user?.isFreez == 1 ? LKey.unFreeze.tr : LKey.freeze.tr,
                          () => controller.freezeUnfreezeUser(user?.isFreez == 1))
                  ],
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: ShapeDecoration(
                      shape:
                          SmoothRectangleBorder(borderRadius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1)),
                      color: ColorRes.bgGrey,
                    ),
                    child: Image.asset(AssetRes.icMore, height: 21, width: 21),
                  )),
            )
        ],
      ),
    );
  }
}

class NoUserFoundButton extends StatelessWidget {
  const NoUserFoundButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButtonCustom(
      onTap: () {},
      title: LKey.userNotFound.tr,
      btnHeight: 40,
      backgroundColor: ColorRes.bgMediumGrey,
      fontSize: 15,
      radius: 8,
      titleColor: ColorRes.textLightGrey,
      margin: const EdgeInsets.only(bottom: 10, left: 40, right: 40, top: 20),
    );
  }
}

class UnblockButton extends StatelessWidget {
  final VoidCallback onTap;

  const UnblockButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButtonCustom(
      onTap: onTap,
      title: LKey.unBlock.tr,
      fontSize: 16,
      backgroundColor: ColorRes.blueFollow,
      titleColor: ColorRes.whitePure,
      horizontalMargin: 0,
      btnHeight: 45,
    );
  }
}

class RowButton extends StatelessWidget {
  final bool isMe;
  final ProfileScreenController controller;
  final User? user;

  const RowButton({
    super.key,
    required this.isMe,
    required this.controller,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: TextButtonCustom(
                onTap: () => Get.to(() => SettingsScreen(onUpdateUser: controller.onUpdateUser)),
                title: LKey.settings.tr,
                fontSize: 15,
                backgroundColor: ColorRes.themeAccentSolid,
                titleColor: ColorRes.whitePure,
                horizontalMargin: 0,
                btnHeight: 46,
                radius: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => {},
                child: Container(
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorRes.themeAccentSolid.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    LKey.uploadResume.tr,
                    style: TextStyleCustom.outFitSemiBold600(
                      color: ColorRes.themeAccentSolid,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 10),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () {
                bool isFollowProgress = controller.isFollowUnFollowInProcess.value;
                Color textColor = user?.isFollowing == true ? ColorRes.textLightGrey : ColorRes.whitePure;
                return TextButtonCustom(
                  onTap: () async {
                    if (!isFollowProgress) controller.followUnFollowUser();
                  },
                  title: user?.isFollowing == true ? LKey.unFollow.tr : LKey.follow.tr,
                  fontSize: 16,
                  backgroundColor:
                      user?.isFollowing == true ? ColorRes.bgGrey : ColorRes.blueFollow,
                  titleColor: textColor,
                  horizontalMargin: 0,
                  btnHeight: 45,
                  child: isFollowProgress
                      ? CupertinoActivityIndicator(radius: 10, color: textColor)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          if (user?.receiveMessage == 1)
            Expanded(
              child: TextButtonCustom(
                  onTap: () => controller.handlePublishOrMessageBtn(false),
                  title: LKey.message.tr,
                  fontSize: 16,
                  backgroundColor: ColorRes.bgGrey,
                  titleColor: ColorRes.textLightGrey,
                  horizontalMargin: 0,
                  btnHeight: 45),
            ),
        ],
      ),
    );
  }
}

// Stat Item Model
class StatItem {
  final num value;
  final String label;

  StatItem({required this.value, required this.label});
}
