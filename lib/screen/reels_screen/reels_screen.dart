import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/my_refresh_indicator.dart';
import 'package:stakBread/common/widget/no_data_widget.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/post_story/post_by_id.dart';
import 'package:stakBread/model/post_story/post_model.dart';
import 'package:stakBread/screen/comment_sheet/widget/hashtag_and_mention_view.dart';
import 'package:stakBread/screen/reels_screen/reel/reel_page.dart';
import 'package:stakBread/screen/reels_screen/reels_screen_controller.dart';
import 'package:stakBread/screen/reels_screen/widget/reels_text_field.dart';
import 'package:stakBread/screen/reels_screen/widget/reels_top_bar.dart';
import 'package:stakBread/utilities/color_res.dart';

// ---------------------------------------------------------------
// REELS SCREEN (PAGEVIEW)
// ---------------------------------------------------------------
class ReelsScreen extends StatefulWidget {
  final RxList<Post> reels;
  final int position;
  final Widget? widget;
  final Future<void> Function()? onFetchMoreData;
  final Future<void> Function()? onRefresh;
  final RxBool? isLoading;
  final PostByIdData? postByIdData;
  final bool isHomePage;
  final bool isFromChat;

  const ReelsScreen({
    super.key,
    required this.reels,
    required this.position,
    this.widget,
    this.onFetchMoreData,
    this.onRefresh,
    this.isLoading,
    this.postByIdData,
    this.isHomePage = false,
    this.isFromChat = false,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late final ReelsScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
        ReelsScreenController(
          reels: widget.reels,
          currentIndex: widget.position.obs,
          onFetchMoreData: widget.onFetchMoreData,
          isHomePage: widget.isHomePage,
        ),
        tag: widget.isHomePage ? ReelsScreenController.tag : '${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.blackPure,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: MyRefreshIndicator(
                  onRefresh: () async {
                    await controller.handleRefresh(widget.onRefresh);
                  },
                  shouldRefresh: widget.onRefresh != null,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Obx(() {
                        final reels = widget.reels;
                        if (widget.isLoading?.value == true && reels.isEmpty) {
                          return Center(child: CupertinoActivityIndicator(color: ColorRes.textLightGrey));
                        }
                        if (widget.isLoading?.value == false && reels.isEmpty) {
                          return NoDataWidgetWithScroll(
                              title: LKey.reelsEmptyTitle.tr, description: LKey.reelsEmptyDescription.tr);
                        }
                        return PageView.builder(
                          controller: controller.pageController,
                          physics: const CustomPageViewScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: reels.length,
                          onPageChanged: controller.onPageChanged,
                          itemBuilder: (context, index) {
                            return Obx(
                              () {
                                bool isLoading = controller.isLoading.value;
                                return isLoading
                                    ? Center(child: CupertinoActivityIndicator(color: ColorRes.textLightGrey))
                                    : ReelPage(
                                        reelData: reels[index],
                                        autoPlay: index == controller.currentIndex.value,
                                        likeKey: GlobalKey(),
                                        reelsScreenController: controller,
                                        onUpdateReelData: controller.onUpdateReelData,
                                        isHomePage: widget.isHomePage);
                              },
                            );
                          },
                        );
                      }),
                      HashTagAndMentionUserView(helper: controller.commentHelper),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ReelsTopBar(controller: controller, widget: widget.widget),
        ],
      ),
    );
  }
}

/// TikTok-style: halka swipe pe bhi next/previous video pe snap (low velocity threshold).
class CustomPageViewScrollPhysics extends PageScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  /// Halka swipe bhi page change trigger kare (default threshold zyada high hota hai).
  static const double _minVelocityForPageChange = 15.0;

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 0.8, stiffness: 2000, damping: 52);

  double _pageFromPixels(ScrollMetrics position) {
    return position.pixels / position.viewportDimension;
  }

  double _pixelsFromPage(ScrollMetrics position, double page) {
    return page * position.viewportDimension;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    double page = _pageFromPixels(position);
    // Low threshold: halka swipe = next/prev page
    if (velocity < -_minVelocityForPageChange) {
      page = (page - 0.5).roundToDouble();
    } else if (velocity > _minVelocityForPageChange) {
      page = (page + 0.5).roundToDouble();
    } else {
      page = page.roundToDouble();
    }
    final double target = _pixelsFromPage(position, page);
    if ((target - position.pixels).abs() < 0.5) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: toleranceFor(position),
    );
  }
}
