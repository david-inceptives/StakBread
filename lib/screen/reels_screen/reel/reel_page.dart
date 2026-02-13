import 'dart:async';
import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/common/service/api/post_service.dart';
import 'package:stakBread/common/widget/black_gradient_shadow.dart';
import 'package:stakBread/common/widget/double_tap_detector.dart';
import 'package:stakBread/model/post_story/post_by_id.dart';
import 'package:stakBread/model/post_story/post_model.dart';
import 'package:stakBread/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:stakBread/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:stakBread/screen/reels_screen/reel/widget/reel_animation_like.dart';
import 'package:stakBread/screen/reels_screen/reel/widget/reel_seek_bar.dart';
import 'package:stakBread/screen/reels_screen/reel/widget/side_bar_list.dart';
import 'package:stakBread/screen/reels_screen/reel/widget/user_information.dart';
import 'package:stakBread/screen/reels_screen/reels_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// ---------------------------------------------------------------
// REEL PAGE (flick_video_player)
// ---------------------------------------------------------------
class ReelPage extends StatefulWidget {
  final Post reelData;
  final bool autoPlay;
  final PostByIdData? postByIdData;
  final bool isFromChat;
  final GlobalKey likeKey;
  final ReelsScreenController reelsScreenController;
  final Function(Post reel) onUpdateReelData;
  final bool isHomePage;

  const ReelPage(
      {super.key,
      required this.reelData,
      this.autoPlay = false,
      this.postByIdData,
      this.isFromChat = false,
      required this.likeKey,
      required this.reelsScreenController,
      required this.onUpdateReelData,
      required this.isHomePage});

