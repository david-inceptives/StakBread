import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stakBread/common/functions/media_picker_helper.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/camera_screen/camera_screen.dart';
import 'package:stakBread/screen/video_resume/resume_video_details_screen.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Bottom sheet shown when user taps "Upload Resume" on profile.
/// Options: Record Video, Upload From Internal Storage, Upload From Cloud, Cancel.
void showUploadResumeSheet() {
  Get.bottomSheet(
    _UploadResumeSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
  );
}

class _UploadResumeSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              label: LKey.recordVideo.tr,
              onTap: () {
                Get.back();
                Get.to(() => const CameraScreen(cameraType: CameraScreenType.videoResume));
              },
            ),
            const SizedBox(height: 16),
            _OptionTile(
              label: LKey.uploadFromInternalStorage.tr,
              onTap: () async {
                Get.back();
                final media = await MediaPickerHelper.shared.pickVideo(source: ImageSource.gallery);
                if (media != null) {
                  Get.to(() => ResumeVideoDetailsScreen(
                    videoPath: media.file.path,
                    thumbnailPath: media.thumbNail.path,
                  ));
                }
              },
            ),
            const SizedBox(height: 16),
            _OptionTile(
              label: LKey.uploadFromCloud.tr,
              onTap: () {
                Get.back();
                Get.snackbar('', 'Upload From Cloud – coming soon');
              },
            ),
            const SizedBox(height: 24),
            _OptionTile(
              label: LKey.cancel.tr,
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OptionTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyleCustom.outFitSemiBold600(
                fontSize: 16,
                color: const Color(0xFF007AFF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
