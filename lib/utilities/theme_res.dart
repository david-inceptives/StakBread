import 'package:flutter/material.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/font_res.dart';

class ThemeRes {
  static ThemeData lightTheme() {
    return ThemeData(
      scaffoldBackgroundColor: ColorRes.whitePure,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorRes.whitePure,
        selectedItemColor: ColorRes.themeAccentSolid,
        unselectedItemColor: ColorRes.textLightGrey,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorRes.whitePure,
        foregroundColor: ColorRes.textDarkGrey,
        titleTextStyle: TextStyle(
          color: ColorRes.textDarkGrey,
          fontSize: 18,
          fontFamily: FontRes.outFitRegular400,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: IconThemeData(color: ColorRes.textDarkGrey),
      ),
      fontFamily: FontRes.outFitRegular400,
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: ColorRes.whitePure),
      sliderTheme: const SliderThemeData(
          trackHeight: 2.5,
          trackShape: RectangularSliderTrackShape(),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
          overlayColor: Colors.transparent,
          activeTrackColor: ColorRes.themeAccentSolid,
          thumbColor: ColorRes.themeAccentSolid),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: ColorRes.whitePure),
        titleMedium: TextStyle(color: ColorRes.textDarkGrey),
        titleSmall: TextStyle(color: ColorRes.textLightGrey),
        bodyLarge: TextStyle(color: ColorRes.textLightGrey),
        bodyMedium: TextStyle(color: ColorRes.textLightGrey),
        bodySmall: TextStyle(color: ColorRes.textLightGrey),
        labelSmall: TextStyle(color: ColorRes.themeAccentSolid),
        labelMedium: TextStyle(color: ColorRes.textLightGrey),
        labelLarge: TextStyle(color: ColorRes.disabledGrey),
      ),
      colorScheme: const ColorScheme.light(
        primary: ColorRes.themeAccentSolid,
        onPrimary: ColorRes.whitePure,
        surface: ColorRes.whitePure,
        onSurface: ColorRes.textDarkGrey,
        surfaceContainerHighest: ColorRes.whitePure,
        outline: ColorRes.borderLight,
      ),
      textSelectionTheme:
          const TextSelectionThemeData(selectionColor: ColorRes.disabledGrey),
      cardTheme: const CardThemeData(color: ColorRes.blueFollow),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: ColorRes.themeAccentSolid,
      dividerColor: ColorRes.borderLight,
      cardColor: ColorRes.whitePure,
      primaryColorDark: ColorRes.blackPure,
      canvasColor: ColorRes.whitePure,
      useMaterial3: false,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorRes.themeAccentSolid,
          foregroundColor: ColorRes.whitePure,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: ColorRes.whitePure,
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorRes.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ColorRes.themeAccentSolid, width: 1.5),
        ),
        labelStyle: TextStyle(color: ColorRes.textLightGrey),
        hintStyle: TextStyle(color: ColorRes.textLightGrey),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData();
  }
}