  @override
  State<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> {
  FlickManager? _flickManager;
  bool _isDisposed = false;
  late ReelController reelController;
  Rx<TapDownDetails?> details = Rx(null);
  final dashboardController = Get.find<DashboardScreenController>();
  bool _showBufferingIndicator = false;
  Timer? _bufferingTimer;

  VideoPlayerController? get _controller =>
      _flickManager?.flickVideoManager?.videoPlayerController;

  bool get _initialized =>
      _flickManager != null &&
      (_flickManager!.flickVideoManager?.isVideoInitialized ?? false);

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<ReelController>(tag: '${widget.reelData.id}')) {
      reelController = Get.find<ReelController>(tag: '${widget.reelData.id}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.isFromChat) {
          reelController.updateReelData(reel: widget.reelData);
        }
        reelController.notifyCommentSheet(widget.postByIdData);
      });
    } else {
      reelController = Get.put(
        ReelController(widget.reelData.obs, widget.onUpdateReelData),
        tag: '${widget.reelData.id}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reelController.notifyCommentSheet(widget.postByIdData);
      });
    }

    _initializeAndPlayVideo();
  }

  /// Don't block play: quick cache check (500ms). Miss → stream from network + cache in background.
  static const Duration _cacheWaitTimeout = Duration(milliseconds: 500);

  Future<void> _initializeAndPlayVideo({int retryCount = 0}) async {
    if (_isDisposed) return;

    final videoUrl = widget.reelData.video?.addBaseURL() ?? '';
    if (videoUrl.isEmpty) return;

    try {
      File? cachedFile;
      try {
        cachedFile = await DefaultCacheManager()
            .getSingleFile(videoUrl)
            .timeout(_cacheWaitTimeout);
        if (!await cachedFile.exists()) cachedFile = null;
      } catch (_) {
        cachedFile = null;
      }

      if (_isDisposed) return;

      final VideoPlayerController videoController = cachedFile != null
          ? VideoPlayerController.file(cachedFile)
          : VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      if (cachedFile == null) {
        DefaultCacheManager().getSingleFile(videoUrl);
      }

      await videoController.initialize();
      if (_isDisposed) {
        videoController.dispose();
        return;
      }
      videoController.setLooping(true);

      final flickManager = FlickManager(
        videoPlayerController: videoController,
        autoInitialize: false,
        autoPlay: false,
      );

      if (_isDisposed) {
        flickManager.dispose();
        return;
      }

      flickManager.flickVideoManager?.addListener(_onBufferingChanged);

      if (dashboardController.selectedPageIndex.value != 0 && widget.isHomePage) {
        if (mounted) setState(() => _flickManager = flickManager);
        return;
      }
      if (widget.autoPlay &&
          widget.reelsScreenController.isCurrentPageVisible) {
        flickManager.flickControlManager?.play();
        _increaseViewsCount(widget.reelData);
      }

      if (mounted) setState(() => _flickManager = flickManager);
    } catch (e) {
      debugPrint('Video init error: $e');
      if (retryCount < 3 && !_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 500));
        _initializeAndPlayVideo(retryCount: retryCount + 1);
      } else if (mounted) {
        setState(() {});
      }
    }
  }

  void _onBufferingChanged() {
    if (!mounted || _isDisposed) return;
    final buffering = _flickManager?.flickVideoManager?.isBuffering ?? false;
    if (buffering) {
      _bufferingTimer?.cancel();
      _bufferingTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted || _isDisposed) return;
        if (_flickManager?.flickVideoManager?.isBuffering ?? false) {
          setState(() => _showBufferingIndicator = true);
        }
      });
    } else {
      _bufferingTimer?.cancel();
      _bufferingTimer = null;
      if (_showBufferingIndicator) setState(() => _showBufferingIndicator = false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bufferingTimer?.cancel();
    _bufferingTimer = null;
    _flickManager?.flickVideoManager?.removeListener(_onBufferingChanged);
    _flickManager?.dispose();
    _flickManager = null;
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (_flickManager == null || !_initialized) return;

    if ((info.visibleFraction * 100) > 90) {
      if (!(_flickManager!.flickVideoManager?.isPlaying ?? false)) {
        _flickManager!.flickControlManager?.play();
      }
    } else {
      if (_flickManager!.flickVideoManager?.isPlaying ?? false) {
        _flickManager!.flickControlManager?.pause();
      }
    }
    if (mounted) setState(() {});
  }

  void onPlayPause() {
    if (_flickManager == null || !_initialized) return;
    _flickManager!.flickControlManager?.togglePlay();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapDetector(
      onDoubleTap: (value) {
        if (details.value != null) return;
        details.value = value;
      },
      child: _flickManager == null
          ? const ColoredBox(color: ColorRes.blackPure)
          : FlickVideoPlayer(
              flickManager: _flickManager!,
              flickVideoWithControls: Stack(
                alignment: Alignment.bottomCenter,
                fit: StackFit.expand,
                children: [
                  VisibilityDetector(
                    key: Key('reel_${widget.reelData.id}'),
                    onVisibilityChanged: _handleVisibilityChanged,
                    child: InkWell(
                      onTap: onPlayPause,
                      child: FlickNativeVideoPlayer(
                        videoPlayerController: _controller,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (_showBufferingIndicator)
                    const IgnorePointer(
                      child: Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(ColorRes.bgGrey),
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                      onTap: onPlayPause,
                      child: const BlackGradientShadow()),
                  ListenableBuilder(
                    listenable: _flickManager!.flickVideoManager!,
                    builder: (_, __) {
                      final isPlaying =
                          _flickManager!.flickVideoManager?.isPlaying ?? true;
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: isPlaying ? 0.0 : 1.0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            alignment: const Alignment(0.25, 0),
                            child: Image.asset(
                              isPlaying ? AssetRes.icPause : AssetRes.icPlay,
                              width: 45,
                              height: 45,
                              color: ColorRes.bgGrey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ReelInfoSection(
                    controller: reelController,
                    likeKey: widget.likeKey,
                    videoPlayerPlusController: _controller,
                  ),
                  Obx(() {
                    if (details.value == null) return const SizedBox();
                    return ReelAnimationLike(
                      likeKey: widget.likeKey,
                      position: details.value!.globalPosition,
                      size: const Size(50, 50),
                      leftRightPosition: 8,
                      onLikeCall: () {
                        if (reelController.reelData.value.isLiked == true) {
                          return;
                        }
                        reelController.onLikeTap();
                      },
                      onCompleteAnimation: () => details.value = null,
                    );
                  }),
                ],
              ),
            ),
    );
  }

  void _increaseViewsCount(Post reelData) {
    PostService.instance.increaseViewsCount(postId: reelData.id).then((value) {
      if (value.status == true) {
        reelController.updateReelData(reel: reelData, isIncreaseCoin: true);
      }
    });
  }
}

class ReelInfoSection extends StatelessWidget {
  final ReelController controller;
  final GlobalKey likeKey;
  final VideoPlayerController? videoPlayerPlusController;

  const ReelInfoSection({
    super.key,
    required this.controller,
    required this.likeKey,
    required this.videoPlayerPlusController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ReelInfoRow(controller: controller, likeKey: likeKey),
        ReelSeekBar(
            videoController: videoPlayerPlusController, controller: controller),
      ],
    );
  }
}

class ReelInfoRow extends StatelessWidget {
  final ReelController controller;
  final GlobalKey likeKey;

  const ReelInfoRow(
      {super.key, required this.controller, required this.likeKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: UserInformation(controller: controller)),
        SideBarList(controller: controller, likeKey: likeKey),
      ],
    );
  }
}
