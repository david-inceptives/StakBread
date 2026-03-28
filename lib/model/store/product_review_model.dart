class ProductReviewUser {
  final String? fullname;
  final String? username;
  final String? profilePhoto;

  ProductReviewUser({
    this.fullname,
    this.username,
    this.profilePhoto,
  });

  factory ProductReviewUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ProductReviewUser();
    }
    return ProductReviewUser(
      fullname: json['fullname']?.toString(),
      username: json['username']?.toString(),
      profilePhoto: json['profile_photo']?.toString(),
    );
  }
}

class ProductReview {
  final int id;
  final int productId;
  final int rating;
  final String review;
  final String? createdAt;
  final String? updatedAt;
  final ProductReviewUser? user;

  ProductReview({
    required this.id,
    required this.productId,
    required this.rating,
    required this.review,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  String? get displayDateRaw {
    final c = createdAt;
    if (c != null && c.isNotEmpty && c != 'null') return c;
    final u = updatedAt;
    if (u != null && u.isNotEmpty && u != 'null') return u;
    return null;
  }

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      productId: int.tryParse(json['product_id']?.toString() ?? '') ?? 0,
      rating: int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      review: json['review']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      user: ProductReviewUser.fromJson(json['user'] as Map<String, dynamic>?),
    );
  }
}
