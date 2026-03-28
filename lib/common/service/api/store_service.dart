import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/service/api/api_service.dart';
import 'package:stakBread/common/service/utils/web_service.dart';
import 'package:stakBread/model/store/product_review_model.dart';
import 'package:stakBread/model/store/store_product_category.dart';
import 'package:stakBread/screen/store_screen/cart_controller.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';

/// Result of POST [WebService.store.applyCoupon].
class CouponApplyResult {
  CouponApplyResult({
    required this.success,
    this.message,
    this.discountAmount = 0,
  });

  final bool success;
  final String? message;
  final double discountAmount;
}

class StoreService {
  StoreService._();

  static final StoreService instance = StoreService._();

  Future<List<StoreProduct>> fetchProductForYou() async {
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.productForYou,
      fromJson: (json) => json,
    );
    final raw = decoded['data'];
    if (raw is! List) return [];
    final list = <StoreProduct>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        list.add(StoreProduct.fromProductForYouJson(item));
      }
    }
    return list;
  }

  /// Featured products for cart “Products you may like” (same item shape as [fetchProductForYou]).
  Future<List<StoreProduct>> fetchFeatureProducts() async {
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.featureProducts,
      fromJson: (json) => json,
    );
    final raw = decoded['data'];
    if (raw is! List) return [];
    final list = <StoreProduct>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        list.add(StoreProduct.fromProductForYouJson(item));
      }
    }
    return list;
  }

  Future<List<StoreProductCategory>> fetchProductCategories() async {
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.productCategories,
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Failed to load categories');
    }
    final raw = decoded['data'];
    if (raw is! List) return [];
    final out = <StoreProductCategory>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        final c = StoreProductCategory.fromJson(item);
        if (c.id.isNotEmpty) out.add(c);
      }
    }
    return out;
  }

  /// GET `productsByCategory/:categoryId` — same product shape as [fetchProductForYou].
  Future<List<StoreProduct>> fetchProductsByCategory(String categoryId) async {
    final id = categoryId.trim();
    if (id.isEmpty) return [];
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.productsByCategory(id),
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Failed to load category products');
    }
    final raw = decoded['data'];
    if (raw is! List) return [];
    final list = <StoreProduct>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        list.add(StoreProduct.fromProductForYouJson(item));
      }
    }
    return list;
  }

  Future<List<StoreProduct>> fetchTopSellingProducts() async {
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.topSellingProducts,
      fromJson: (json) => json,
    );
    final raw = decoded['data'];
    if (raw is! List) return [];
    final list = <StoreProduct>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        list.add(StoreProduct.fromProductForYouJson(item));
      }
    }
    return list;
  }

  Future<StoreProduct?> fetchProductDetail(String productId) async {
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.productDetail(productId),
      fromJson: (json) => json,
    );
    final raw = decoded['data'];
    if (raw is! Map<String, dynamic>) return null;
    return StoreProduct.fromProductDetailJson(raw);
  }

  Future<List<ProductReview>> fetchProductReviews(String productId) async {
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.productReviews(productId),
      fromJson: (json) => json,
    );
    final raw = decoded['data'];
    if (raw is! List) return [];
    final list = <ProductReview>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        list.add(ProductReview.fromJson(item));
      }
    }
    return list;
  }

  static int? _parseCartIdFromResponse(Map<String, dynamic> decoded) {
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      for (final key in ['cart_id', 'id', 'cartId']) {
        final v = data[key];
        if (v != null) {
          final id = int.tryParse(v.toString());
          if (id != null) return id;
        }
      }
    }
    final top = decoded['cart_id'];
    if (top != null) return int.tryParse(top.toString());
    return null;
  }

  /// POST `form-data`: `product_id`, `quantity`, `variant_id`.
  /// Returns server cart line id when present (for [updateCart]).
  Future<int?> addToCart({
    required String productId,
    required int quantity,
    required int variantId,
  }) async {
    final decoded = await ApiService.instance.call<Map<String, dynamic>>(
      url: WebService.store.addToCart,
      param: {
        'product_id': productId,
        'quantity': quantity,
        'variant_id': variantId,
      },
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Add to cart failed');
    }
    final cartId = _parseCartIdFromResponse(decoded);
    if (cartId == null) {
      Loggers.warning('addToCart: no cart id in response, quantity sync may fail');
    }
    return cartId;
  }

  /// POST `form-data`: `cart_id`, `quantity`.
  Future<void> updateCart({
    required int cartId,
    required int quantity,
  }) async {
    final decoded = await ApiService.instance.call<Map<String, dynamic>>(
      url: WebService.store.updateCart,
      param: {
        'cart_id': cartId,
        'quantity': quantity,
      },
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Update cart failed');
    }
  }

  /// POST `form-data`: `cart_id` — remove line when quantity reaches 0.
  Future<void> deleteFromCart({required int cartId}) async {
    final decoded = await ApiService.instance.call<Map<String, dynamic>>(
      url: WebService.store.deleteFromCart,
      param: {
        'cart_id': cartId,
      },
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Delete from cart failed');
    }
  }

  /// POST (server route does not support GET) — full cart for syncing local [CartController].
  Future<List<CartItem>> fetchCartItems() async {
    final decoded = await ApiService.instance.call<Map<String, dynamic>>(
      url: WebService.store.fetchCart,
      param: {},
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Fetch cart failed');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) return [];
    final raw = data['cart_items'];
    if (raw is! List) return [];
    final out = <CartItem>[];
    for (final e in raw) {
      if (e is! Map<String, dynamic>) continue;
      final item = _cartItemFromLine(e);
      if (item != null) out.add(item);
    }
    return out;
  }

  /// POST `form-data`: `code`.
  Future<CouponApplyResult> applyCoupon({required String code}) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return CouponApplyResult(success: false, message: 'Empty coupon code');
    }
    final decoded = await ApiService.instance.call<Map<String, dynamic>>(
      url: WebService.store.applyCoupon,
      param: {'code': trimmed},
      fromJson: (json) => json,
    );
    final ok = decoded['status'] == true;
    final msg = decoded['message']?.toString();
    if (!ok) {
      return CouponApplyResult(success: false, message: msg ?? 'Coupon failed');
    }
    var discount = _parseCouponDiscount(decoded['data']);
    if (discount == 0 && decoded['data'] is! Map<String, dynamic>) {
      discount = _parseCouponDiscount(decoded);
    }
    return CouponApplyResult(
      success: true,
      message: msg,
      discountAmount: discount,
    );
  }

  static double _parseCouponDiscount(dynamic data) {
    if (data == null) return 0;
    if (data is num) return data.toDouble();
    if (data is! Map<String, dynamic>) return 0;
    final m = data;
    const keys = [
      'discount',
      'discount_amount',
      'discountAmount',
      'coupon_discount',
      'amount',
      'saved',
      'value',
      'deduction',
    ];
    for (final key in keys) {
      final v = m[key];
      if (v == null) continue;
      final d = double.tryParse(
        v.toString().replaceAll(RegExp(r'[^\d.-]'), ''),
      );
      if (d != null && d != 0) return d;
    }
    return 0;
  }

  static CartItem? _cartItemFromLine(Map<String, dynamic> line) {
    final qty = int.tryParse(line['quantity']?.toString() ?? '0') ?? 0;
    if (qty < 1) return null;
    final cartRowId = int.tryParse(line['id']?.toString() ?? '');
    int? variantId;
    if (line['variant_id'] != null) {
      variantId = int.tryParse(line['variant_id'].toString());
    }
    final product = StoreProduct.fromCartLine(line);
    if (product.id.isEmpty) return null;
    return CartItem(
      product: product,
      quantity: qty,
      variantText: variantId != null ? 'Standard' : null,
      serverCartId: cartRowId,
      variantId: variantId,
    );
  }
}
