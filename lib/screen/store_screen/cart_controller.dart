import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:stakBread/model/store/store_product_model.dart';

class CartItem {
  final StoreProduct product;
  int quantity;
  final String? variantText; // e.g. "Size: M", "Color: Black"
  /// Server cart row id from add-to-cart API (for [StoreService.updateCart]).
  int? serverCartId;
  /// Matches API `variant_id` on the cart line (null = no variant row).
  final int? variantId;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.variantText,
    this.serverCartId,
    this.variantId,
  });

  double get linePrice {
    final p = _parsePrice(product.price);
    return p * quantity;
  }

  static double _parsePrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return 0;
    final cleaned = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}

class CartController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;

  /// From [StoreService.applyCoupon] — subtracted in [total].
  final RxDouble couponDiscountAmount = 0.0.obs;
  final RxString appliedCouponCode = ''.obs;

  static const double deliveryFee = 10.0;

  int get totalItemCount => items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => items.fold(0.0, (sum, e) => sum + e.linePrice);

  double get total =>
      math.max(0.0, subtotal + deliveryFee - couponDiscountAmount.value);

  void setAppliedCoupon(String code, double discountAmount) {
    appliedCouponCode.value = code;
    couponDiscountAmount.value = discountAmount;
  }

  void clearCoupon() {
    appliedCouponCode.value = '';
    couponDiscountAmount.value = 0.0;
  }

  int _indexOf(String productId, int? variantId) {
    return items.indexWhere(
      (e) => e.product.id == productId && e.variantId == variantId,
    );
  }

  /// Replaces in-memory cart with server state from [fetchCart].
  void replaceAllFromServer(List<CartItem> newItems) {
    clearCoupon();
    items.assignAll(newItems);
    items.refresh();
  }

  void addItem(
    StoreProduct product, {
    int quantity = 1,
    String? variantText,
    int? serverCartId,
    int? variantId,
  }) {
    final vid = variantId ?? product.variantId;
    final existing = _indexOf(product.id, vid);
    if (existing >= 0) {
      items[existing].quantity += quantity;
      if (serverCartId != null) {
        items[existing].serverCartId = serverCartId;
      }
      items.refresh();
    } else {
      items.add(CartItem(
        product: product,
        quantity: quantity,
        variantText: variantText,
        serverCartId: serverCartId,
        variantId: vid,
      ));
    }
  }

  void removeItem(String productId, {int? variantId}) {
    items.removeWhere(
      (e) => e.product.id == productId && e.variantId == variantId,
    );
  }

  void updateQuantity(String productId, int quantity, {int? variantId}) {
    if (quantity <= 0) {
      removeItem(productId, variantId: variantId);
      return;
    }
    final i = _indexOf(productId, variantId);
    if (i >= 0) {
      items[i].quantity = quantity;
      items.refresh();
    }
  }

  void incrementQuantity(String productId, {int? variantId}) {
    final i = _indexOf(productId, variantId);
    if (i >= 0) {
      items[i].quantity++;
      items.refresh();
    }
  }

  void decrementQuantity(String productId, {int? variantId}) {
    final i = _indexOf(productId, variantId);
    if (i >= 0) {
      if (items[i].quantity <= 1) {
        removeItem(productId, variantId: variantId);
      } else {
        items[i].quantity--;
        items.refresh();
      }
    }
  }
}
