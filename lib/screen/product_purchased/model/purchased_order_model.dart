import 'package:intl/intl.dart';
import 'package:stakBread/model/order/sold_order_model.dart';
import 'package:stakBread/model/store/store_product_model.dart';

/// Order status for product purchased (My Orders).
enum PurchasedOrderStatus {
  pending,
  toShip,
  completed,
  cancelled,
  rejected,
}

PurchasedOrderStatus purchasedOrderStatusFromApi(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'pending':
      return PurchasedOrderStatus.pending;
    case 'to_ship':
      return PurchasedOrderStatus.toShip;
    case 'completed':
      return PurchasedOrderStatus.completed;
    case 'cancelled':
      return PurchasedOrderStatus.cancelled;
    case 'rejected':
      return PurchasedOrderStatus.rejected;
    default:
      return PurchasedOrderStatus.pending;
  }
}

/// Single purchased order row (from [SoldOrder] API shape).
class PurchasedOrderModel {
  final String id;
  final String productImagePath;
  final String? networkImageUrl;
  final String productName;
  final String storeName;
  final String description;
  final String price;
  final PurchasedOrderStatus status;
  final String placedDate;
  final bool isReimbursed;

  /// First line `product_id` for [StoreService.reportOrderProduct].
  final String? primaryProductId;

  /// Seller — chat from To Ship (purchased orders).
  final int? sellerUserId;
  final String? sellerFullname;
  final String? sellerUsername;

  const PurchasedOrderModel({
    required this.id,
    required this.productImagePath,
    this.networkImageUrl,
    required this.productName,
    required this.storeName,
    required this.description,
    required this.price,
    required this.status,
    required this.placedDate,
    this.isReimbursed = false,
    this.primaryProductId,
    this.sellerUserId,
    this.sellerFullname,
    this.sellerUsername,
  });

  factory PurchasedOrderModel.fromSoldOrder(SoldOrder o) {
    final first = o.items.isNotEmpty ? o.items.first : null;
    final product = first?.product;
    var name = product?.name ?? 'Order #${o.id}';
    if (o.items.length > 1) {
      name = '$name (+${o.items.length - 1} more)';
    }

    String sellerLine = '';
    if (o.seller != null) {
      final fn = o.seller!.fullname?.trim() ?? '';
      final un = o.seller!.username?.trim() ?? '';
      if (fn.isNotEmpty && un.isNotEmpty) {
        sellerLine = '$fn · @$un';
      } else if (fn.isNotEmpty) {
        sellerLine = fn;
      } else if (un.isNotEmpty) {
        sellerLine = '@$un';
      }
    }
    if (sellerLine.isEmpty) {
      sellerLine = 'Seller #${o.sellerId}';
    }

    final img = product?.imageUrls.isNotEmpty == true
        ? product!.imageUrls.first
        : null;

    final placed = o.createdAt != null
        ? DateFormat.yMMMd().add_jm().format(o.createdAt!.toLocal())
        : '';

    final addr = o.address.trim();
    var desc = addr.isNotEmpty ? addr : (product?.name ?? '');
    final cr = o.cancelReason?.trim();
    if (cr != null && cr.isNotEmpty) {
      desc = desc.isEmpty ? cr : '$cr · $desc';
    }

    String? primaryPid;
    if (first != null) {
      final pid = first.product?.id.trim();
      if (pid != null && pid.isNotEmpty) {
        primaryPid = pid;
      } else if (first.productId != null && first.productId! > 0) {
        primaryPid = '${first.productId}';
      }
    }

    return PurchasedOrderModel(
      id: '${o.id}',
      productImagePath: '',
      networkImageUrl: img,
      productName: name,
      storeName: sellerLine,
      description: desc,
      price: storeProductFormatPriceForUi(o.totalAmount),
      status: purchasedOrderStatusFromApi(o.statusRaw),
      placedDate: placed,
      isReimbursed: false,
      primaryProductId: primaryPid,
      sellerUserId: o.sellerId > 0 ? o.sellerId : null,
      sellerFullname: o.seller?.fullname,
      sellerUsername: o.seller?.username,
    );
  }
}
