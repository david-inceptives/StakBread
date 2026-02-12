import 'package:stakBread/utilities/const_res.dart';

/// Returns dummy/mock response for API calls when [useDummyApi] is true.
/// No network calls are made; all data is local.
class DummyApi {
  DummyApi._();

  // Valid public URLs for dummy video/thumbnail/audio (so playback works)
  static const String _videoUrl1 =
      'https://download.samplelib.com/mp4/sample-5s.mp4';
  static const String _videoUrl2 =
      'https://download.samplelib.com/mp4/sample-10s.mp4';
  static const String _videoUrl3 =
      'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4';
  static const String _thumbUrl1 = 'https://picsum.photos/seed/reel1/400/700';
  static const String _thumbUrl2 = 'https://picsum.photos/seed/reel2/400/700';
  static const String _thumbUrl3 = 'https://picsum.photos/seed/reel3/400/700';
  /// Profile image for logged-in user (id 1).
  static const String _loggedInUserProfileUrl = 'https://picsum.photos/seed/demouser/400/400';
  static const String _audioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  /// Logged-in user id (must match login dummy data).
  static const int _loggedInUserId = 1;

  /// Dummy Privacy Policy HTML (shown when useDummyApi is true).
  static const String _dummyPrivacyPolicyHtml = '''
<h2>Privacy Policy (Dummy)</h2>
<p>This is a placeholder privacy policy for demo purposes.</p>
<h3>1. Information We Collect</h3>
<p>We may collect your name, email, profile photo, and content you share on the app.</p>
<h3>2. How We Use Your Data</h3>
<p>Your data is used to provide and improve our services, personalize your experience, and communicate with you.</p>
<h3>3. Data Security</h3>
<p>We use industry-standard measures to protect your personal information.</p>
<h3>4. Your Rights</h3>
<p>You can request access, correction, or deletion of your data at any time.</p>
<h3>5. Contact</h3>
<p>For privacy questions, contact: privacy@example.com</p>
''';

  /// Dummy Terms of Use HTML (shown when useDummyApi is true).
  static const String _dummyTermsOfUseHtml = '''
<h2>Terms of Use (Dummy)</h2>
<p>Welcome. These are placeholder terms for demo purposes.</p>
<h3>1. Acceptance</h3>
<p>By using this app you agree to these terms.</p>
<h3>2. Use of Service</h3>
<p>You must use the service lawfully and not harass others or post illegal content.</p>
<h3>3. Intellectual Property</h3>
<p>You retain rights to your content; you grant us a license to display and distribute it within the service.</p>
<h3>4. Termination</h3>
<p>We may suspend or terminate your account if you breach these terms.</p>
<h3>5. Contact</h3>
<p>For terms-related queries: support@example.com</p>
''';

  /// Multiple dummy users. Id 1 = current user, 2–5 = others (for feed/followers/profile).
  static Map<String, dynamic> _dummyUserById(int id) {
    const users = {
      1: {'id': 1, 'identity': 'demo@demo.com', 'fullname': 'Demo User', 'username': 'demouser', 'user_email': 'demo@demo.com', 'profile_photo': _loggedInUserProfileUrl, 'bio': 'Dummy bio', 'follower_count': 12, 'following_count': 8},
      2: {'id': 2, 'identity': 'alex@test.com', 'fullname': 'Alex Rivera', 'username': 'alex_r', 'user_email': 'alex@test.com', 'profile_photo': _thumbUrl1, 'bio': 'Creator', 'follower_count': 250, 'following_count': 100},
      3: {'id': 3, 'identity': 'sam@test.com', 'fullname': 'Sam Wilson', 'username': 'samwilson', 'user_email': 'sam@test.com', 'profile_photo': _thumbUrl2, 'bio': 'Travel & reels', 'follower_count': 89, 'following_count': 45},
      4: {'id': 4, 'identity': 'jordan@test.com', 'fullname': 'Jordan Lee', 'username': 'jordan_lee', 'user_email': 'jordan@test.com', 'profile_photo': _thumbUrl3, 'bio': 'Music lover', 'follower_count': 120, 'following_count': 200},
      5: {'id': 5, 'identity': 'casey@test.com', 'fullname': 'Casey Kim', 'username': 'caseykim', 'user_email': 'casey@test.com', 'profile_photo': _thumbUrl1, 'bio': 'Daily vlogs', 'follower_count': 56, 'following_count': 120},
    };
    final u = Map<String, dynamic>.from(users[id] ?? users[1]!);
    u['is_verify'] = id == 2 ? 1 : 0;
    u['is_following'] = id == _loggedInUserId ? false : (id % 2 == 0);
    u['follow_status'] = 0;
    u['is_block'] = false;
    u['new_register'] = false;
    u['token'] = null;
    u['links'] = [];
    u['stories'] = [];
    u['following_ids'] = [];
    u['receive_message'] = 1; // so Message button shows on other profile
    return u;
  }

