int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

String? _parseNullableString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

/// Resume payload nested under trending creator (`resume` may be null).
class TrendingCreatorResume {
  TrendingCreatorResume({
    this.id,
    this.userId,
    this.caption,
    this.pdfFile,
    this.videoFile,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String? caption;
  /// Full URL or relative path from API.
  final String? pdfFile;
  final String? videoFile;
  final String? createdAt;
  final String? updatedAt;

  factory TrendingCreatorResume.fromJson(Map<String, dynamic> json) {
    return TrendingCreatorResume(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      caption: _parseNullableString(json['caption']),
      pdfFile: _parseNullableString(json['pdf_file']),
      videoFile: _parseNullableString(json['video_file']),
      createdAt: _parseNullableString(json['created_at']),
      updatedAt: _parseNullableString(json['updated_at']),
    );
  }
}

/// One entry from trending creators API (`data` array).
class TrendingCreatorModel {
  TrendingCreatorModel({
    required this.id,
    required this.username,
    required this.fullname,
    this.bio,
    this.profilePhotoPath,
    this.isVerify = false,
    this.device,
    this.deviceToken,
    this.appLanguage,
    this.notifyPostLike,
    this.notifyPostComment,
    this.notifyFollow,
    this.notifyMention,
    this.notifyGiftReceived,
    this.notifyChat,
    this.coinCollectedLifetime,
    this.totalPostLikesCount,
    this.followingCount,
    this.followerCount,
    this.receiveMessage,
    this.isFollowing = false,
    this.resume,
  });

  final String id;
  final String username;
  final String fullname;
  final String? bio;
  /// Relative path or full URL; null if absent.
  final String? profilePhotoPath;
  final bool isVerify;
  final int? device;
  final String? deviceToken;
  final String? appLanguage;
  final int? notifyPostLike;
  final int? notifyPostComment;
  final int? notifyFollow;
  final int? notifyMention;
  final int? notifyGiftReceived;
  final int? notifyChat;
  final int? coinCollectedLifetime;
  final int? totalPostLikesCount;
  final int? followingCount;
  final int? followerCount;
  final int? receiveMessage;
  final bool isFollowing;
  final TrendingCreatorResume? resume;

  factory TrendingCreatorModel.fromJson(Map<String, dynamic> json) {
    final photo = json['profile_photo']?.toString();
    TrendingCreatorResume? resume;
    final rawResume = json['resume'];
    if (rawResume is Map<String, dynamic>) {
      resume = TrendingCreatorResume.fromJson(rawResume);
    }

    return TrendingCreatorModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      bio: _parseNullableString(json['bio']),
      profilePhotoPath: (photo != null && photo.isNotEmpty) ? photo : null,
      isVerify: json['is_verify'] == 1 || json['is_verify'] == true,
      device: _parseInt(json['device']),
      deviceToken: _parseNullableString(json['device_token']),
      appLanguage: _parseNullableString(json['app_language']),
      notifyPostLike: _parseInt(json['notify_post_like']),
      notifyPostComment: _parseInt(json['notify_post_comment']),
      notifyFollow: _parseInt(json['notify_follow']),
      notifyMention: _parseInt(json['notify_mention']),
      notifyGiftReceived: _parseInt(json['notify_gift_received']),
      notifyChat: _parseInt(json['notify_chat']),
      coinCollectedLifetime: _parseInt(json['coin_collected_lifetime']),
      totalPostLikesCount: _parseInt(json['total_post_likes_count']),
      followingCount: _parseInt(json['following_count']),
      followerCount: _parseInt(json['follower_count']),
      receiveMessage: _parseInt(json['receive_message']),
      isFollowing: json['is_following'] == true || json['is_following'] == 1,
      resume: resume,
    );
  }
}
