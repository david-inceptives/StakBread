import 'dart:ui' as ui show Gradient;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/utilities/color_res.dart';

class StyleRes {
  static Gradient themeGradient = const LinearGradient(
    colors: [ColorRes.themeGradient1, ColorRes.themeGradient2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static Gradient textDarkGreyGradient({double opacity = 1}) => LinearGradient(
        colors: [
          ColorRes.textDarkGrey.withValues(alpha: opacity),
          ColorRes.textDarkGrey.withValues(alpha: opacity)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static Gradient disabledGreyGradient({double opacity = 1}) => LinearGradient(
        colors: [
          ColorRes.disabledGrey.withValues(alpha: opacity),
          ColorRes.disabledGrey.withValues(alpha: opacity)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static Gradient textLightGreyGradient({double opacity = 1}) => LinearGradient(
        colors: [
          ColorRes.textLightGrey.withValues(alpha: opacity),
          ColorRes.textLightGrey.withValues(alpha: opacity)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  static Shader wavesGradient = ui.Gradient.linear(
    const Offset(70, 50),
    Offset(Get.width / 2, 0),
    [ColorRes.themeGradient1, ColorRes.themeGradient2],
  );
}
