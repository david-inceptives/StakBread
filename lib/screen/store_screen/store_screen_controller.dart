import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/store/store_product_category.dart';

/// API may send [price] as String or num.
String _storePriceRaw(dynamic v) {
  if (v == null) return '0';
  if (v is num) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }
  final s = v.toString().trim();
  return s.isEmpty ? '0' : s;
}

String _storeFormatPriceForUi(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return '\$0';
  if (s.startsWith('\$') || s.startsWith('€')) return s;
  return '\$$s';
}

class StoreProduct {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imagePath; // asset path for product image
  final double rating;
  final String? price; // e.g. "\$299"
  final String? detailDescription; // long description for detail screen
  final List<String>? thumbnailPaths; // optional list of asset paths for thumbnails
  /// When true, [imageUrl] is a server-relative path; use [String.addBaseURL] in UI.
  final bool isNetworkImage;

  /// First variant id from API (`variants[0].id`) — used for [addToCart].
  final int? variantId;

  StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imagePath,
    this.rating = 4.9,
    this.price,
    this.detailDescription,
    this.thumbnailPaths,
    this.isNetworkImage = false,
    this.variantId,
  });

  factory StoreProduct.fromProductForYouJson(Map<String, dynamic> json) {
    return StoreProduct._fromProductApiJson(json);
  }

  /// Same payload shape as list items (`/api/productForYou` and `/api/productDetail/:id`).
  factory StoreProduct.fromProductDetailJson(Map<String, dynamic> json) {
    return StoreProduct._fromProductApiJson(json);
  }

  /// One row from [fetchCart] `cart_items` — display price is always nested [product] price, not line [unit_price].
  factory StoreProduct.fromCartLine(Map<String, dynamic> line) {
    final productJson = line['product'];
    if (productJson is! Map<String, dynamic>) {
      return StoreProduct(
        id: '',
        title: '',
        description: '',
        isNetworkImage: false,
      );
    }
    final base = StoreProduct._fromProductApiJson(productJson);
    int? variantId;
    if (line['variant_id'] != null) {
      variantId = int.tryParse(line['variant_id'].toString());
    }
    return StoreProduct(
      id: base.id,
      title: base.title,
      description: base.description,
      imageUrl: base.imageUrl,
      imagePath: base.imagePath,
      rating: base.rating,
      price: base.price,
      detailDescription: base.detailDescription,
      thumbnailPaths: base.thumbnailPaths,
      isNetworkImage: base.isNetworkImage,
      variantId: variantId,
    );
  }

  factory StoreProduct._fromProductApiJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final description = json['description']?.toString() ?? '';
    final priceRaw = _storePriceRaw(json['price']);
    final images = json['images']?.toString();
    final imagePath = images != null && images.isNotEmpty ? images : null;

    int? variantId;
    final variants = json['variants'];
    if (variants is List && variants.isNotEmpty) {
      final v0 = variants.first;
      if (v0 is Map<String, dynamic>) {
        variantId = int.tryParse(v0['id']?.toString() ?? '');
      }
    }

    return StoreProduct(
      id: id,
      title: name,
      description: description,
      imageUrl: imagePath,
      imagePath: null,
      rating: 4.5,
      price: _storeFormatPriceForUi(priceRaw),
      detailDescription: description,
      thumbnailPaths: null,
      isNetworkImage: imagePath != null,
      variantId: variantId,
    );
  }

  List<String> get effectiveThumbnailSources {
    if (thumbnailPaths != null && thumbnailPaths!.isNotEmpty) return thumbnailPaths!;
    if (isNetworkImage && imageUrl != null && imageUrl!.isNotEmpty) return [imageUrl!];
    if (imagePath != null && imagePath!.isNotEmpty) return [imagePath!];
    return [];
  }
}

class StoreScreenController extends BaseController {
  static const int storeHomeSectionMaxItems = 3;

  RxInt notificationCount = 15.obs;
  RxInt cartCount = 2.obs;

  final RxList<StoreProduct> productsForYou = <StoreProduct>[].obs;
  final RxBool isLoadingProductsForYou = false.obs;

  final RxList<StoreProduct> topSelling = <StoreProduct>[].obs;
  final RxBool isLoadingTopSelling = false.obs;

  final RxList<StoreProductCategory> productCategories = <StoreProductCategory>[].obs;
  final RxBool isLoadingCategories = false.obs;

  /// Up to [storeHomeSectionMaxItems] items for the store home section.
  List<StoreProduct> get productsForYouPreview {
    final list = productsForYou;
    if (list.length <= storeHomeSectionMaxItems) return list.toList();
    return list.sublist(0, storeHomeSectionMaxItems);
  }

  /// Up to [storeHomeSectionMaxItems] items for the top-selling row on the store home.
  List<StoreProduct> get topSellingPreview {
    final list = topSelling;
    if (list.length <= storeHomeSectionMaxItems) return list.toList();
    return list.sublist(0, storeHomeSectionMaxItems);
  }

  @override
  void onInit() {
    super.onInit();
    loadProductsForYou();
    loadTopSellingProducts();
    loadProductCategories();
  }

  /// [silent]: no loading indicators, no error snackbars — lists update in place (e.g. pull-to-refresh).
  /// Returns `true` if the request succeeded.
  Future<bool> loadProductsForYou({bool silent = false}) async {
    if (!silent) isLoadingProductsForYou.value = true;
    try {
      final list = await StoreService.instance.fetchProductForYou();
      productsForYou.assignAll(list);
      return true;
    } catch (e) {
      if (silent) {
        Loggers.error('loadProductsForYou (silent): $e');
      } else {
        showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
      return false;
    } finally {
      if (!silent) isLoadingProductsForYou.value = false;
    }
  }

  /// [silent]: no loading indicators, no error snackbars — lists update in place (e.g. pull-to-refresh).
  /// Returns `true` if the request succeeded.
  Future<bool> loadTopSellingProducts({bool silent = false}) async {
    if (!silent) isLoadingTopSelling.value = true;
    try {
      final list = await StoreService.instance.fetchTopSellingProducts();
      topSelling.assignAll(list);
      return true;
    } catch (e) {
      if (silent) {
        Loggers.error('loadTopSellingProducts (silent): $e');
      } else {
        showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
      return false;
    } finally {
      if (!silent) isLoadingTopSelling.value = false;
    }
  }

  /// Refreshes both sections. Default [silent] keeps the UI stable (no spinners/snackbars).
  /// Shows a short "Refreshed" toast when [silent] and both requests succeed.
  Future<void> refreshStoreHome({bool silent = true}) async {
    final results = await Future.wait([
      loadProductsForYou(silent: silent),
      loadTopSellingProducts(silent: silent),
      loadProductCategories(silent: silent),
    ]);
    if (silent && results.every((e) => e)) {
      showSmallCenterToast(LKey.refreshed.tr, second: 1);
    }
  }

  /// [silent]: no loading indicators / snackbars (e.g. pull-to-refresh).
  Future<bool> loadProductCategories({bool silent = false}) async {
    if (!silent) isLoadingCategories.value = true;
    try {
      final list = await StoreService.instance.fetchProductCategories();
      productCategories.assignAll(list);
      return true;
    } catch (e) {
      if (silent) {
        Loggers.error('loadProductCategories (silent): $e');
      } else {
        showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
      return false;
    } finally {
      if (!silent) isLoadingCategories.value = false;
    }
  }
}
