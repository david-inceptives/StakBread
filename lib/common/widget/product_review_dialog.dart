import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// `null` if dismissed without submit.
class ProductReviewDialogResult {
  const ProductReviewDialogResult({
    required this.rating,
    required this.reviewText,
  });

  final int rating;
  final String reviewText;
}

class ProductReviewDialog extends StatefulWidget {
  const ProductReviewDialog({super.key});

  @override
  State<ProductReviewDialog> createState() => _ProductReviewDialogState();
}

class _ProductReviewDialogState extends State<ProductReviewDialog> {
  late final TextEditingController _reviewCtrl;
  int _rating = 5;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _reviewCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _reviewCtrl.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = LKey.fieldRequired.tr);
      return;
    }
    Navigator.of(context).pop<ProductReviewDialogResult>(
      ProductReviewDialogResult(rating: _rating, reviewText: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorRes.whitePure,
      title: Text(
        LKey.review.tr,
        style: TextStyleCustom.unboundedSemiBold600(
          fontSize: 17,
          color: ColorRes.textDarkGrey,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LKey.yourRating.tr,
              style: TextStyleCustom.outFitRegular400(
                color: ColorRes.textLightGrey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final filled = (i + 1) <= _rating;
                return InkWell(
                  onTap: () => setState(() {
                    _rating = i + 1;
                    _errorText = null;
                  }),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.star_rounded,
                      size: 36,
                      color: filled ? ColorRes.orange : ColorRes.borderLight,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewCtrl,
              maxLines: 4,
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              decoration: InputDecoration(
                labelText: LKey.writeYourReview.tr,
                errorText: _errorText,
                labelStyle: TextStyleCustom.outFitRegular400(
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
                  borderSide: const BorderSide(
                    color: ColorRes.themeAccentSolid,
                    width: 1.5,
                  ),
                ),
              ),
              style: TextStyleCustom.outFitRegular400(
                color: ColorRes.textDarkGrey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop<ProductReviewDialogResult?>(null),
          child: Text(
            LKey.cancel.tr,
            style: TextStyleCustom.outFitSemiBold600(
              color: ColorRes.textLightGrey,
              fontSize: 14,
            ),
          ),
        ),
        TextButton(
          onPressed: _submit,
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
