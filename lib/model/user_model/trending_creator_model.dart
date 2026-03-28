/// One entry from trending creators API (`data` array).
class TrendingCreatorModel {
  TrendingCreatorModel({
    required this.id,
    required this.username,
    required this.fullname,
    this.bio,
    this.profilePhotoPath,
    required this.isVerify,
    required this.followerCount,
  });

  final String id;
  final String username;
  final String fullname;
  final String? bio;
  /// Relative path or full URL; null if absent.
  final String? profilePhotoPath;
  final bool isVerify;
  final int followerCount;

  factory TrendingCreatorModel.fromJson(Map<String, dynamic> json) {
    final photo = json['profile_photo']?.toString();
    return TrendingCreatorModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      bio: json['bio']?.toString(),
      profilePhotoPath: (photo != null && photo.isNotEmpty) ? photo : null,
      isVerify: json['is_verify'] == 1 || json['is_verify'] == true,
      followerCount: int.tryParse(json['follower_count']?.toString() ?? '0') ?? 0,
    );
  }
}
