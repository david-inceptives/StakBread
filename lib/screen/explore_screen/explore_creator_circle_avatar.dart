import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stakBread/screen/explore_screen/explore_tab_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/color_res.dart';

class ExploreCreatorCircleAvatar extends StatelessWidget {
  final ExploreCreatorItem creator;
  final double radius;

  const ExploreCreatorCircleAvatar({
    super.key,
    required this.creator,
    this.radius = 36,
  });

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    if (creator.avatarUrl != null && creator.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: ColorRes.borderLight,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: creator.avatarUrl!,
            width: d,
            height: d,
            fit: BoxFit.cover,
            placeholder: (_, __) => SizedBox(
              width: d,
              height: d,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, __, ___) => Image.asset(
              AssetRes.icUserPlaceholder,
              width: d,
              height: d,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    if (creator.avatarPath != null && creator.avatarPath!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: ColorRes.borderLight,
        backgroundImage: AssetImage(creator.avatarPath!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: ColorRes.borderLight,
      child: Image.asset(
        AssetRes.icUserPlaceholder,
        width: d * 0.67,
        height: d * 0.67,
        fit: BoxFit.cover,
      ),
    );
  }
}
