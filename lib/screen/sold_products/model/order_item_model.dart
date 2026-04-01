import 'package:intl/intl.dart';
import 'package:stakBread/model/order/sold_order_model.dart';
import 'package:stakBread/model/store/store_product_model.dart';

/// Order status for sold products / orders management.
enum OrderStatus {
  pending,
  toShip,
  completed,
  rejected,
  cancelled,
}

OrderStatus orderStatusFromApiString(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'to_ship':
      return OrderStatus.toShip;
    case 'completed':
      return OrderStatus.completed;
    case 'rejected':
      return OrderStatus.rejected;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

/// Single row in Orders Management (sold) list UI.
class OrderItemModel {
  final String id;
  /// Local asset path when [networkImageUrl] is null.
  final String productImagePath;
  final String? networkImageUrl;
  final String productName;
  /// Buyer line for sold orders (e.g. name · @username).
  final String storeName;
  final String description;
  final String price;
  final OrderStatus status;
  final String placedDate;
  final bool isReimbursed;

  /// First line product id for seller `acceptOrder` (`product_id`).
  final String? primaryProductId;

  /// Buyer — chat from To Ship (sold orders).
  final int? buyerUserId;
  final String? buyerFullname;
  final String? buyerUsername;

  const OrderItemModel({
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
    this.buyerUserId,
    this.buyerFullname,
    this.buyerUsername,
  });

  factory OrderItemModel.fromSoldOrder(SoldOrder o) {
    final first = o.items.isNotEmpty ? o.items.first : null;
    final product = first?.product;
    var name = product?.name ?? 'Order #${o.id}';
    if (o.items.length > 1) {
      name = '$name (+${o.items.length - 1} more)';
    }

    String buyerLine = '';
    if (o.buyer != null) {
      final fn = o.buyer!.fullname?.trim() ?? '';
      final un = o.buyer!.username?.trim() ?? '';
      if (fn.isNotEmpty && un.isNotEmpty) {
        buyerLine = '$fn · @$un';
      } else if (fn.isNotEmpty) {
        buyerLine = fn;
      } else if (un.isNotEmpty) {
        buyerLine = '@$un';
      }
    }
    if (buyerLine.isEmpty) {
      buyerLine = 'Buyer #${o.buyerId}';
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

    return OrderItemModel(
      id: '${o.id}',
      productImagePath: '',
      networkImageUrl: img,
      productName: name,
      storeName: buyerLine,
      description: desc,
      price: storeProductFormatPriceForUi(o.totalAmount),
      status: orderStatusFromApiString(o.statusRaw),
      placedDate: placed,
      isReimbursed: false,
      primaryProductId: primaryPid,
      buyerUserId: o.buyerId > 0 ? o.buyerId : null,
      buyerFullname: o.buyer?.fullname,
      buyerUsername: o.buyer?.username,
    );
  }
}
