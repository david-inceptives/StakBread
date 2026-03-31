import 'dart:convert';

import 'package:stakBread/model/store/product_review_model.dart';

/// One linked attribute value on a product (`attribute_values[]` from API).
class StoreProductAttributeValue {
  const StoreProductAttributeValue({
    required this.id,
    required this.attributeId,
    required this.value,
    this.attributeName,
  });

  final int id;
  final int attributeId;
  final String value;
  final String? attributeName;

  factory StoreProductAttributeValue.fromJson(Map<String, dynamic> json) {
    String? attrName;
    final attr = json['attribute'];
    if (attr is Map<String, dynamic>) {
      attrName = attr['name']?.toString();
    }
    return StoreProductAttributeValue(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      attributeId: int.tryParse(json['attribute_id']?.toString() ?? '') ?? 0,
      value: json['value']?.toString() ?? '',
      attributeName: attrName,
    );
  }
}

/// API may send [price] as String or num.
String storeProductPriceRaw(dynamic v) {
  if (v == null) return '0';
  if (v is num) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }
  final s = v.toString().trim();
  return s.isEmpty ? '0' : s;
}

String storeProductFormatPriceForUi(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return '\$0';
  if (s.startsWith('\$') || s.startsWith('€')) return s;
  return '\$$s';
}

double storeProductAverageRating(List<ProductReview> reviews) {
  if (reviews.isEmpty) return 0;
  var sum = 0;
  for (final r in reviews) {
    sum += r.rating.clamp(0, 5);
  }
  return sum / reviews.length;
}

int? _parseOptionalPositiveInt(dynamic v) {
  if (v == null) return null;
  final n = v is int ? v : v is num ? v.toInt() : int.tryParse(v.toString());
  if (n == null || n <= 0) return null;
  return n;
}

/// Normalizes `images` / `image` / `image_url` from product JSON.
List<String> parseProductImageUrls(Map<String, dynamic> json) {
  final out = <String>[];
  void addOne(String? s) {
    final t = s?.trim() ?? '';
    if (t.isEmpty) return;
    out.add(t);
  }

  void fromMap(Map<dynamic, dynamic> m) {
    for (final k in ['url', 'image', 'path', 'image_url', 'src', 'full_url']) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        addOne(v.toString());
        return;
      }
    }
  }

  dynamic raw = json['images'];
  if (raw == null) raw = json['image'];
  if (raw == null) raw = json['image_url'];

  if (raw == null) return out;

  if (raw is String) {
    final s = raw.trim();
    if (s.isEmpty) return out;
    if (s.startsWith('[') || s.startsWith('{')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) {
          for (final e in decoded) {
            if (e is String) {
              addOne(e);
            } else if (e is Map) {
              fromMap(e);
            }
          }
          return out;
        }
        if (decoded is Map) {
          fromMap(decoded);
          return out;
        }
      } catch (_) {}
    }
    addOne(s);
    return out;
  }

  if (raw is List) {
    for (final e in raw) {
      if (e is String) {
        addOne(e);
      } else if (e is Map) {
        fromMap(e);
      }
    }
    return out;
  }

  if (raw is Map) {
    fromMap(raw);
    return out;
  }

  addOne(raw.toString());
  return out;
}

List<ProductReview> _parseProductReviews(Map<String, dynamic> json) {
  final raw = json['reviews'];
  if (raw is! List) return [];
  final out = <ProductReview>[];
  for (final e in raw) {
    if (e is Map<String, dynamic>) {
      out.add(ProductReview.fromJson(e));
    }
  }
  return out;
}

List<StoreProductAttributeValue> _parseAttributeValues(Map<String, dynamic> json) {
  final raw = json['attribute_values'];
  if (raw is! List) return [];
  final out = <StoreProductAttributeValue>[];
  for (final e in raw) {
    if (e is Map<String, dynamic>) {
      out.add(StoreProductAttributeValue.fromJson(e));
    }
  }
  return out;
}

/// Store product — list/detail/featured/cart nested `product` shape.
class StoreProduct {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? imagePath;
  final double rating;
  final String? price;
  final String? detailDescription;
  final List<String>? thumbnailPaths;
  final bool isNetworkImage;
  final int? variantId;

  final int? stock;
  final bool isFeatured;
  final String? categoryId;
  final String? categoryTitle;
  final List<ProductReview> reviews;
  final List<StoreProductAttributeValue> attributeValues;

  /// Marketplace seller from API `user_id` (null for platform-only / unparsed rows).
  final int? sellerUserId;

  StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imagePath,
    this.rating = 0,
    this.price,
    this.detailDescription,
    this.thumbnailPaths,
    this.isNetworkImage = false,
    this.variantId,
    this.stock,
    this.isFeatured = false,
    this.categoryId,
    this.categoryTitle,
    this.reviews = const [],
    this.attributeValues = const [],
    this.sellerUserId,
  });

  /// Groups [attributeValues] by attribute name for UI chips.
  Map<String, List<StoreProductAttributeValue>> get attributeValuesByGroup {
    final m = <String, List<StoreProductAttributeValue>>{};
    for (final v in attributeValues) {
      final key = (v.attributeName != null && v.attributeName!.trim().isNotEmpty)
          ? v.attributeName!.trim()
          : 'Options';
      (m[key] ??= []).add(v);
    }
    return m;
  }

  factory StoreProduct.fromProductForYouJson(Map<String, dynamic> json) {
    return StoreProduct._fromProductApiJson(json);
  }

  factory StoreProduct.fromProductDetailJson(Map<String, dynamic> json) {
    return StoreProduct._fromProductApiJson(json);
  }

  factory StoreProduct.fromCartLine(Map<String, dynamic> line) {
    final productJson = line['product'];
    if (productJson is! Map<String, dynamic>) {
      return StoreProduct(
        id: '',
        title: '',
        description: '',
        isNetworkImage: false,
      );
    }
    final base = StoreProduct._fromProductApiJson(productJson);
    int? variantId;
    if (line['variant_id'] != null) {
      variantId = int.tryParse(line['variant_id'].toString());
    }
    return StoreProduct(
      id: base.id,
      title: base.title,
      description: base.description,
      imageUrl: base.imageUrl,
      imagePath: base.imagePath,
      rating: base.rating,
      price: base.price,
      detailDescription: base.detailDescription,
      thumbnailPaths: base.thumbnailPaths,
      isNetworkImage: base.isNetworkImage,
      variantId: variantId,
      stock: base.stock,
      isFeatured: base.isFeatured,
      categoryId: base.categoryId,
      categoryTitle: base.categoryTitle,
      reviews: base.reviews,
      attributeValues: base.attributeValues,
      sellerUserId: base.sellerUserId,
    );
  }

  factory StoreProduct._fromProductApiJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final description = json['description']?.toString() ?? '';
    final priceRaw = storeProductPriceRaw(json['price']);
    final imageUrls = parseProductImageUrls(json);
    final primary = imageUrls.isNotEmpty ? imageUrls.first : null;
    final thumbs = imageUrls.length > 1 ? List<String>.from(imageUrls) : null;

    int? variantId;
    final variants = json['variants'];
    if (variants is List && variants.isNotEmpty) {
      final v0 = variants.first;
      if (v0 is Map<String, dynamic>) {
        variantId = int.tryParse(v0['id']?.toString() ?? '');
      }
    }

    final reviews = _parseProductReviews(json);
    double rating;
    if (reviews.isNotEmpty) {
      rating = storeProductAverageRating(reviews);
    } else {
      final ar = json['average_rating'] ?? json['rating_average'] ?? json['avg_rating'];
      rating = ar != null ? (double.tryParse(ar.toString()) ?? 0) : 0;
    }

    String? categoryIdStr = json['category_id']?.toString();
    String? categoryTitle;
    final cat = json['category'];
    if (cat is Map<String, dynamic>) {
      categoryTitle = cat['title']?.toString();
      if (categoryIdStr == null || categoryIdStr.isEmpty) {
        categoryIdStr = cat['id']?.toString();
      }
    }

    final stockVal = json['stock'];
    final stock = stockVal == null ? null : int.tryParse(stockVal.toString());

    final featured = json['is_featured'];
    final isFeatured = featured == 1 || featured == true;

    final attributeValues = _parseAttributeValues(json);

    int? sellerUserId = _parseOptionalPositiveInt(json['user_id']);
    final userObj = json['user'];
    if (sellerUserId == null && userObj is Map<String, dynamic>) {
      sellerUserId = _parseOptionalPositiveInt(userObj['id']);
    }

    return StoreProduct(
      id: id,
      title: name,
      description: description,
      imageUrl: primary,
      imagePath: null,
      rating: rating,
      price: storeProductFormatPriceForUi(priceRaw),
      detailDescription: description,
      thumbnailPaths: thumbs,
      isNetworkImage: primary != null,
      variantId: variantId,
      stock: stock,
      isFeatured: isFeatured,
      categoryId: categoryIdStr,
      categoryTitle: categoryTitle,
      reviews: reviews,
      attributeValues: attributeValues,
      sellerUserId: sellerUserId,
    );
  }

  List<String> get effectiveThumbnailSources {
    if (thumbnailPaths != null && thumbnailPaths!.isNotEmpty) return thumbnailPaths!;
    if (isNetworkImage && imageUrl != null && imageUrl!.isNotEmpty) return [imageUrl!];
    if (imagePath != null && imagePath!.isNotEmpty) return [imagePath!];
    return [];
  }

  /// Human-readable summary for cart line (hex-only values omit the code; use attribute name).
  String? summaryForSelectedAttributeValueIds(List<int> ids) {
    if (ids.isEmpty) return null;
    final parts = <String>[];
    for (final id in ids) {
      StoreProductAttributeValue? match;
      for (final v in attributeValues) {
        if (v.id == id) {
          match = v;
          break;
        }
      }
      if (match == null) continue;
      final name = match.attributeName?.trim();
      final val = match.value.trim();
      if (_isHexColorCode(val)) {
        if (name != null && name.isNotEmpty) {
          parts.add(name);
        }
      } else {
        parts.add(
          (name != null && name.isNotEmpty) ? '$name: $val' : val,
        );
      }
    }
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  static bool _isHexColorCode(String input) {
    var s = input.trim();
    if (!s.startsWith('#')) return false;
    s = s.substring(1);
    if (s.length == 3) {
      s = s.split('').map((c) => '$c$c').join();
    }
    if (s.length != 6 && s.length != 8) return false;
    return int.tryParse(s, radix: 16) != null;
  }
}
