import 'package:stakBread/common/extensions/string_extension.dart';

/// Item from GET `productCategories` (`data` array).
class StoreProductCategory {
  const StoreProductCategory({
    required this.id,
    required this.title,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String? imageUrl;

  factory StoreProductCategory.fromJson(Map<String, dynamic> json) {
    final imageUrlRaw = json['image_url']?.toString().trim();
    final imageRel = json['image']?.toString().trim();
    String? url;
    if (imageUrlRaw != null && imageUrlRaw.isNotEmpty) {
      url = imageUrlRaw;
    } else if (imageRel != null && imageRel.isNotEmpty) {
      url = imageRel.startsWith('http') ? imageRel : imageRel.addBaseURL();
    }
    return StoreProductCategory(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: url,
    );
  }
}
