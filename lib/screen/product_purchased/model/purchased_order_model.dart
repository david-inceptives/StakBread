/// Order status for product purchased (My Orders).
enum PurchasedOrderStatus {
  pending,
  toShip,
  completed,
  cancelled,
  rejected,
}

/// Single purchased order item in My Orders.
class PurchasedOrderModel {
  final String id;
  final String productImagePath;
  final String productName;
  final String storeName;
  final String description;
  final String price;
  final PurchasedOrderStatus status;
  final String placedDate;
  final bool isReimbursed;

  const PurchasedOrderModel({
    required this.id,
    required this.productImagePath,
    required this.productName,
    required this.storeName,
    required this.description,
    required this.price,
    required this.status,
    required this.placedDate,
    this.isReimbursed = false,
  });
}
