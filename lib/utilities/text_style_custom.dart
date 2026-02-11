import 'package:flutter/material.dart';
import 'package:stakBread/utilities/font_res.dart';

class TextStyleCustom {
  static TextStyle outFitBlack900(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w900);

  static TextStyle outFitExtraBold800(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w800);

  static TextStyle outFitBold700(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w700);

  static TextStyle outFitSemiBold600(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w600);

  static TextStyle outFitMedium500(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w500);

  static TextStyle outFitRegular400(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w400);

  static TextStyle outFitLight300(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w300);

  static TextStyle outFitExtraLight200(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w200);

  static TextStyle outFitThin100(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w100);

  static TextStyle unboundedBlack900(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w900);

  static TextStyle unboundedBold700(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w700);

  static TextStyle unboundedExtraBold800(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w800);

  static TextStyle unboundedExtraLight100(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w100);

  static TextStyle unboundedLight200(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w200);

  static TextStyle unboundedMedium500(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w500);

  static TextStyle unboundedRegular400(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w400);

  static TextStyle unboundedSemiBold600(
          {Color? color, double? opacity, double fontSize = 14}) =>
      TextStyle(
          color: color?.withValues(alpha: opacity ?? 1),
          fontSize: fontSize,
          fontFamily: FontRes.lato,
          fontWeight: FontWeight.w600);
}
