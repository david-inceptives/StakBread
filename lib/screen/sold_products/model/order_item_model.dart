/// Order status for sold products / orders management.
enum OrderStatus {
  pending,
  toShip,
  completed,
  rejected,
}

/// Single order item in Orders Management.
class OrderItemModel {
  final String id;
  final String productImagePath;
  final String productName;
  final String storeName;
  final String description;
  final String price;
  final OrderStatus status;
  final String placedDate;
  final bool isReimbursed;

  const OrderItemModel({
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
