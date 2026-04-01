import 'package:stakBread/model/store/store_product_model.dart';

/// Buyer snapshot on sold-order payload.
class SoldOrderBuyer {
  const SoldOrderBuyer({
    required this.id,
    this.fullname,
    this.username,
  });

  final int id;
  final String? fullname;
  final String? username;

  factory SoldOrderBuyer.fromJson(Map<String, dynamic> json) {
    return SoldOrderBuyer(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      fullname: json['fullname']?.toString(),
      username: json['username']?.toString(),
    );
  }
}

/// Nested product on a sold order line.
class SoldOrderLineProduct {
  const SoldOrderLineProduct({
    required this.id,
    required this.name,
    required this.imageUrls,
  });

  final String id;
  final String name;
  final List<String> imageUrls;

  factory SoldOrderLineProduct.fromJson(Map<String, dynamic> json) {
    return SoldOrderLineProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrls: parseProductImageUrls(json),
    );
  }
}

/// One line on a sold order.
class SoldOrderLineItem {
  const SoldOrderLineItem({
    required this.id,
    required this.quantity,
    required this.price,
    this.product,
    this.productId,
  });

  final int id;
  final int quantity;
  final String price;
  final SoldOrderLineProduct? product;
  /// Line-level `product_id` when nested `product` is missing.
  final int? productId;

  factory SoldOrderLineItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? p;
    final raw = json['product'];
    if (raw is Map<String, dynamic>) p = raw;
    return SoldOrderLineItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      price: json['price']?.toString() ?? '0',
      product: p != null ? SoldOrderLineProduct.fromJson(p) : null,
      productId: int.tryParse(json['product_id']?.toString() ?? ''),
    );
  }
}

/// Order row from POST [order/fetchMySoldOrders] / [order/fetchMyPurchasedOrders].
class SoldOrder {
  const SoldOrder({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.address,
    required this.totalAmount,
    required this.deliveryCharges,
    required this.shippingFee,
    required this.statusRaw,
    required this.paymentStatus,
    this.paymentId,
    this.cancelReason,
    this.createdAt,
    required this.items,
    this.buyer,
    this.seller,
  });

  final int id;
  final int buyerId;
  final int sellerId;
  final String address;
  final String totalAmount;
  final int deliveryCharges;
  final int shippingFee;
  /// API: `pending` | `to_ship` | `completed` | `rejected` | `cancelled`
  final String statusRaw;
  final String paymentStatus;
  final String? paymentId;
  final String? cancelReason;
  final DateTime? createdAt;
  final List<SoldOrderLineItem> items;
  final SoldOrderBuyer? buyer;
  /// Present on purchased-order payloads for buyer UI (seller shop / user).
  final SoldOrderBuyer? seller;

  factory SoldOrder.fromJson(Map<String, dynamic> json) {
    final items = <SoldOrderLineItem>[];
    final itemsRaw = json['items'];
    if (itemsRaw is List) {
      for (final e in itemsRaw) {
        if (e is Map<String, dynamic>) {
          items.add(SoldOrderLineItem.fromJson(e));
        }
      }
    }

    SoldOrderBuyer? buyer;
    final b = json['buyer'];
    if (b is Map<String, dynamic>) {
      buyer = SoldOrderBuyer.fromJson(b);
    }

    SoldOrderBuyer? seller;
    final s = json['seller'];
    if (s is Map<String, dynamic>) {
      seller = SoldOrderBuyer.fromJson(s);
    }

    return SoldOrder(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      buyerId: int.tryParse(json['buyer_id']?.toString() ?? '') ?? 0,
      sellerId: int.tryParse(json['seller_id']?.toString() ?? '') ?? 0,
      address: json['address']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0',
      deliveryCharges:
          int.tryParse(json['delivery_charges']?.toString() ?? '0') ?? 0,
      shippingFee: int.tryParse(json['shipping_fee']?.toString() ?? '0') ?? 0,
      statusRaw: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentId: json['payment_id']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      items: items,
      buyer: buyer,
      seller: seller,
    );
  }
}
