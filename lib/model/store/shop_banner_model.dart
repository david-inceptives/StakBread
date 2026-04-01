/// Row from GET `shopBanners` (`data[]`).
class ShopBanner {
  const ShopBanner({
    required this.id,
    this.imageUrl,
    required this.title,
    required this.description,
    this.link,
    this.active = true,
  });

  final int id;
  final String? imageUrl;
  final String title;
  final String description;
  final String? link;
  final bool active;

  factory ShopBanner.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final active = status == null ||
        status == 1 ||
        status == true ||
        status == '1';
    final imgRaw = json['image']?.toString().trim();
    return ShopBanner(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
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
