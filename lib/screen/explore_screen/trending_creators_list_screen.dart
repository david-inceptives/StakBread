import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/explore_screen/explore_creator_circle_avatar.dart';
import 'package:stakBread/screen/explore_screen/explore_tab_controller.dart';
import 'package:stakBread/screen/explore_screen/resume_view_screen.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Full trending creators list (same data as [ExploreTabController.trendingCreatorsAll]).
class TrendingCreatorsListScreen extends StatelessWidget {
  const TrendingCreatorsListScreen({super.key});

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
          LKey.trendingCreators.tr,
          style: TextStyleCustom.outFitSemiBold600(
            fontSize: 16,
            color: ColorRes.blackPure,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<ExploreTabController>(
        builder: (ctrl) {
          if (ctrl.isTrendingCreatorsLoading && ctrl.trendingCreatorsAll.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.trendingCreatorsAll.isEmpty) {
            return Center(
              child: Text(
                LKey.noData.tr,
                style: TextStyleCustom.outFitRegular400(color: ColorRes.textLightGrey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: ctrl.trendingCreatorsAll.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final creator = ctrl.trendingCreatorsAll[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    ExploreCreatorCircleAvatar(creator: creator, radius: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  creator.name,
                                  style: TextStyleCustom.outFitSemiBold600(
                                    fontSize: 15,
                                    color: ColorRes.textDarkGrey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (creator.verified) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.verified, size: 16, color: ColorRes.themeAccentSolid),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            creator.profession,
                            style: TextStyleCustom.outFitRegular400(
                              fontSize: 13,
                              color: ColorRes.textLightGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: creator.resume != null
                          ? () => Get.to(() => ResumeViewScreen(creator: creator))
                          : null,
                      child: Text(
                        LKey.viewResume.tr,
                        style: TextStyleCustom.outFitSemiBold600(
                          fontSize: 12,
                          color: creator.resume != null
                              ? ColorRes.themeAccentSolid
                              : ColorRes.textLightGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
