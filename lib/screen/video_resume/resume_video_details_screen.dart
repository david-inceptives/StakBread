import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Resume video details screen: caption, attach document, Add To Resume.
/// Shown after recording or picking a video.
class ResumeVideoDetailsScreen extends StatefulWidget {
  final String videoPath;
  final String thumbnailPath;

  const ResumeVideoDetailsScreen({
    super.key,
    required this.videoPath,
    required this.thumbnailPath,
  });

  @override
  State<ResumeVideoDetailsScreen> createState() => _ResumeVideoDetailsScreenState();
}

class _ResumeVideoDetailsScreenState extends State<ResumeVideoDetailsScreen> {
  final TextEditingController _captionController = TextEditingController();
  String? _attachedFilePath;
  String? _attachedFileName;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _onAttachDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachedFilePath = result.files.single.path;
        _attachedFileName = result.files.single.name;
      });
    }
  }

  void _onAddToResume() {
    // TODO: Upload video (widget.videoPath), caption, and _attachedFilePath to backend
    Get.back();
    Get.snackbar('', _attachedFilePath != null ? 'Resume video and document added' : 'Resume video added');
  }

  Widget _placeholderThumbnail() {
    return Container(
      width: 56,
      height: 56,
      color: ColorRes.borderLight,
      child: Icon(Icons.videocam_outlined, size: 28, color: ColorRes.textLightGrey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      appBar: AppBar(
        backgroundColor: ColorRes.whitePure,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ColorRes.textDarkGrey, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text(
          LKey.resumeVideo.tr,
          style: TextStyleCustom.outFitSemiBold600(
            fontSize: 16,
            color: ColorRes.textDarkGrey,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: ColorRes.textDarkGrey, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video thumbnail + caption row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: widget.thumbnailPath.isNotEmpty
                      ? Image.file(
                          File(widget.thumbnailPath),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderThumbnail(),
                        )
                      : _placeholderThumbnail(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: LKey.writeCaptionHere.tr,
                      hintStyle: TextStyleCustom.outFitRegular400(
                        fontSize: 14,
                        color: ColorRes.textLightGrey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorRes.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorRes.borderLight),
                      ),
                      filled: true,
                      fillColor: ColorRes.whitePure,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 14,
                      color: ColorRes.textDarkGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Attach Document row
            Row(
              children: [
                Text(
                  LKey.attachDocument.tr,
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 15,
                    color: ColorRes.textDarkGrey,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _onAttachDocument,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: ColorRes.themeAccentSolid,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: ColorRes.whitePure, size: 26),
                  ),
                ),
              ],
            ),
            if (_attachedFileName != null) ...[
              const SizedBox(height: 8),
              Text(
                _attachedFileName!,
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 13,
                  color: ColorRes.textLightGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 32),
            // Add To Resume button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onAddToResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorRes.themeAccentSolid,
                  foregroundColor: ColorRes.whitePure,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  LKey.addToResume.tr,
                  style: TextStyleCustom.outFitSemiBold600(fontSize: 16, color: ColorRes.whitePure),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
