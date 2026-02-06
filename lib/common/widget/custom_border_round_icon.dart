import 'package:flutter/material.dart';
import 'package:stakBread/common/manager/haptic_manager.dart';
import 'package:stakBread/utilities/color_res.dart';

class CustomBorderRoundIcon extends StatelessWidget {
  final String? image;
  final VoidCallback? onTap;
  final Widget? widget;

  const CustomBorderRoundIcon({super.key, this.image, this.onTap, this.widget});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticManager.shared.light();
        onTap?.call();
      },
      child: Container(
        height: 37,
        width: 37,
        decoration: BoxDecoration(
            color: ColorRes.whitePure.withValues(alpha: .20),
            shape: BoxShape.circle,
            border:
                Border.all(color: ColorRes.whitePure.withValues(alpha: .25))),
        child: widget ??
            Center(
              child: Image.asset(image!,
                  color: ColorRes.whitePure, width: 23, height: 23),
            ),
      ),
    );
  }
}
