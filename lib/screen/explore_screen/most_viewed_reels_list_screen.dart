import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/reel_list.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/post_story/post_model.dart';
import 'package:stakBread/screen/explore_screen/explore_tab_controller.dart';
import 'package:stakBread/screen/reels_screen/reels_screen.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Full most-viewed reels grid; opens [ReelsScreen] with the same list as Explore.
class MostViewedReelsListScreen extends StatelessWidget {
  const MostViewedReelsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      appBar: AppBar(
        backgroundColor: ColorRes.whitePure,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ColorRes.blackPure, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text(
          LKey.trendingReels.tr,
          style: TextStyleCustom.outFitSemiBold600(
            fontSize: 16,
            color: ColorRes.blackPure,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<ExploreTabController>(
        builder: (ctrl) {
          if (ctrl.isMostViewedReelsLoading && ctrl.mostViewedReelsAll.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.mostViewedReelsAll.isEmpty) {
            return Center(
              child: Text(
                LKey.noData.tr,
                style: TextStyleCustom.outFitRegular400(color: ColorRes.textLightGrey),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(1, 8, 1, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
              mainAxisExtent: 172,
            ),
            itemCount: ctrl.mostViewedReelsAll.length,
            itemBuilder: (context, index) {
              final post = ctrl.mostViewedReelsAll[index];
              return ReelGridCardView(
                post: post,
                isPinShow: false,
                onTap: () {
                  final reels = RxList<Post>.from(ctrl.mostViewedReelsAll);
                  Get.to(
                    () => ReelsScreen(reels: reels, position: index),
                    preventDuplicates: false,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
