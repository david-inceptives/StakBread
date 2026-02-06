import 'package:flutter/cupertino.dart';
import 'package:stakBread/common/widget/custom_back_button.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Widget? widget;
  final Widget? rowWidget;
  final String? subTitle;
  final TextStyle? titleStyle;
  final Color? bgColor;
  final Color? iconColor;
  final bool isLoading;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.widget,
      this.subTitle,
      this.titleStyle,
      this.bgColor,
      this.iconColor,
      this.rowWidget,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: bgColor ?? ColorRes.bgLightGrey,
      child: SafeArea(
        bottom: false,
        child: Column(
          spacing: widget != null ? 10 : 0,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(
                  color: iconColor,
                  width: 18,
                  height: 18,
                  padding: const EdgeInsets.all(15),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: titleStyle ?? TextStyleCustom.unboundedMedium500(color: ColorRes.textDarkGrey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isLoading)
                        CupertinoActivityIndicator(
                          color: ColorRes.textLightGrey,
                          radius: 8,
                        )
                      else if (subTitle != null)
                        Text(
                          subTitle ?? '',
                          style: TextStyleCustom.outFitLight300(
                            color: ColorRes.textLightGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                rowWidget ?? const SizedBox(width: 48)
              ],
            ),
            widget ?? const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
