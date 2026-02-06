import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/edit_profile_screen/edit_profile_screen.dart';
import 'package:stakBread/screen/settings_screen/settings_screen_controller.dart';
import 'package:stakBread/screen/settings_screen/widget/notifications_page.dart';
import 'package:stakBread/screen/subscription_screen/subscription_screen.dart';
import 'package:stakBread/screen/term_and_privacy_screen/term_and_privacy_screen.dart';
import 'package:stakBread/screen/withdrawals_screen/withdrawals_screen.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

import '../../common/widget/custom_drop_down.dart';
import '../../common/widget/custom_toggle.dart';
import '../blocked_user_screen/blocked_user_screen.dart';
import '../saved_post_screen/saved_post_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Function(User? user)? onUpdateUser;

  const SettingsScreen({super.key, this.onUpdateUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsScreenController());
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: LKey.accountSettings.tr),
                    _SettingTile(
                      title: LKey.editProfile.tr,
                      onTap: () =>
                          Get.to(() => EditProfileScreen(onUpdateUser: onUpdateUser)),
                    ),
                    _SettingTile(
                      title: LKey.updatePassword.tr,
                      onTap: () => _showUpdatePasswordHint(),
                    ),
                    _SettingTile(

                      title: LKey.savedPosts,
                      onTap: () {
                        Get.to(() => const SavedPostScreen());
                      },
                    ),
                _SettingTile(
                      title: LKey.blockedUsers,
                      onTap: () {
                        Get.to(() => const BlockedUserScreen());
                      },
                    ),

              /*  Obx(
                      () => SettingIconTextWithArrow(
                    title: LKey.whoCanSeePosts,
                    widget: CustomDropDownBtn<WhoCanSeePost>(
                      items: WhoCanSeePost.values,
                      onChanged: controller.isUpdateApiCalled.value
                          ? null
                          : controller.onChangedWhoCanSeePost,
                      selectedValue: controller.selectedWhoCanSeePost.value,
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 15, color: ColorRes.textLightGrey),
                      getTitle: (value) => value.title,
                    ),
                  ),
                ),
                Obx(
                      () {
                    return SettingIconTextWithArrow(
                      title: LKey.showMyFollowings,
                      widget: CustomToggle(
                        isOn: (controller.myUser.value?.showMyFollowing == 1).obs,
                        onChanged: (value) {
                          controller.onChangedToggle(
                              value, SettingToggle.showMyFollowings);
                        },
                      ),
                    );
                  },),*/
                    _SectionHeader(title: LKey.notifications.tr),
                    _SettingTile(
                      title: LKey.pushNotifications.tr,
                      onTap: () => Get.to(() => const NotificationsPage()),
                    ),
                    _SectionHeader(title: LKey.orderManagement.tr),
                    _SettingTile(
                      title: LKey.productsSold.tr,
                      onTap: () {},
                    ),
                    _SettingTile(
                      title: LKey.productsPurchased.tr,
                      onTap: () {},
                    ),
                    _SectionHeader(title: LKey.paymentAndBilling.tr),
                    _SettingTile(
                      title: LKey.savedCardsPaymentMethods.tr,
                      onTap: () {},
                    ),
                    _SettingTile(
                      title: LKey.transactionHistory.tr,
                      onTap: () => Get.to(() => const WithdrawalsScreen()),
                    ),
                    /*_SettingTile(
                      title: LKey.subscriptionIfApplicable.tr,
                      onTap: () => Get.to<bool>(
                            () => SubscriptionScreen(onUpdateUser: onUpdateUser),
                          )?.then((v) {
                        if (v == true) controller.initData();
                      }),
                    ),*/
                    _SectionHeader(title: LKey.legalAndPolicies.tr),
                    _SettingTile(
                      title: LKey.termsAndConditions.tr,
                      onTap: () => Get.to(() => const TermAndPrivacyScreen(
                            type: TermAndPrivacyType.termAndCondition,
                          )),
                    ),
                    _SettingTile(
                      title: LKey.privacyPolicy.tr,
                      onTap: () => Get.to(() => const TermAndPrivacyScreen(
                            type: TermAndPrivacyType.privacyPolicy,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: ColorRes.whitePure,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: ColorRes.textDarkGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              LKey.settings.tr,
              textAlign: TextAlign.center,
              style: TextStyleCustom.unboundedSemiBold600(
                fontSize: 18,
                color: ColorRes.textDarkGrey,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showMoreOptions(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.more_horiz_rounded,
                size: 22,
                color: ColorRes.textDarkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdatePasswordHint() {
    Get.snackbar(
      LKey.updatePassword.tr,
      'Reset link can be sent to your email. Use Forget Password on login screen.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ColorRes.textDarkGrey,
      colorText: ColorRes.whitePure,
    );
  }

  void _showMoreOptions(BuildContext context) {
    final controller = Get.find<SettingsScreenController>();
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorRes.whitePure,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.logout_rounded, color: ColorRes.textDarkGrey),
              title: Text(
                LKey.logOut.tr,
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 16,
                  color: ColorRes.textDarkGrey,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                controller.onLogout();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: ColorRes.likeRed),
              title: Text(
                LKey.deleteAccount.tr,
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 16,
                  color: ColorRes.likeRed,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                controller.onDeleteAccount();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyleCustom.unboundedSemiBold600(
          fontSize: 16,
          color: ColorRes.textDarkGrey,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorRes.borderLight, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 15,
                  color: ColorRes.textDarkGrey,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: ColorRes.textDarkGrey,
            ),
          ],
        ),
      ),
    );
  }
}
