import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:stakBread/model/store/store_product_model.dart';

class CartItem {
  final StoreProduct product;
  int quantity;
  final String? variantText; // e.g. "Size: M", "Color: Black"
  /// Server cart row id from add-to-cart API (for [StoreService.updateCart]).
  int? serverCartId;
  /// Selected attribute value ids for this line (API `attribute_values`).
  final List<int> selectedAttributeValueIds;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.variantText,
    this.serverCartId,
    this.selectedAttributeValueIds = const [],
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

  static List<int> _normalizeAttributeIds(List<int>? ids) {
    final out = (ids ?? []).where((e) => e > 0).toList()..sort();
    return out;
  }

  static bool _sameAttributeSelection(List<int> a, List<int> b) {
    return listEquals(_normalizeAttributeIds(a), _normalizeAttributeIds(b));
  }

  /// From [StoreService.applyCoupon] — subtracted in [total].
  final RxDouble couponDiscountAmount = 0.0.obs;
  final RxString appliedCouponCode = ''.obs;

  int get totalItemCount => items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => items.fold(0.0, (sum, e) => sum + e.linePrice);

  /// Sum of `shipping_fee` × quantity per line (from product detail / cart product).
  double get totalShippingFee => items.fold(0.0, (sum, e) {
        final fee = e.product.shippingFee;
        if (fee == null || fee < 0) return sum;
        return sum + fee * e.quantity;
      });

  /// Sum of `delivery_days` across cart lines (each line once, not × quantity).
  int get totalDeliveryDaysSum => items.fold(0, (sum, e) {
        final d = e.product.deliveryDays;
        if (d == null || d < 0) return sum;
        return sum + d;
      });

  double get total =>
      math.max(0.0, subtotal + totalShippingFee - couponDiscountAmount.value);

  void setAppliedCoupon(String code, double discountAmount) {
    appliedCouponCode.value = code;
    couponDiscountAmount.value = discountAmount;
  }

  void clearCoupon() {
    appliedCouponCode.value = '';
    couponDiscountAmount.value = 0.0;
  }

  int _indexOf(String productId, List<int> attributeValueIds) {
    return items.indexWhere(
      (e) =>
          e.product.id == productId &&
          _sameAttributeSelection(e.selectedAttributeValueIds, attributeValueIds),
    );
  }

  int findItemIndex(String productId, List<int> attributeValueIds) {
    return _indexOf(productId, _normalizeAttributeIds(attributeValueIds));
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
    List<int>? selectedAttributeValueIds,
  }) {
    final ids = _normalizeAttributeIds(selectedAttributeValueIds);
    final existing = _indexOf(product.id, ids);
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
        selectedAttributeValueIds: ids,
      ));
    }
  }

  void removeItem(String productId, {List<int>? selectedAttributeValueIds}) {
    final ids = _normalizeAttributeIds(selectedAttributeValueIds);
    items.removeWhere(
      (e) =>
          e.product.id == productId &&
          _sameAttributeSelection(e.selectedAttributeValueIds, ids),
    );
  }

  void updateQuantity(String productId, int quantity, {List<int>? selectedAttributeValueIds}) {
    final ids = _normalizeAttributeIds(selectedAttributeValueIds);
    if (quantity <= 0) {
      removeItem(productId, selectedAttributeValueIds: ids);
      return;
    }
    final i = _indexOf(productId, ids);
    if (i >= 0) {
      items[i].quantity = quantity;
      items.refresh();
    }
  }

  void incrementQuantity(String productId, {List<int>? selectedAttributeValueIds}) {
    final ids = _normalizeAttributeIds(selectedAttributeValueIds);
    final i = _indexOf(productId, ids);
    if (i >= 0) {
      items[i].quantity++;
      items.refresh();
    }
  }

  void decrementQuantity(String productId, {List<int>? selectedAttributeValueIds}) {
    final ids = _normalizeAttributeIds(selectedAttributeValueIds);
    final i = _indexOf(productId, ids);
    if (i >= 0) {
      if (items[i].quantity <= 1) {
        removeItem(productId, selectedAttributeValueIds: ids);
      } else {
        items[i].quantity--;
        items.refresh();
      }
    }
  }
}
