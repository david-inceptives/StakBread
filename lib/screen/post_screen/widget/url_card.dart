import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/common/service/url_extractor/parsers/base_parser.dart';
import 'package:stakBread/common/widget/custom_bg_circle_button.dart';
import 'package:stakBread/common/widget/custom_image.dart';
import 'package:stakBread/utilities/asset_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';
import 'package:stakBread/utilities/color_res.dart';

class UrlCard extends StatelessWidget {
  final UrlMetadata? metadata;
  final EdgeInsets? margin;
  final VoidCallback? onDelete;

  const UrlCard({super.key, this.metadata, this.margin, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        metadata?.url?.lunchUrlWithHttps;
      },
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          Container(
            height: 80,
            margin: margin ?? const EdgeInsets.symmetric(vertical: 10),
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 9, cornerSmoothing: 1),
                  side: BorderSide(color: ColorRes.bgGrey)),
            ),
            child: Row(
              spacing: 10,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: ShapeDecoration(
                    shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.horizontal(
                          left: SmoothRadius(
                              cornerRadius: 8, cornerSmoothing: 1)),
                    ),
                    color: ColorRes.bgGrey,
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: const SmoothBorderRadius.horizontal(
                        left:
                            SmoothRadius(cornerRadius: 8, cornerSmoothing: 1)),
                    child: CustomImage(
                      size: const Size(80, 80),
                      radius: 0,
                      image: metadata?.image,
                      isShowPlaceHolder: true,
                      placeHolderImage: AssetRes.icLinkPlaceholder,
                    ),
                  ),
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      metadata?.title ?? '',
                      style: TextStyleCustom.outFitRegular400(
                          color: ColorRes.textDarkGrey, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (metadata?.host != null)
                      Text(
                        metadata?.host ?? '',
                        style: TextStyleCustom.outFitRegular400(
                            color: ColorRes.textLightGrey, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ))
              ],
            ),
          ),
          if (onDelete != null)
            InkWell(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: CustomBgCircleButton(
                  image: AssetRes.icClose1,
                  bgColor: ColorRes.textDarkGrey,
                  size: const Size(25, 25),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
