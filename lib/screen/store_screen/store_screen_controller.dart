import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/service/api/store_service.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/store/shop_banner_model.dart';
import 'package:stakBread/model/store/store_product_category.dart';
import 'package:stakBread/model/store/store_product_model.dart';

export 'package:stakBread/model/store/store_product_model.dart';

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

  final RxList<ShopBanner> shopBanners = <ShopBanner>[].obs;
  final RxBool isLoadingShopBanners = false.obs;

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
    loadShopBanners();
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
      loadShopBanners(silent: silent),
    ]);
    if (silent && results.every((e) => e)) {
      showSmallCenterToast(LKey.refreshed.tr, second: 1);
    }
  }

  /// [silent]: no loading indicators / snackbars (e.g. pull-to-refresh).
  Future<bool> loadShopBanners({bool silent = false}) async {
    if (!silent) isLoadingShopBanners.value = true;
    try {
      final list = await StoreService.instance.fetchShopBanners();
      shopBanners.assignAll(list);
      return true;
    } catch (e) {
      if (silent) {
        Loggers.error('loadShopBanners (silent): $e');
      } else {
        showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
      return false;
    } finally {
      if (!silent) isLoadingShopBanners.value = false;
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
