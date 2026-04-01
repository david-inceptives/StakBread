/// Cart `data` object from POST [fetchCart] (totals + lines).
class CartSummary {
  final int totalItems;
  final double subTotal;
  final double totalShippingFee;
  final double grandTotal;
  final int? deliveryDays;

  const CartSummary({
    required this.totalItems,
    required this.subTotal,
    required this.totalShippingFee,
    required this.grandTotal,
    this.deliveryDays,
  });

  static CartSummary? tryFromDataMap(Map<String, dynamic>? data) {
    if (data == null) return null;
    if (!data.containsKey('sub_total') &&
        !data.containsKey('grand_total') &&
        !data.containsKey('total_shipping_fee')) {
      return null;
    }
    return CartSummary(
      totalItems: int.tryParse(data['total_items']?.toString() ?? '') ?? 0,
      subTotal: _parseDouble(data['sub_total']),
      totalShippingFee: _parseDouble(data['total_shipping_fee']),
      grandTotal: _parseDouble(data['grand_total']),
      deliveryDays: _parseNullableInt(data['delivery_days']),
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(
          v.toString().replaceAll(RegExp(r'[^\d.-]'), ''),
        ) ??
        0;
  }

  static int? _parseNullableInt(dynamic v) {
    if (v == null) return null;
    return int.tryParse(v.toString());
  }
}
