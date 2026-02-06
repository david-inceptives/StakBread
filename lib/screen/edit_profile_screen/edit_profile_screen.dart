import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/common/widget/custom_image.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/common/widget/text_field_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/edit_profile_screen/edit_profile_screen_controller.dart';
import 'package:stakBread/screen/edit_profile_screen/widget/build_link_view.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class EditProfileScreen extends StatelessWidget {
  final Function(User? user)? onUpdateUser;

  const EditProfileScreen({super.key, this.onUpdateUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileScreenController(onUpdateUser));
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      LKey.editProfile.tr,
                      style: TextStyleCustom.unboundedSemiBold600(
                        fontSize: 20,
                        color: ColorRes.textDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() => Text(
                          '${LKey.userId.tr}: ${controller.userData.value?.id ?? ''}',
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 14,
                            color: ColorRes.textLightGrey,
                          ),
                        )),
                    const SizedBox(height: 16),
                    Text(
                      LKey.profileImage.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 15,
                        color: ColorRes.textLightGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: controller.onChangeProfileImage,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Obx(
                            () => controller.fileProfileImage.value != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(controller.fileProfileImage.value?.path ?? ''),
                                      height: 86,
                                      width: 86,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : CustomImage(
                                    size: const Size(86, 86),
                                    image: controller.userData.value?.profilePhoto?.addBaseURL(),
                                    fullName: controller.userData.value?.fullname,
                                  ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 28,
                              width: 28,
                              decoration: BoxDecoration(
                                color: ColorRes.themeAccentSolid,
                                shape: BoxShape.circle,
                                border: Border.all(color: ColorRes.whitePure, width: 2),
                              ),
                              child: Icon(Icons.edit_rounded, size: 16, color: ColorRes.whitePure),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _EditProfileField(
                      label: LKey.fullName.tr,
                      controller: controller.fullNameController,
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => _EditProfileField(
                        label: LKey.username.tr,
                        controller: controller.usernameController,
                        onChanged: controller.checkUsernameAvailability,
                        error: !controller.isValidUserName.value,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _EditProfileField(
                      label: LKey.email.tr,
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextFieldCustom(
                      controller: controller.phoneNumberController,
                      title: LKey.phoneNumber.tr,
                      isPrefixIconShow: true,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      LKey.bio.tr,
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 15,
                        color: ColorRes.textLightGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _EditProfileField(
                      label: '',
                      controller: controller.bioController,
                      minLines: 4,
                    ),
                    const SizedBox(height: 20),
                    BuildLinkView(controller: controller),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: TextButtonCustom(
                onTap: controller.onSaveTap,
                title: LKey.saveChanges.tr,
                backgroundColor: ColorRes.themeAccentSolid,
                titleColor: ColorRes.whitePure,
                btnHeight: 52,
                radius: 14,
                horizontalMargin: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: ColorRes.whitePure,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
              LKey.accountSettings.tr,
              textAlign: TextAlign.center,
              style: TextStyleCustom.unboundedSemiBold600(
                fontSize: 18,
                color: ColorRes.textDarkGrey,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Container()
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool error;
  final TextInputType? keyboardType;
  final int minLines;

  const _EditProfileField({
    required this.label,
    required this.controller,
    this.onChanged,
    this.error = false,
    this.keyboardType,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 15,
                color: ColorRes.textLightGrey,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: ColorRes.whitePure,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error ? ColorRes.likeRed : ColorRes.borderLight,
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              keyboardType: keyboardType,
              minLines: minLines,
              maxLines: minLines > 1 ? 6 : 1,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 16,
                color: ColorRes.textDarkGrey,
              ),
              decoration: InputDecoration(
                hintText: label.isNotEmpty ? 'Enter ${label.toLowerCase()}' : LKey.enterHere.tr,
                hintStyle: TextStyleCustom.outFitRegular400(
                  fontSize: 16,
                  color: ColorRes.textLightGrey,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              cursorColor: ColorRes.themeAccentSolid,
            ),
          ),
        ),
      ],
    );
  }
}
