import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/navigation/app_route_observer.dart';
import 'package:stakBread/common/widget/custom_border_round_icon.dart';
import 'package:stakBread/common/widget/loader_widget.dart';
import 'package:stakBread/common/widget/text_button_custom.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/camera_edit_screen/camera_edit_screen_controller.dart';
import 'package:stakBread/screen/camera_edit_screen/text_story/story_text_view.dart';
import 'package:stakBread/screen/camera_screen/camera_screen_controller.dart';
import 'package:stakBread/screen/camera_screen/widget/camera_top_view.dart';
import 'package:stakBread/screen/color_filter_screen/color_filter_view.dart';
import 'package:stakBread/screen/selected_music_sheet/selected_music_sheet_controller.dart';
import 'package:stakBread/utilities/app_res.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:video_player/video_player.dart';

class CameraEditScreen extends StatefulWidget {
  final PostStoryContent content;

  const CameraEditScreen({super.key, required this.content});

  @override
  State<CameraEditScreen> createState() => _CameraEditScreenState();
}

class _CameraEditScreenState extends State<CameraEditScreen> with RouteAware {
  late final CameraEditScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(CameraEditScreenController(widget.content.obs));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    _controller.videoSurfaceAllowed.value = false;
  }

  @override
  void didPopNext() {
    _controller.videoSurfaceAllowed.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 20),
                child: Stack(
                  children: [
                    GenerateContentView(controller: _controller),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CameraEditTopViewTools(controller: _controller),
                        FilterAndMusicView(controller: _controller)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            CameraEditActionButtons(controller: _controller),
          ],
        ),
      ),
    );
  }
}

class GenerateContentView extends StatelessWidget {
  final CameraEditScreenController controller;

  const GenerateContentView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return switch (controller.content.value.type) {
      PostStoryContentType.storyText ||
      PostStoryContentType.storyImage =>
        CameraEditImageView(cameraEditController: controller),
      PostStoryContentType.reel ||
      PostStoryContentType.storyVideo =>
        CameraEditVideoView(content: controller.content),
    };
  }
}

class CameraEditTopViewTools extends StatelessWidget {
  final CameraEditScreenController controller;

  const CameraEditTopViewTools({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    PostStoryContent content = controller.content.value;
    PostStoryContentType type = content.type;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10,
        children: [
          // Obx(
          //   () {
          //     if (controller.videoPlayerController.value != null) {
          //       return ValueListenableBuilder(
          //         valueListenable: controller.videoPlayerController.value!,
          //         builder: (context, value, child) => CustomBorderRoundIcon(
          //           image: value.volume == 1.0
          //               ? AssetRes.icVolumeOn
          //               : AssetRes.icVolumeOff,
          //           onTap: controller.toggleVideoVolume,
          //         ),
          //       );
          //     } else {
          //       return const SizedBox();
          //     }
          //   },
          // ),
          if ([PostStoryContentType.storyImage, PostStoryContentType.storyText]
              .contains(type))
            Obx(
              () => CustomBorderRoundIcon(
                onTap: controller.changeStoryTime,
                widget: Center(
                  child: Text(
                      '${AppRes.storyDurations[controller.currentStoryDurationIndex.value]}s',
                      style: TextStyleCustom.unboundedMedium500(
                          color: ColorRes.whitePure),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          if ([PostStoryContentType.storyImage, PostStoryContentType.storyText]
              .contains(type))
            CustomBorderRoundIcon(
              onTap: () => controller.onNewTexFieldAdd?.call(),
              image: AssetRes.icText1,
            ),
          if (![PostStoryContentType.storyText].contains(content.type))
            CustomBorderRoundIcon(
                image: AssetRes.icFilter, onTap: controller.onFilterToggle),
          if ([PostStoryContentType.storyText, PostStoryContentType.storyImage]
              .contains(type))
            Obx(() {
              bool isTextStory = PostStoryContentType.storyText == type;
              int selectedGradientIndex = controller.selectedBgIndex.value;

              var gradient = isTextStory
                  ? controller.storyGradientColor[selectedGradientIndex]
                  : controller.content.value.bgGradient;
              return CustomBorderRoundIcon(
                onTap: () => controller.changeBg(isTextStory),
                widget: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isTextStory
                          ? gradient
                          : controller.content.value.bgGradient,
                      border: Border.all(color: ColorRes.whitePure, width: 2)),
                ),
              );
            }),
          CustomBorderRoundIcon(
              image: AssetRes.icMusic, onTap: controller.handleMusicSelection),
        ],
      ),
    );
  }
}

class FilterAndMusicView extends StatelessWidget {
  final CameraEditScreenController controller;