  static Map<String, dynamic> _dummyUserMini() => _dummyUserById(1);

  /// Single dummy post. [postType] 1=reel, 2=image, 3=video, 4=text.
  /// [userId] 1–5 so feed shows multiple users; [videoIndex] for different URLs.
  static Map<String, dynamic> _dummyPost({
    int postType = 1,
    int videoIndex = 0,
    int userId = 1,
  }) {
    final videos = [_videoUrl1, _videoUrl2, _videoUrl3];
    final thumbs = [_thumbUrl1, _thumbUrl2, _thumbUrl3];
    final i = videoIndex.clamp(0, 2);
    final uid = userId.clamp(1, 5);
    return {
      'id': 100 + uid + videoIndex * 10,
      'post_save_id': null,
      'post_type': postType,
      'user_id': uid,
      'sound_id': null,
      'metadata': null,
      'description': 'Dummy post by user $uid #demo #stakbread',
      'hashtags': '#demo #stakbread',
      'video': videos[i],
      'thumbnail': thumbs[i],
      'views': 100 + uid * 10,
      'likes': 25,
      'comments': 5,
      'saves': 10,
      'shares': 2,
      'mentioned_user_ids': null,
      'is_trending': 0,
      'can_comment': 1,
      'place_title': null,
      'place_lat': null,
      'place_lon': null,
      'state': null,
      'country': null,
      'is_pinned': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_liked': false,
      'is_saved': false,
      'mentioned_users': null,
      'images': null,
      'music': null,
      'user': _dummyUserById(uid),
    };
  }

  /// Feed/reels: posts from users 1,2,3,4,5 so tapping avatar opens correct profile.
  static List<Map<String, dynamic>> _dummyPostList({int postType = 1, int? forUserId}) {
    if (forUserId != null) {
      final uid = forUserId.clamp(1, 5);
      return [
        _dummyPost(postType: postType, videoIndex: 0, userId: uid),
        _dummyPost(postType: postType, videoIndex: 1, userId: uid)..['id'] = (100 + uid + 10),
      ];
    }
    return [
      _dummyPost(postType: postType, videoIndex: 0, userId: 1),
      _dummyPost(postType: postType, videoIndex: 1, userId: 2)..['id'] = 112,
      _dummyPost(postType: postType, videoIndex: 2, userId: 3)..['id'] = 123,
      _dummyPost(postType: postType, videoIndex: 0, userId: 4)..['id'] = 114,
      _dummyPost(postType: postType, videoIndex: 1, userId: 5)..['id'] = 125,
    ];
  }

  /// Dummy story for fetchStory (users with stories) - valid video URL
  static Map<String, dynamic> _dummyStory() => {
        'id': 1,
        'user_id': 1,
        'type': 1,
        'content': _videoUrl1,
        'thumbnail': _thumbUrl1,
        'sound_id': null,
        'duration': null,
        'view_by_user_ids': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'user': null,
        'music': null,
      };

  static Map<String, dynamic> _dummyUserWithStories() => {
        ..._dummyUserMini(),
        'stories': [_dummyStory()],
      };

  static Map<String, dynamic> _dummyMusic() => {
        'id': 1,
        'category_id': 1,
        'post_count': 5,
        'added_by': 1,
        'user_id': 1,
        'title': 'Dummy Sound',
        'sound': _audioUrl,
        'duration': '0:30',
        'artist': 'Demo Artist',
        'image': _thumbUrl1,
        'is_deleted': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'user': null,
      };

