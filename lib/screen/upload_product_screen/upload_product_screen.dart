import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/common/widget/custom_app_bar.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/store/product_attribute_model.dart';
import 'package:stakBread/model/store/store_product_category.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

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
  final _stockController = TextEditingController();
  final _picker = ImagePicker();

  final List<XFile> _images = [];
  final Set<int> _selectedAttributeValueIds = {};

  List<StoreProductCategory> _categories = [];
  String? _selectedCategoryId;
  bool _loadingCategories = true;
  bool _categoriesLoadFailed = false;

  List<ProductAttribute> _attributes = [];
  bool _loadingAttributes = true;
  bool _attributesLoadFailed = false;

  bool _isFeatured = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
      _loadAttributes();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoriesLoadFailed = false;
    });
    try {
      final list = await StoreService.instance.fetchProductCategories();
      if (!mounted) return;
      setState(() {
        _categories = list;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categories = [];
        _loadingCategories = false;
        _categoriesLoadFailed = true;
      });
      BaseController.share.showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _loadAttributes() async {
    setState(() {
      _loadingAttributes = true;
      _attributesLoadFailed = false;
    });
    try {
      final list = await StoreService.instance.fetchProductAttributes();
      if (!mounted) return;
      setState(() {
        _attributes = list;
        _loadingAttributes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _attributes = [];
        _loadingAttributes = false;
        _attributesLoadFailed = true;
      });
      BaseController.share.showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
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

  void _toggleAttributeValue(int valueId) {
    setState(() {
      if (_selectedAttributeValueIds.contains(valueId)) {
        _selectedAttributeValueIds.remove(valueId);
      } else {
        _selectedAttributeValueIds.add(valueId);
      }
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      BaseController.share.showSnackBar(LKey.selectCategory.tr);
      return;
    }
    if (_images.isEmpty) {
      BaseController.share.showSnackBar(LKey.uploadProductValidation.tr);
      return;
    }
    final priceRaw = _priceController.text.trim().replaceAll(',', '.');
    final price = double.tryParse(priceRaw);
    if (price == null || price <= 0) {
      BaseController.share.showSnackBar(LKey.uploadProductValidation.tr);
      return;
    }
    final stock = int.tryParse(_stockController.text.trim());
    if (stock == null || stock < 1) {
      BaseController.share.showSnackBar(LKey.fieldRequired.tr);
      return;
    }

    final attributeValueIds =
        _selectedAttributeValueIds.map((id) => '$id').toList();

    setState(() => _submitting = true);
    BaseController.share.showLoader();
    try {
      final model = await StoreService.instance.addProduct(
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        price: price.toStringAsFixed(2),
        stock: '$stock',
        description: _descController.text.trim(),
        isFeatured: _isFeatured,
        images: List<XFile>.from(_images),
        attributeValueIds: attributeValueIds,
      );
      BaseController.share.stopLoader();
      if (!mounted) return;
      if (model.status == true) {
        BaseController.share.showSnackBar(
          (model.message != null && model.message!.isNotEmpty)
              ? model.message
              : LKey.uploadProductSuccess.tr,
        );
        Get.back();
      } else {
        BaseController.share.showSnackBar(model.message ?? LKey.somethingWentWrong.tr);
      }
    } catch (e) {
      BaseController.share.stopLoader();
      if (mounted) {
        BaseController.share.showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                  _selectedAttributeValueIds.clear();
                  _nameController.clear();
                  _descController.clear();
                  _priceController.clear();
                  _stockController.clear();
                  _selectedCategoryId = null;
                  _isFeatured = false;
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

  List<ProductAttribute> get _visibleAttributes =>
      _attributes.where((a) => a.values.isNotEmpty).toList();

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
                        if (_loadingCategories)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorRes.themeAccentSolid,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    LKey.loadingCategories.tr,
                                    style: TextStyleCustom.outFitRegular400(
                                      color: ColorRes.textLightGrey,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          if (_categoriesLoadFailed && _categories.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: TextButton.icon(
                                onPressed: _loadCategories,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(LKey.retry.tr),
                              ),
                            ),
                          DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: _fieldDecoration(LKey.productCategory.tr),
                            hint: Text(
                              LKey.selectCategory.tr,
                              style: TextStyleCustom.outFitRegular400(
                                color: ColorRes.textLightGrey,
                                fontSize: 14.sp,
                              ),
                            ),
                            isExpanded: true,
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c.id,
                                    child: Text(
                                      c.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyleCustom.outFitRegular400(
                                        color: ColorRes.textDarkGrey,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: _categories.isEmpty
                                ? null
                                : (v) => setState(() => _selectedCategoryId = v),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return LKey.selectCategory.tr;
                              }
                              return null;
                            },
                          ),
                        ],
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
                          decoration: _fieldDecoration(LKey.productPrice.tr),
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
                        SizedBox(height: 1.2.h),
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: TextStyleCustom.outFitRegular400(
                            color: ColorRes.textDarkGrey,
                            fontSize: 15.sp,
                          ),
                          decoration: _fieldDecoration(LKey.productStock.tr),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return LKey.fieldRequired.tr;
                            }
                            final n = int.tryParse(v.trim());
                            if (n == null || n < 1) {
                              return LKey.fieldRequired.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 0.6.h),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            LKey.productFeatured.tr,
                            style: TextStyleCustom.outFitRegular400(
                              color: ColorRes.textDarkGrey,
                              fontSize: 15.sp,
                            ),
                          ),
                          value: _isFeatured,
                          onChanged: (v) => setState(() => _isFeatured = v),
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return ColorRes.whitePure;
                            }
                            return ColorRes.disabledGrey;
                          }),
                          trackColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return ColorRes.themeAccentSolid
                                  .withValues(alpha: 0.55);
                            }
                            return ColorRes.borderLight;
                          }),
                          trackOutlineColor: WidgetStateProperty.resolveWith(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.transparent;
                              }
                              return ColorRes.textLightGrey
                                  .withValues(alpha: 0.35);
                            },
                          ),
                        ),
                        SizedBox(height: 2.h),
                        if (_loadingAttributes)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorRes.themeAccentSolid,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    LKey.loadingProductAttributes.tr,
                                    style: TextStyleCustom.outFitRegular400(
                                      color: ColorRes.textLightGrey,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          if (_attributesLoadFailed && _attributes.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: TextButton.icon(
                                onPressed: _loadAttributes,
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(LKey.retry.tr),
                              ),
                            ),
                          ..._visibleAttributes.expand((attr) {
                            return [
                              _sectionLabel(attr.name),
                              SizedBox(height: 0.8.h),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: attr.values
                                    .where((v) => v.id > 0)
                                    .map((v) => _attributeValueChip(v))
                                    .toList(),
                              ),
                              SizedBox(height: 2.h),
                            ];
                          }),
                        ],
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
                  onPressed: _submitting ? null : _submit,
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

  /// Parses `#RGB`, `#RRGGBB`, `#AARRGGBB` for attribute values stored as hex codes.
  Color? _parseHexColorCode(String input) {
    var s = input.trim();
    if (!s.startsWith('#')) return null;
    s = s.substring(1);
    if (s.length == 3) {
      s = s.split('').map((c) => '$c$c').join();
    }
    if (s.length != 6 && s.length != 8) return null;
    final v = int.tryParse(s, radix: 16);
    if (v == null) return null;
    if (s.length == 6) return Color(0xFF000000 | v);
    return Color(v);
  }

  Widget _attributeValueChip(ProductAttributeValue v) {
    final selected = _selectedAttributeValueIds.contains(v.id);
    final swatch = _parseHexColorCode(v.value);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleAttributeValue(v.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? ColorRes.themeAccentSolid : ColorRes.borderLight,
              width: 2,
            ),
            color: swatch,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (swatch != null) ...[
                const SizedBox(
                  width: 15,
                  height: 15,

                ),
              ],
              swatch == null?Text(
                v.value,
                style: TextStyleCustom.outFitMedium500(
                  color: selected ? ColorRes.themeAccentSolid : ColorRes.textDarkGrey,
                  fontSize: 14.sp,
                ),
              ):SizedBox(),
            ],
          ),
        ),
      ),
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
}