  const FilterAndMusicView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isFilterShow = controller.isFilterShow.value;
      PostStoryContent content = controller.content.value;
      SelectedMusic? music = content.sound;
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: isFilterShow ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: IgnorePointer(
                ignoring: !isFilterShow,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ColorFiltersView(
                      onPageChanged: controller.changedFilter,
                      image: content.thumbNail),
                ),
              ),
            ),
            if (music != null)
              SelectedMusicView(
                  selectedMusic: music.obs,
                  isReelType: false,
                  onDeleteMusic: controller.onMusicDelete,
                  onMusicTap: (music) {
                    controller.handleMusicSelection(initialMusic: music);
                  })
          ],
        ),
      );
    });
  }
}

class CameraEditVideoView extends StatelessWidget {
  final Rx<PostStoryContent> content;

  const CameraEditVideoView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CameraEditScreenController>();
    // Outer Obx: only re-build when the player is created/ready — not on every filter matrix change.
    return Obx(() {
      if (!controller.videoSurfaceAllowed.value) {
        return Container(
          decoration: ShapeDecoration(
            color: ColorRes.blackPure,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 15,
                cornerSmoothing: 1,
              ),
            ),
          ),
        );
      }
      final vpc = controller.videoPlayerController.value;
      if (vpc == null || !vpc.value.isInitialized) {
        return const LoaderWidget();
      }
      return _CameraEditFilteredVideoLayer(
        controller: controller,
        videoController: vpc,
      );
    });
  }
}

/// Filter matrix changes must not rebuild the [VideoPlayer] subtree (Android ImageReader max buffers).
class _CameraEditFilteredVideoLayer extends StatelessWidget {
  final CameraEditScreenController controller;
  final VideoPlayerController videoController;

  const _CameraEditFilteredVideoLayer({
    required this.controller,
    required this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ColorFiltered(
        colorFilter: ColorFilter.matrix(controller.selectedFilter.value),
        child: Container(
          decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 15,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: CustomVideoPlayer(
            key: ValueKey<Object>(videoController),
            videoPlayerController: videoController,
            onPlayPause: controller.onPlayPauseToggle,
          ),
        ),
      );
    });
  }
}

class CustomVideoPlayer extends StatelessWidget {
  final VideoPlayerController? videoPlayerController;
  final VoidCallback onPlayPause;

  const CustomVideoPlayer({
    super.key,
    required this.videoPlayerController,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      final videoSize = videoPlayerController!.value.size;
      final fitType =
          videoSize.width < videoSize.height ? BoxFit.cover : BoxFit.fitWidth;
      return InkWell(
        onTap: onPlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipSmoothRect(
              radius: SmoothBorderRadius(cornerRadius: 15, cornerSmoothing: 1),
              child: Container(
                color: ColorRes.blackPure,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: fitType,
                    child: SizedBox(
                        width: videoSize.width,
                        height: videoSize.height,
                        child: VideoPlayer(videoPlayerController!)),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: videoPlayerController!,
              builder: (context, value, child) => AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: value.isPlaying ? 0 : 1,
                child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: ColorRes.blackPure.withValues(alpha: 0.5),
                        shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Image.asset(AssetRes.icPause,
                        width: 35, height: 35, color: ColorRes.bgGrey)),
              ),
            )
          ],
        ),
      );
    } else {
      return const LoaderWidget();
    }
  }
}

class CameraEditActionButtons extends StatelessWidget {
  final CameraEditScreenController controller;

  const CameraEditActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        children: [
          Expanded(
            child: TextButtonCustom(
              onTap: controller.onDiscard,
              title: LKey.discard.tr,
              btnHeight: 44,
              backgroundColor: ColorRes.bgMediumGrey,
              titleColor: ColorRes.textLightGrey,
              horizontalMargin: 10,
            ),
          ),
          Expanded(
            child: Obx(() => controller.isMergingVideo.value
                ? const LoaderWidget()
                : TextButtonCustom(
                    onTap: controller.handleContentUpload,
                    title: LKey.post.tr,
                    btnHeight: 44,
                    backgroundColor: ColorRes.themeAccentSolid,
                    titleColor: ColorRes.whitePure,
                    horizontalMargin: 10,
                  )),
          ),
        ],
      ),
    );
  }
}
