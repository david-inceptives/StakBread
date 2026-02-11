import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/screen/explore_screen/explore_tab_controller.dart';
import 'package:stakBread/screen/explore_screen/resume_view_screen.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Full-screen "View All" for Trending Creators.
class TrendingCreatorsScreen extends StatelessWidget {
  final List<ExploreCreatorItem> creators;
  final void Function(ExploreCreatorItem creator)? onCreatorTap;

  const TrendingCreatorsScreen({super.key, required this.creators, this.onCreatorTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(
              title: LKey.trendingCreators.tr,
              titleStyle: TextStyleCustom.unboundedMedium500(
                fontSize: 18,
                color: ColorRes.textDarkGrey,
              ),
              bgColor: ColorRes.whitePure,
              iconColor: ColorRes.textDarkGrey,
            ),
            Expanded(
              child: creators.isEmpty
                  ? Center(
                      child: Text(
                        LKey.noData.tr,
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 14,
                          color: ColorRes.textLightGrey,
                        ),
                      ),
                    )
                  : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: creators.length,
                  itemBuilder: (context, index) {
                    final creator = creators[index];
                    return _CreatorCard(
                      creator: creator,
                      onProfileTap: onCreatorTap != null ? () => onCreatorTap!(creator) : null,
                    );
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorCard extends StatelessWidget {
  final ExploreCreatorItem creator;
  final VoidCallback? onProfileTap;

  const _CreatorCard({required this.creator, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorRes.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(36),
            child: CircleAvatar(
            radius: 36,
            backgroundColor: ColorRes.borderLight,
            backgroundImage: creator.avatarPath != null && creator.avatarPath!.isNotEmpty
                ? AssetImage(creator.avatarPath!) as ImageProvider
                : null,
            child: creator.avatarPath == null || creator.avatarPath!.isEmpty
                ? Image.asset(AssetRes.icUserPlaceholder, width: 48, height: 48, fit: BoxFit.cover)
                : null,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onProfileTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    creator.name,
                  style: TextStyleCustom.outFitSemiBold600(
                    fontSize: 14,
                    color: ColorRes.textDarkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (creator.verified) ...[
                const SizedBox(width: 4),
                Icon(Icons.verified, size: 14, color: ColorRes.themeAccentSolid),
              ],
            ],
          ),
          ),
          const SizedBox(height: 2),
          InkWell(
            onTap: onProfileTap,
            child: Text(
              creator.profession,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 12,
              color: ColorRes.textLightGrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: ColorRes.themeAccentSolid,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => Get.to(() => ResumeViewScreen(creator: creator)),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      LKey.viewResume.tr,
                      style: TextStyleCustom.outFitSemiBold600(
                        fontSize: 12,
                        color: ColorRes.whitePure,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
