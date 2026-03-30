/// One option under a product attribute (e.g. RED under Color).
class ProductAttributeValue {
  const ProductAttributeValue({
    required this.id,
    required this.attributeId,
    required this.value,
  });

  final int id;
  final int attributeId;
  final String value;

  factory ProductAttributeValue.fromJson(Map<String, dynamic> json) {
    return ProductAttributeValue(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      attributeId: int.tryParse(json['attribute_id']?.toString() ?? '') ?? 0,
      value: json['value']?.toString() ?? '',
    );
  }
}

/// Attribute group from GET `productAttributes` (`data` array).
class ProductAttribute {
  const ProductAttribute({
    required this.id,
    required this.name,
    required this.values,
  });

  final int id;
  final String name;
  final List<ProductAttributeValue> values;

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    final raw = json['values'];
    final list = <ProductAttributeValue>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(ProductAttributeValue.fromJson(e));
        }
      }
    }
    return ProductAttribute(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      values: list,
    );
  }
}
