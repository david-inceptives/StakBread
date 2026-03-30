import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/store/store_product_model.dart';
import 'package:stakBread/screen/upload_product_screen/upload_product_screen.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  bool _loading = true;
  bool _failed = false;
  List<StoreProduct> _products = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final me = SessionManager.instance.getUserID();
      final list = await StoreService.instance.fetchProductsByUserId('$me');
      if (!mounted) return;
      setState(() {
        _products = list;
        _failed = false;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _products = [];
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _onDelete(StoreProduct p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LKey.delete.tr),
        content: Text('Delete "${p.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(LKey.delete.tr, style: const TextStyle(color: ColorRes.likeRed)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    BaseController.share.showLoader();
    try {
      final res = await StoreService.instance.deleteProduct(productId: p.id);
      BaseController.share.stopLoader();
      if (res.status == true) {
        if (mounted) {
          setState(() => _products.removeWhere((e) => e.id == p.id));
        }
        BaseController.share.showSnackBar(res.message ?? 'Deleted');
      } else {
        BaseController.share.showSnackBar(res.message ?? LKey.somethingWentWrong.tr);
      }
    } catch (e) {
      BaseController.share.stopLoader();
      BaseController.share.showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            _MyShopAppBar(title: LKey.myShop.tr),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: ColorRes.green),
                    )
                  : RefreshIndicator(
                      color: ColorRes.green,
                      onRefresh: _load,
                      child: _products.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 120),
                                Center(
                                  child: Text(
                                    _failed ? LKey.somethingWentWrong.tr : LKey.noData.tr,
                                    style: TextStyleCustom.outFitRegular400(
                                      fontSize: 14,
                                      color: ColorRes.textLightGrey,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                              itemCount: _products.length,
                              itemBuilder: (context, index) => _MyProductCard(
                                product: _products[index],
                                onEditTap: () async {
                                  await Get.to(() => UploadProductScreen(editProduct: _products[index]));
                                  await _load();
                                },
                                onDeleteTap: () => _onDelete(_products[index]),
                              ),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyShopAppBar extends StatelessWidget {
  final String title;
  const _MyShopAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorRes.whitePure,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: ColorRes.textDarkGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyleCustom.unboundedSemiBold600(
                fontSize: 18,
                color: ColorRes.textDarkGrey,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.more_horiz_rounded,
              size: 22,
              color: ColorRes.textDarkGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyProductCard extends StatelessWidget {
  final StoreProduct product;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const _MyProductCard({required this.product, required this.onEditTap, required this.onDeleteTap});

  @override
  Widget build(BuildContext context) {
    final rating = product.rating.clamp(0, 5).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorRes.whitePure,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _ProductThumb(src: product.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleCustom.unboundedSemiBold600(
                    fontSize: 15,
                    color: ColorRes.textDarkGrey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 11.5,
                    color: ColorRes.textLightGrey,
                    opacity: 0.9,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StarsRow(rating: rating),
                    const SizedBox(width: 8),
                    Text(
                      '${rating.toStringAsFixed(1)} / 5',
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 12.5,
                        color: ColorRes.textDarkGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              SizedBox(
                height: 44,
                width: 92,
                child: ElevatedButton(
                  onPressed: onEditTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorRes.themeAccentSolid,
                    foregroundColor: ColorRes.whitePure,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    LKey.edit.tr,
                    style: TextStyleCustom.outFitSemiBold600(
                      fontSize: 14,
                      color: ColorRes.whitePure,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 30,
                width: 92,
                child: TextButton(
                  onPressed: onDeleteTap,
                  style: TextButton.styleFrom(
                    foregroundColor: ColorRes.likeRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    LKey.delete.tr,
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 13,
                      color: ColorRes.likeRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String? src;
  const _ProductThumb({required this.src});

  @override
  Widget build(BuildContext context) {
    final s = src?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        color: const Color(0xFFEFE7F7),
        child: s.isEmpty
            ? const Icon(Icons.image_outlined, color: ColorRes.textLightGrey)
            : CachedNetworkImage(
                imageUrl: s,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined, color: ColorRes.textLightGrey),
              ),
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final double rating;
  const _StarsRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor().clamp(0, 5);
    final half = (rating - full) >= 0.5 && full < 5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107));
        }
        if (i == full && half) {
          return const Icon(Icons.star_half_rounded, size: 16, color: Color(0xFFFFC107));
        }
        return const Icon(Icons.star_border_rounded, size: 16, color: Color(0xFFFFC107));
      }),
    );
  }
}

