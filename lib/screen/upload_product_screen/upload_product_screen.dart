import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

const List<String> _kClothingSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

const List<Color> _kPresetColors = [
  Color(0xFF00B01D),
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFFE91E63),
  Color(0xFFCDDC39),
];

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _picker = ImagePicker();

  final List<XFile> _images = [];
  final Set<String> _selectedClothing = {};
  final Set<int> _selectedShoeEu = {};
  final List<Color> _selectedColors = [];

  static List<int> get _shoeSizes => List.generate(10, (i) => 36 + i);

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85, limit: 12);
      if (files.isEmpty) return;
      setState(() {
        for (final f in files) {
          if (_images.length >= 12) break;
          _images.add(f);
        }
      });
    } catch (e) {
      if (!mounted) return;
      BaseController.share.showSnackBar(e.toString());
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _toggleClothing(String size) {
    setState(() {
      if (_selectedClothing.contains(size)) {
        _selectedClothing.remove(size);
      } else {
        _selectedClothing.add(size);
      }
    });
  }

  void _toggleShoe(int eu) {
    setState(() {
      if (_selectedShoeEu.contains(eu)) {
        _selectedShoeEu.remove(eu);
      } else {
        _selectedShoeEu.add(eu);
      }
    });
  }

  void _togglePresetColor(Color c) {
    setState(() {
      final i = _selectedColors.indexWhere((e) => e == c);
      if (i >= 0) {
        _selectedColors.removeAt(i);
      } else {
        _selectedColors.add(c);
      }
    });
  }

  void _openCustomColorPicker() {
    Color pickerColor = ColorRes.themeAccentSolid;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        final w = (mq.size.width - 48).clamp(260.0, 360.0);
        return AlertDialog(
          title: Text(LKey.pickColor.tr),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (c) => setDialogState(() => pickerColor = c),
                  enableAlpha: false,
                  labelTypes: const [],
                  paletteType: PaletteType.hsvWithHue,
                  colorPickerWidth: w,
                  pickerAreaHeightPercent: 0.65,
                  displayThumbColor: true,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LKey.cancel.tr),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (!_selectedColors.contains(pickerColor)) {
                    _selectedColors.add(pickerColor);
                  }
                });
                Navigator.of(ctx).pop();
              },
              child: Text(LKey.addColor.tr),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      BaseController.share.showSnackBar(LKey.uploadProductValidation.tr);
      return;
    }
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.'));
    if (price == null || price <= 0) {
      BaseController.share.showSnackBar(LKey.uploadProductValidation.tr);
      return;
    }
    // TODO: POST multipart when backend endpoint is available.
    BaseController.share.showSnackBar(LKey.uploadProductPending.tr, second: 3);
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted) Get.back();
    });
  }

  void _onMorePressed() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColorRes.whitePure,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(LKey.clearForm.tr, style: TextStyleCustom.outFitRegular400(color: ColorRes.textDarkGrey)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _images.clear();
                  _selectedClothing.clear();
                  _selectedShoeEu.clear();
                  _selectedColors.clear();
                  _nameController.clear();
                  _descController.clear();
                  _priceController.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyleCustom.outFitRegular400(color: ColorRes.textLightGrey, fontSize: 13.sp),
      filled: true,
      fillColor: ColorRes.whitePure,
      contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.4.h),
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
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.bgLightGrey,
      body: Column(
        children: [
          CustomAppBar(
            title: LKey.uploadProduct.tr,
            rowWidget: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(Icons.more_horiz, color: ColorRes.textDarkGrey, size: 2.4.h),
              onPressed: _onMorePressed,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final horizontal = maxW > 600 ? (maxW - 560) / 2 : 2.h;
                final content = Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontal, 1.h, horizontal, 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildImageSection(maxW),
                        SizedBox(height: 1.5.h),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyleCustom.outFitRegular400(color: ColorRes.textDarkGrey, fontSize: 15.sp),
                          decoration: _fieldDecoration(LKey.productName.tr),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return LKey.fieldRequired.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 1.2.h),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyleCustom.outFitRegular400(color: ColorRes.textDarkGrey, fontSize: 15.sp),
                          decoration: _fieldDecoration(LKey.productDescription.tr),
                        ),
                        SizedBox(height: 1.2.h),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                          ],
                          style: TextStyleCustom.outFitRegular400(color: ColorRes.textDarkGrey, fontSize: 15.sp),
                          decoration: _fieldDecoration(
                            LKey.productPrice.tr,
                            suffix: Padding(
                              padding: EdgeInsets.only(right: 2.w),
                              child: Icon(Icons.euro, size: 2.h, color: ColorRes.textLightGrey),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return LKey.fieldRequired.tr;
                            }
                            final p = double.tryParse(v.trim().replaceAll(',', '.'));
                            if (p == null || p <= 0) {
                              return LKey.fieldRequired.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 2.h),
                        _sectionLabel(LKey.productSizes.tr),
                        SizedBox(height: 0.8.h),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _kClothingSizes.map((s) => _clothingChip(s)).toList(),
                        ),
                        SizedBox(height: 2.h),
                        _sectionLabel(LKey.productColors.tr),
                        SizedBox(height: 0.8.h),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ..._kPresetColors.map(_colorSwatch),
                            _customColorButton(),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        _sectionLabel(LKey.productSizeEu.tr),
                        SizedBox(height: 0.8.h),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _shoeSizes.map(_shoeChip).toList(),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                );
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: content,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(2.h, 0, 2.h, 1.5.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.themeAccentSolid,
                    foregroundColor: ColorRes.whitePure,
                    padding: EdgeInsets.symmetric(vertical: 1.6.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    LKey.uploadProduct.tr,
                    style: TextStyleCustom.outFitMedium500(color: ColorRes.whitePure, fontSize: 16.sp),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyleCustom.outFitMedium500(color: ColorRes.textDarkGrey, fontSize: 14.sp),
    );
  }

  Widget _buildImageSection(double maxWidth) {
    final h = (maxWidth * 0.42).clamp(160.0, 280.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: h,
            color: const Color(0xFFF2F2F2),
            child: _images.isEmpty
                ? Center(
                    child: Icon(Icons.image_outlined, size: 8.h, color: ColorRes.disabledGrey),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(1.2.h),
                    itemCount: _images.length,
                    separatorBuilder: (_, __) => SizedBox(width: 1.2.h),
                    itemBuilder: (context, i) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_images[i].path),
                              width: h - 2.4.h,
                              height: h - 2.4.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Material(
                              color: Colors.black54,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _removeImage(i),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        SizedBox(height: 1.2.h),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: Icon(Icons.add_photo_alternate_outlined, size: 2.2.h, color: ColorRes.whitePure),
          label: Text(
            LKey.uploadProductPictures.tr,
            style: TextStyleCustom.outFitMedium500(color: ColorRes.whitePure, fontSize: 15.sp),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorRes.themeAccentSolid,
            foregroundColor: ColorRes.whitePure,
            padding: EdgeInsets.symmetric(vertical: 1.4.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _clothingChip(String size) {
    final selected = _selectedClothing.contains(size);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleClothing(size),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? ColorRes.themeAccentSolid : ColorRes.borderLight,
              width: selected ? 2 : 1,
            ),
            color: ColorRes.whitePure,
          ),
          child: Text(
            size,
            style: TextStyleCustom.outFitMedium500(
              color: selected ? ColorRes.themeAccentSolid : ColorRes.textDarkGrey,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorSwatch(Color c) {
    final selected = _selectedColors.contains(c);
    return GestureDetector(
      onTap: () => _togglePresetColor(c),
      child: Container(
        width: 11.w.clamp(36.0, 48.0),
        height: 11.w.clamp(36.0, 48.0),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? ColorRes.themeAccentSolid : ColorRes.borderLight,
            width: selected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customColorButton() {
    return Material(
      color: ColorRes.whitePure,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _openCustomColorPicker,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 11.w.clamp(36.0, 48.0),
          height: 11.w.clamp(36.0, 48.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorRes.borderLight),
          ),
          child: Icon(Icons.palette_outlined, color: ColorRes.textDarkGrey, size: 2.2.h),
        ),
      ),
    );
  }

  Widget _shoeChip(int eu) {
    final selected = _selectedShoeEu.contains(eu);
    final label = '$eu EU';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleShoe(eu),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? ColorRes.themeAccentSolid : ColorRes.borderLight,
              width: selected ? 2 : 1,
            ),
            color: ColorRes.whitePure,
          ),
          child: Text(
            label,
            style: TextStyleCustom.outFitMedium500(
              color: selected ? ColorRes.themeAccentSolid : ColorRes.textDarkGrey,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}
