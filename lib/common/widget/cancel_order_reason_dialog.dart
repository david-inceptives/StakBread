import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Returns trimmed reason, or `null` if user dismissed. Controller disposed in [dispose].
class CancelOrderReasonDialog extends StatefulWidget {
  const CancelOrderReasonDialog({
    super.key,
    this.titleText,
    this.hintText,
  });

  /// Defaults to [LKey.cancelOrder].
  final String? titleText;

  /// Defaults to [LKey.enterCancelReason].
  final String? hintText;

  @override
  State<CancelOrderReasonDialog> createState() =>
      _CancelOrderReasonDialogState();
}

class _CancelOrderReasonDialogState extends State<CancelOrderReasonDialog> {
  late final TextEditingController _reasonCtrl;

  @override
  void initState() {
    super.initState();
    _reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorRes.whitePure,
      title: Text(
        widget.titleText ?? LKey.cancelOrder.tr,
        style: TextStyleCustom.unboundedSemiBold600(
          fontSize: 17,
          color: ColorRes.textDarkGrey,
        ),
      ),
      content: TextField(
        controller: _reasonCtrl,
        maxLines: 3,
        autofocus: true,
        decoration: InputDecoration(
          labelText: LKey.reason.tr,
          hintText: widget.hintText ?? LKey.enterCancelReason.tr,
          labelStyle: TextStyleCustom.outFitRegular400(
            color: ColorRes.textLightGrey,
            fontSize: 13,
          ),
          hintStyle: TextStyleCustom.outFitRegular400(
            color: ColorRes.textLightGrey,
            fontSize: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorRes.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorRes.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ColorRes.themeAccentSolid, width: 1.5),
          ),
        ),
        style: TextStyleCustom.outFitRegular400(
          color: ColorRes.textDarkGrey,
          fontSize: 15,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<String?>(null),
          child: Text(
            LKey.cancel.tr,
            style: TextStyleCustom.outFitSemiBold600(
              color: ColorRes.textLightGrey,
              fontSize: 14,
            ),
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop<String?>(_reasonCtrl.text.trim()),
          child: Text(
            LKey.submit.tr,
            style: TextStyleCustom.outFitSemiBold600(
              color: ColorRes.themeAccentSolid,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