  static Map<String, dynamic> _dummyHashtag() => {
        'id': 1,
        'hashtag': 'demo',
        'post_count': 10,
        'on_explore': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  static Map<String, dynamic> _dummyAdminNotification() => {
        'id': 1,
        'title': 'Welcome',
        'description': 'This is a dummy notification.',
        'image': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  static Map<String, dynamic> _dummyActivityNotification() => {
        'id': 1,
        'from_user_id': 2,
        'to_user_id': 1,
        'type': 1,
        'data_id': 101,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'data': null,
        'from_user': _dummyUserById(2),
      };

  static int? _paramUserId(Map<String, dynamic>? param) {
    if (param == null) return null;
    final v = param['user_id'];
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static int? _paramLastItemId(Map<String, dynamic>? param) {
    if (param == null) return null;
    final v = param['last_item_id'];
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static Map<String, dynamic>? _getDummyMap(String url, [Map<String, dynamic>? param]) {
    if (!useDummyApi) return null;

    // Settings - app needs itemBaseUrl and basic settings
    if (url.contains('fetchSettings')) {
      return {
        'status': true,
        'message': 'Success',
        'data': {
          'id': 1,
          'itemBaseUrl': baseURL,
          'is_content_moderation': 0,
          'app_name': 'StakBread',
          'currency': 'USD',
          'coin_value': 1.0,
          'min_redeem_coins': 100,
          'is_compress': 1,
          'is_deepAR': 0,
          'is_withdrawal_on': 0,
          'max_upload_daily': 10,
          'max_story_daily': 10,
          'max_comment_daily': 50,
          'max_images_per_post': 10,
          'max_user_links': 5,
          'place_api_access_token': null,
          'deepar_android_key': null,
          'deepar_iOS_key': null,
          'sight_engine_api_user': null,
          'sight_engine_api_secret': null,
          'sight_engine_image_workflow_id': null,
          'sight_engine_video_workflow_id': null,
          'giphy_key': null,
          'languages': [],
          'onBoarding': [],
          'coinPackages': [],
          'redeemGateways': [],
          'gifts': [],
          'musicCategories': [],
          'userLevels': [],
          'dummyLives': [],
          'reportReasons': [],
          'deepARFilters': [],
          'privacy_policy': _dummyPrivacyPolicyHtml,
          'terms_of_uses': _dummyTermsOfUseHtml,
        },
      };
    }

    // Auth: logout & delete account – success, no real API
    if (url.contains('logOutUser') || url.contains('deleteMyAccount')) {
      return {'status': true, 'message': 'Success', 'data': null};
    }

    // Login / auth - return user with token so session works
    if (url.contains('logInUser') || url.contains('logInFakeUser')) {
      return {
        'status': true,
        'message': 'Success',
        'data': {
          'id': 1,
          'identity': 'demo@demo.com',
          'fullname': 'Demo User',
          'username': 'demouser',
          'user_email': 'demo@demo.com',
          'profile_photo': _loggedInUserProfileUrl,
          'bio': null,
          'follower_count': 0,
          'following_count': 0,
          'is_verify': 0,
          'is_following': false,
          'follow_status': 0,
          'is_block': false,
          'new_register': false,
          'token': {
            'user_id': 1,
            'auth_token': 'dummy_auth_token_${DateTime.now().millisecondsSinceEpoch}',
          },
          'links': [],
          'stories': [],
          'following_ids': [],
        },
      };
    }

    // Fetch user details – by user_id (tap profile: id 1 = my profile, 2–5 = other profile)
    if (url.contains('fetchUserDetails')) {
      final userId = _paramUserId(param) ?? _loggedInUserId;
      final data = _dummyUserById(userId);
      if (userId == _loggedInUserId) {
        data['token'] = {'user_id': 1, 'auth_token': 'dummy_auth_token'};
      }
      return {'status': true, 'message': 'Success', 'data': data};
    }

    // fetchUserPosts returns UserPostModel – posts for requested user_id (my profile vs other)
    if (url.contains('fetchUserPosts')) {
      final userId = _paramUserId(param) ?? _loggedInUserId;
      return {
        'status': true,
        'message': 'Success',
        'data': {'posts': _dummyPostList(forUserId: userId), 'pinnedPostList': []},
      };
    }

    // Reels feed - post_type 1. With last_item_id (pagination) return empty to avoid duplicates.
    if (url.contains('fetchPostsDiscover') || url.contains('fetchReelPostsByMusic')) {
      if (_paramLastItemId(param) != null) {
        return {'status': true, 'message': 'Success', 'data': <Map<String, dynamic>>[]};
      }
      return {
        'status': true,
        'message': 'Success',
        'data': _dummyPostList(postType: 1),
      };
    }

    // fetchPostsByHashtag returns HashtagPostModel with data: { posts, hashtag }
    if (url.contains('fetchPostsByHashtag')) {
      return {
        'status': true,
        'message': 'Success',
        'data': {'posts': _dummyPostList(), 'hashtag': _dummyHashtag()},
      };
    }

    // Other post list endpoints - mixed dummy posts. With last_item_id return empty to avoid duplicates.
    if (url.contains('fetchPostsFollowing') ||
        url.contains('fetchPostsByLocation') ||
        url.contains('fetchPostsNearBy') ||
        url.contains('fetchSavedPosts') ||
        url.contains('searchPosts')) {
      if (_paramLastItemId(param) != null) {
        return {'status': true, 'message': 'Success', 'data': <Map<String, dynamic>>[]};
      }
      return {
        'status': true,
        'message': 'Success',
        'data': _dummyPostList(),
      };
    }

    // Fetch post by id - dummy post so detail screen shows content
    if (url.contains('fetchPostById')) {
      return {
        'status': true,
        'message': 'Success',
        'data': {
          'post': _dummyPost(),
          'comment': null,
          'reply': null,
        },
      };
    }

    // Explore page - hashtags + highPostHashtags
    if (url.contains('fetchExplorePageData')) {
      final hashtag = _dummyHashtag();
      final highPost = {
        'id': 1,
        'hashtag': 'trending',
        'post_count': 50,
        'on_explore': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'postList': _dummyPostList(postType: 1),
      };
      return {
        'status': true,
        'message': 'Success',
        'data': {
          'hashtags': [hashtag, {...hashtag, 'id': 2, 'hashtag': 'stakbread'}],
          'highPostHashtags': [highPost],
        },
      };
    }

    // searchUsers – list of User (id, fullname, username, profile_photo, etc.)
    if (url.contains('searchUsers')) {
      final list = [1, 2, 3, 4, 5].map((id) => _dummyUserById(id)).toList();
      return {'status': true, 'message': 'Success', 'data': list};
    }

    // Followers – FollowerModel expects data: List<{ from_user: User }>
    if (url.contains('fetchMyFollowers') || url.contains('fetchUserFollowers')) {
      final list = [2, 3, 4, 5].map((id) => {
        'id': id,
        'from_user_id': id,
        'to_user_id': _loggedInUserId,
        'status': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'from_user': _dummyUserById(id),
      }).toList();
      return {'status': true, 'message': 'Success', 'data': list};
    }

    // Following – FollowingModel expects data: List<{ to_user: User }>
    if (url.contains('fetchUserFollowings') || url.contains('fetchMyFollowings')) {
      final list = [2, 3, 4, 5].map((id) => {
        'id': id,
        'from_user_id': _loggedInUserId,
        'to_user_id': id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'to_user': _dummyUserById(id),
      }).toList();
      return {'status': true, 'message': 'Success', 'data': list};
    }

    // Blocked users – BlockUserModel expects data: List<{ to_user: User }>
    if (url.contains('fetchMyBlockedUsers')) {
      final list = [2, 3].map((id) => {
        'id': id,
        'from_user_id': _loggedInUserId,
        'to_user_id': id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'to_user': _dummyUserById(id),
      }).toList();
      return {'status': true, 'message': 'Success', 'data': list};
    }

    // Notifications
    if (url.contains('fetchAdminNotifications')) {
      return {
        'status': true,
        'message': 'Success',
        'data': [_dummyAdminNotification()],
      };
    }
    if (url.contains('fetchActivityNotifications')) {
      return {
        'status': true,
        'message': 'Success',
        'data': [_dummyActivityNotification()],
      };
    }

    // Comments - FetchCommentModel expects data: { comments, pinnedComments }
    if (url.contains('fetchPostComments')) {
      final dummyComment = {
        'id': 1,
        'comment_id': null,
        'post_id': 101,
        'user_id': 1,
        'comment': 'Dummy comment',
        'reply': null,
        'mentioned_user_ids': null,
        'likes': 2,
        'replies_count': 0,
        'is_pinned': 0,
        'type': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_liked': false,
        'mentionedUsers': null,
        'user': _dummyUserMini(),
      };
      return {
        'status': true,
        'message': 'Success',
        'data': {'comments': [dummyComment], 'pinnedComments': []},
      };
    }
    if (url.contains('fetchPostCommentReplies')) {
      return {'status': true, 'message': 'Success', 'data': []};
    }

    // Music
    if (url.contains('fetchMusicExplore') ||
        url.contains('fetchMusicByCategories') ||
        url.contains('fetchSavedMusics') ||
        url.contains('serchMusic')) {
      final m2 = Map<String, dynamic>.from(_dummyMusic())..['id'] = 2..['title'] = 'Another Sound';
      return {'status': true, 'message': 'Success', 'data': [_dummyMusic(), m2]};
    }

    // Story - fetchStory returns list of users with stories; fetchStoryByID returns single Story
    if (url.contains('fetchStoryByID')) {
      return {
        'status': true,
        'message': 'Success',
        'data': {..._dummyStory(), 'user': _dummyUserMini()},
      };
    }
    if (url.contains('fetchStory')) {
      return {
        'status': true,
        'message': 'Success',
        'data': [_dummyUserWithStories()],
      };
    }

    // Hashtag search
    if (url.contains('searchHashtags')) {
      return {
        'status': true,
        'message': 'Success',
        'data': [_dummyHashtag(), {..._dummyHashtag(), 'id': 2, 'hashtag': 'stakbread'}],
      };
    }

    // Withdrawal / gift
    if (url.contains('fetchMyWithdrawalRequest')) {
      return {'status': true, 'message': 'Success', 'data': []};
    }

    // Upload file (multipart) - return dummy path
    if (url.contains('uploadFileGivePath')) {
      return {
        'status': true,
        'message': 'Success',
        'data': '$baseURL/uploads/dummy_${DateTime.now().millisecondsSinceEpoch}.jpg',
      };
    }

    // Update user (multipart)
    if (url.contains('updateUserDetails')) {
      return _getDummyMap('logInUser');
    }

    // Create story (multipart)
    if (url.contains('createStory')) {
      return {'status': true, 'message': 'Success', 'data': null};
    }

    // Add user music (multipart) – return dummy Music so reel upload with audio works
    if (url.contains('addUserMusic')) {
      return {'status': true, 'message': 'Success', 'data': _dummyMusic()};
    }

    // Add post (text / image / video / reel) – return dummy Post so upload success flow works
    if (url.contains('addPost_Feed_Text')) {
      return {'status': true, 'message': 'Success', 'data': _dummyPost(postType: 4, videoIndex: 0)..['id'] = 999};
    }
    if (url.contains('addPost_Feed_Image')) {
      return {'status': true, 'message': 'Success', 'data': _dummyPost(postType: 2, videoIndex: 0)..['id'] = 999};
    }
    if (url.contains('addPost_Feed_Video')) {
      return {'status': true, 'message': 'Success', 'data': _dummyPost(postType: 3, videoIndex: 0)..['id'] = 999};
    }
    if (url.contains('addPost_Reel')) {
      return {'status': true, 'message': 'Success', 'data': _dummyPost(postType: 1, videoIndex: 0)..['id'] = 999};
    }

    // Add comment – return dummy comment so it appears in list
    if (url.contains('addPostComment')) {
      final id = DateTime.now().millisecondsSinceEpoch;
      return {
        'status': true,
        'message': 'Success',
        'data': _dummyCommentMap(id: id, commentId: null, comment: param?['comment'] ?? 'Dummy comment'),
      };
    }
    if (url.contains('replyToComment')) {
      final id = DateTime.now().millisecondsSinceEpoch;
      final parentId = param?['comment_id'];
      return {
        'status': true,
        'message': 'Success',
        'data': _dummyCommentMap(id: id, commentId: parentId, comment: param?['reply'] ?? 'Dummy reply'),
      };
    }

    // User links (add / edit / delete)
    if (url.contains('addUserLink') || url.contains('editeUserLink') || url.contains('deleteUserLink')) {
      return {'status': true, 'message': 'Success', 'data': []};
    }

    // Moderator
    if (url.contains('moderator_deletePost') ||
        url.contains('moderator_unFreezeUser') ||
        url.contains('moderatorFreezeUser') ||
        url.contains('moderatorDeleteStory')) {
      return {'status': true, 'message': 'Success', 'data': null};
    }

    // Default - success response for status-only endpoints
    return {'status': true, 'message': 'Success', 'data': null};
  }

  static Map<String, dynamic> _dummyCommentMap({
    required int id,
    int? commentId,
    String comment = 'Dummy comment',
  }) {
    return {
      'id': id,
      'comment_id': commentId,
      'post_id': 101,
      'user_id': _loggedInUserId,
      'comment': comment,
      'reply': null,
      'mentioned_user_ids': null,
      'likes': 0,
      'replies_count': 0,
      'is_pinned': 0,
      'type': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_liked': false,
      'mentionedUsers': null,
      'user': _dummyUserById(_loggedInUserId),
    };
  }

  static Future<T?> getResponse<T>(
    String url,
    T Function(Map<String, dynamic>)? fromJson, [
    Map<String, dynamic>? param,
  ]) async {
    final map = _getDummyMap(url, param);
    if (map == null) return null;
    if (fromJson != null) {
      return fromJson(map);
    }
    return map as T;
  }

  /// Fallback when URL is not in dummy map (should not happen when useDummyApi is true).
  static Map<String, dynamic> getFallback() =>
      {'status': true, 'message': 'Success', 'data': null};
}
