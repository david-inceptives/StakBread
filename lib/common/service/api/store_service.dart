import 'package:image_picker/image_picker.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/service/api/api_service.dart';
import 'package:stakBread/common/service/utils/params.dart';
import 'package:stakBread/common/service/utils/web_service.dart';
import 'package:stakBread/model/general/status_model.dart';
import 'package:stakBread/model/store/product_attribute_model.dart';
import 'package:stakBread/model/store/product_review_model.dart';
import 'package:stakBread/model/store/store_product_category.dart';
import 'package:stakBread/model/store/store_product_model.dart';
import 'package:stakBread/screen/store_screen/cart_controller.dart';

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

/// Stripe PaymentIntent client secret from POST [WebService.order.checkout].
class OrderCheckoutResult {
  OrderCheckoutResult({required this.clientSecret});

  final String clientSecret;

  /// `pi_xxx` from `pi_xxx_secret_yyy`.
  static String? paymentIntentIdFromClientSecret(String clientSecret) {
    const marker = '_secret_';
    final i = clientSecret.indexOf(marker);
    if (i <= 0) return null;
    return clientSecret.substring(0, i);
  }
}

class StoreService {
  StoreService._();

  static final StoreService instance = StoreService._();

  /// GET `stripe/getConnectAccountStatus` — returns `data.is_setup_completed`.
  Future<bool> getStripeConnectIsSetupCompleted() async {
    final decoded =
        await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.stripe.getConnectAccountStatus,
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(
          decoded['message']?.toString() ?? 'Failed to fetch Stripe status');
    }
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final v = data['is_setup_completed'];
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
    }
    return false;
  }

  /// POST `stripe/createConnectAccount` — returns `data.onboarding_url`.
  Future<String> createStripeConnectAccountAndGetOnboardingUrl() async {
    final decoded = await ApiService.instance.call<Map<String, dynamic>>(
      url: WebService.stripe.createConnectAccount,
      param: {},
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ??
          'Failed to create Stripe connect account');
    }
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final url = data['onboarding_url']?.toString().trim();
      if (url != null && url.isNotEmpty) return url;
    }
    return '';
  }

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

  /// GET `productAttributes` — attribute groups with `values` for add-product UI.
  Future<List<ProductAttribute>> fetchProductAttributes() async {
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.productAttributes,
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Failed to load attributes');
    }
    final raw = decoded['data'];
    if (raw is! List) return [];
    final out = <ProductAttribute>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        final a = ProductAttribute.fromJson(item);
        if (a.id > 0 && a.name.isNotEmpty) out.add(a);
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

  Future<List<StoreProduct>> fetchProductsByUserId(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) return [];
    final decoded = await ApiService.instance.callGetAuthenticated<Map<String, dynamic>>(
      url: WebService.store.productByUserId(id),
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Failed to load my products');
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

  /// Best-effort "My products" list. Until backend provides a dedicated endpoint,
  /// we merge multiple store feeds and keep only products matching logged-in `user_id`.
  Future<List<StoreProduct>> fetchMyProducts() async {
    final me = SessionManager.instance.getUserID();
    if (me <= 0) return [];

    Future<List<StoreProduct>> safe(Future<List<StoreProduct>> f) async {
      try {
        return await f;
      } catch (e) {
        Loggers.error('[MY_PRODUCTS] $e');
        return [];
      }
    }

    final lists = await Future.wait([
      safe(fetchProductForYou()),
      safe(fetchFeatureProducts()),
      safe(fetchTopSellingProducts()),
    ]);

    final byId = <String, StoreProduct>{};
    for (final l in lists) {
      for (final p in l) {
        if (p.id.isEmpty) continue;
        byId[p.id] = p;
      }
    }

    final out = <StoreProduct>[];
    for (final p in byId.values) {
      if (p.sellerUserId == me) out.add(p);
    }
    out.sort((a, b) => b.id.compareTo(a.id));
    return out;
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

  /// POST `addProduct` — multipart: name, category_id, price, stock, description, is_featured (0/1), `images[]`, optional repeated `attribute_value_ids[]`.
  Future<StatusModel> addProduct({
    required String name,
    required String categoryId,
    required String price,
    required String stock,
    required String description,
    bool isFeatured = false,
    List<XFile> images = const <XFile>[],
    List<String> attributeValueIds = const [],
  }) async {
    final stringParts = <MapEntry<String, String>>[];
    for (final id in attributeValueIds) {
      final t = id.trim();
      if (t.isNotEmpty) {
        stringParts.add(MapEntry(Params.addProductAttributeValueIds, t));
      }
    }

    return ApiService.instance.multiPartCallApi<StatusModel>(
      url: WebService.store.addProduct,
      param: {
        Params.addProductName: name,
        Params.categoryId: categoryId,
        Params.addProductPrice: price,
        Params.addProductStock: stock,
        Params.description: description,
        Params.addProductIsFeatured: isFeatured ? 1 : 0,
      },
      multipartStringParts: stringParts.isEmpty ? null : stringParts,
      filesMap: {
        Params.addProductImages: [...images],
      },
      fromJson: StatusModel.fromJson,
    );
  }

  /// POST `updateProduct` — multipart: product_id + name, category_id, price, stock, description, is_featured, `images[]`, optional repeated `attribute_value_ids[]`.
  Future<StatusModel> updateProduct({
    required String productId,
    required String name,
    required String categoryId,
    required String price,
    required String stock,
    required String description,
    bool isFeatured = false,
    List<XFile> images = const <XFile>[],
    List<String> attributeValueIds = const [],
  }) async {
    final stringParts = <MapEntry<String, String>>[];
    for (final id in attributeValueIds) {
      final t = id.trim();
      if (t.isNotEmpty) {
        stringParts.add(MapEntry(Params.addProductAttributeValueIds, t));
      }
    }

    return ApiService.instance.multiPartCallApi<StatusModel>(
      url: WebService.store.updateProduct,
      param: {
        'product_id': productId,
        Params.addProductName: name,
        Params.categoryId: categoryId,
        Params.addProductPrice: price,
        Params.addProductStock: stock,
        Params.description: description,
        Params.addProductIsFeatured: isFeatured ? 1 : 0,
      },
      multipartStringParts: stringParts.isEmpty ? null : stringParts,
      filesMap: images.isEmpty ? {} : {Params.addProductImages: [...images]},
      fromJson: StatusModel.fromJson,
    );
  }

  /// POST `deleteProduct` — form-data: product_id
  Future<StatusModel> deleteProduct({required String productId}) async {
    return ApiService.instance.call<StatusModel>(
      url: WebService.store.deleteProduct,
      param: {'product_id': productId},
      fromJson: StatusModel.fromJson,
    );
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

  /// POST multipart: `product_id`, `quantity`, repeated `attribute_values[]` (ids).
  /// Returns server cart line id when present (for [updateCart]).
  Future<int?> addToCart({
    required String productId,
    required int quantity,
    List<int> attributeValueIds = const [],
  }) async {
    final stringParts = <MapEntry<String, String>>[];
    for (final id in attributeValueIds) {
      if (id > 0) {
        stringParts.add(MapEntry(Params.cartAttributeValues, '$id'));
      }
    }

    final decoded = await ApiService.instance.multiPartCallApi<Map<String, dynamic>>(
      url: WebService.store.addToCart,
      param: {
        'product_id': productId,
        'quantity': quantity,
      },
      multipartStringParts: stringParts.isEmpty ? null : stringParts,
      filesMap: const {},
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

  /// One seller per cart: if [product] belongs to a different `sellerUserId` than existing
  /// lines, removes every line (server delete when `serverCartId` exists, then local clear).
  Future<void> replaceCartIfDifferentSeller({
    required CartController cart,
    required StoreProduct product,
  }) async {
    if (cart.items.isEmpty) return;
    final existingSeller = cart.items.first.product.sellerUserId;
    if (existingSeller == product.sellerUserId) return;
    final snapshot = List<CartItem>.from(cart.items);
    for (final item in snapshot) {
      final serverId = item.serverCartId;
      if (item.product.isNetworkImage && serverId != null) {
        try {
          await deleteFromCart(cartId: serverId);
        } catch (_) {}
      }
    }
    cart.replaceAllFromServer([]);
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

  /// POST `order/checkout` — form `address` only; response must include PaymentIntent `client_secret`.
  Future<OrderCheckoutResult> checkoutOrder({required String address}) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      throw Exception('Address is required');
    }
    final decoded = await ApiService.instance.call<Map<String, dynamic>>(
      url: WebService.order.checkout,
      param: {'address': trimmed},
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Checkout failed');
    }
    final secret = _parsePaymentClientSecret(decoded);
    if (secret == null || secret.isEmpty) {
      throw Exception('Missing client_secret in checkout response');
    }
    return OrderCheckoutResult(clientSecret: secret);
  }

  /// POST `order/confirmPayment` — after Stripe PaymentSheet succeeds.
  Future<void> confirmOrderPayment({String? paymentIntentId}) async {
    final param = <String, dynamic>{};
    final id = paymentIntentId?.trim();
    if (id != null && id.isNotEmpty) {
      param['payment_intent_id'] = id;
    }
    final decoded = await ApiService.instance.call<Map<String, dynamic>>(
      url: WebService.order.confirmPayment,
      param: param,
      fromJson: (json) => json,
    );
    if (decoded['status'] != true) {
      throw Exception(
          decoded['message']?.toString() ?? 'Payment confirmation failed');
    }
  }

  static String? _parsePaymentClientSecret(Map<String, dynamic> decoded) {
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      for (final key in [
        'client_secret',
        'clientSecret',
        'payment_intent_client_secret',
      ]) {
        final v = data[key];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString().trim();
        }
      }
    }
    for (final key in ['client_secret', 'clientSecret']) {
      final v = decoded[key];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return null;
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

  static List<int> _attributeValueIdsFromCartLine(Map<String, dynamic> line) {
    final out = <int>[];
    dynamic raw = line['attribute_values'];
    if (raw is! List) raw = line['attributeValues'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          final id = int.tryParse(e['id']?.toString() ?? '');
          if (id != null && id > 0) out.add(id);
        } else {
          final id = int.tryParse(e.toString());
          if (id != null && id > 0) out.add(id);
        }
      }
    }
    if (out.isEmpty && line['variant_id'] != null) {
      final v = int.tryParse(line['variant_id'].toString());
      if (v != null && v > 0) out.add(v);
    }
    out.sort();
    return out;
  }

  static CartItem? _cartItemFromLine(Map<String, dynamic> line) {
    final qty = int.tryParse(line['quantity']?.toString() ?? '0') ?? 0;
    if (qty < 1) return null;
    final cartRowId = int.tryParse(line['id']?.toString() ?? '');
    final selectedIds = _attributeValueIdsFromCartLine(line);
    final product = StoreProduct.fromCartLine(line);
    if (product.id.isEmpty) return null;
    return CartItem(
      product: product,
      quantity: qty,
      variantText: product.summaryForSelectedAttributeValueIds(selectedIds),
      serverCartId: cartRowId,
      selectedAttributeValueIds: selectedIds,
    );
  }
}
