import 'package:stakBread/model/store/store_product_model.dart';

/// Row from GET `shopBanners` (`data[]`).
///
/// API example: `product_id`, nested `product`, `image`, `title`, `desc`, `link`, `status`.
class ShopBanner {
  const ShopBanner({
    required this.id,
    this.productId,
    this.linkedProduct,
    this.imageUrl,
    required this.title,
    required this.description,
    this.link,
    this.active = true,
  });

  final int id;
  /// Banner `product_id` (may be set without nested `product`).
  final int? productId;
  /// Nested `product` object from API — used for Buy now → product detail screen.
  final StoreProduct? linkedProduct;
  final String? imageUrl;
  final String title;
  final String description;
  final String? link;
  final bool active;

  bool get hasExternalLink {
    final l = link?.trim();
    return l != null && l.isNotEmpty && l != 'null';
  }

  /// True when we can open product detail (nested product parsed with id).
  bool get hasLinkedProduct =>
      linkedProduct != null && linkedProduct!.id.trim().isNotEmpty;

  bool get showBuyNowButton => hasLinkedProduct || hasExternalLink;

  factory ShopBanner.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final active = status == null ||
        status == 1 ||
        status == true ||
        status == '1';
    final imgRaw = json['image']?.toString().trim();
    final pid = int.tryParse(json['product_id']?.toString() ?? '');
    StoreProduct? nested;
    final p = json['product'];
    if (p is Map<String, dynamic>) {
      nested = StoreProduct.fromProductForYouJson(p);
    }
    return ShopBanner(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      productId: pid,
      linkedProduct: nested,
      imageUrl: (imgRaw != null && imgRaw.isNotEmpty) ? imgRaw : null,
      title: json['title']?.toString() ?? '',
      description: json['desc']?.toString() ?? '',
      link: () {
        final l = json['link']?.toString().trim();
        if (l == null || l.isEmpty || l == 'null') return null;
        return l;
      }(),
      active: active,
    );
  }
}
