import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:stakBread/model/store/cart_model.dart';
import 'package:stakBread/model/store/store_product_model.dart';

class CartItem {
  final StoreProduct product;
  int quantity;
  final String? variantText; // e.g. "Size: M", "Color: Black"
  /// Server cart row id from add-to-cart API (for [StoreService.updateCart]).
  int? serverCartId;
  /// Selected attribute value ids for this line (API `attribute_values`).
  final List<int> selectedAttributeValueIds;

  /// From fetch cart line `item_total` (quantity × unit, as returned by API).
  final double? serverLineItemTotal;
  /// From fetch cart line `shipping_fee` (per-line fee from API).
  final double? serverLineShippingFee;
  /// From fetch cart line `delivery_days`.
  final int? serverLineDeliveryDays;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.variantText,
    this.serverCartId,
    this.selectedAttributeValueIds = const [],
    this.serverLineItemTotal,
    this.serverLineShippingFee,
    this.serverLineDeliveryDays,
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

  /// Set from POST [fetchCart] `data` totals; drives checkout subtotal/shipping/grand.
  final Rx<CartSummary?> lastServerSummary = Rx<CartSummary?>(null);

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

  double get _lineSubtotal =>
      items.fold(0.0, (sum, e) => sum + (e.serverLineItemTotal ?? e.linePrice));

  /// Sum of shipping from lines when no cart-level summary (uses API line `shipping_fee` when present).
  double get _lineShippingSum => items.fold(0.0, (sum, e) {
        if (e.serverLineShippingFee != null) {
          return sum + e.serverLineShippingFee!;
        }
        final fee = e.product.shippingFee;
        if (fee == null || fee < 0) return sum;
        return sum + fee * e.quantity;
      });

  /// Subtotal for checkout UI (cart API `sub_total` when available).
  double get subtotal =>
      lastServerSummary.value != null
          ? lastServerSummary.value!.subTotal
          : _lineSubtotal;

  /// Shipping for checkout UI (cart API `total_shipping_fee` when available).
  double get totalShippingFee =>
      lastServerSummary.value != null
          ? lastServerSummary.value!.totalShippingFee
          : _lineShippingSum;

  /// Sum of `delivery_days` across cart lines (each line once, not × quantity).
  int get totalDeliveryDaysSum => items.fold(0, (sum, e) {
        final d = e.serverLineDeliveryDays ?? e.product.deliveryDays;
        if (d == null || d < 0) return sum;
        return sum + d;
      });

  double get _grandBeforeCoupon =>
      lastServerSummary.value != null
          ? lastServerSummary.value!.grandTotal
          : (_lineSubtotal + _lineShippingSum);

  double get total =>
      math.max(0.0, _grandBeforeCoupon - couponDiscountAmount.value);

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
  void replaceAllFromServer(List<CartItem> newItems, {CartSummary? summary}) {
    clearCoupon();
    lastServerSummary.value = newItems.isEmpty ? null : summary;
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
      lastServerSummary.value = null;
      items.refresh();
    } else {
      lastServerSummary.value = null;
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
    lastServerSummary.value = null;
    items.refresh();
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
      lastServerSummary.value = null;
      items.refresh();
    }
  }

  void incrementQuantity(String productId, {List<int>? selectedAttributeValueIds}) {
    final ids = _normalizeAttributeIds(selectedAttributeValueIds);
    final i = _indexOf(productId, ids);
    if (i >= 0) {
      items[i].quantity++;
      lastServerSummary.value = null;
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
        lastServerSummary.value = null;
        items.refresh();
      }
    }
  }
}
