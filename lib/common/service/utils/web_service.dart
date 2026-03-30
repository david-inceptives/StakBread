import 'package:stakBread/utilities/const_res.dart';

class WebService {
  static var user = _User();
  static var setting = _Setting();
  static var addPostStory = _AddPostStory();
  static var post = _Post();
  static var google = _Google();
  static var notification = _Notification();
  static var giftWallet = _GiftWallet();
  static var search = _Search();
  static var moderation = _Moderation();
  static var common = _Common();
  static var store = _Store();
  static var resume = _Resume();
}

class _Resume {
  String addResume = "${apiURL}resume/addResume";
}

class _Store {
  String productForYou = "${apiURL}productForYou";

  String productDetail(String productId) => "${apiURL}productDetail/$productId";

  /// GET `productByUserId/:id`
  String productByUserId(String userId) => "${apiURL}productByUserId/$userId";

  String get topSellingProducts => "${apiURL}products/topSelling";

  String productReviews(String productId) => "${apiURL}productReviews/$productId";

  String get addToCart => "${apiURL}addToCart";

  String get updateCart => "${apiURL}updateCart";

  String get fetchCart => "${apiURL}fetchCart";

  String get deleteFromCart => "${apiURL}deleteFromCart";

  String get applyCoupon => "${apiURL}applyCoupon";

  String get featureProducts => "${apiURL}featureProducts";

  String get productCategories => "${apiURL}productCategories";

  String get productAttributes => "${apiURL}productAttributes";

  String productsByCategory(String categoryId) => "${apiURL}productsByCategory/$categoryId";

  /// POST `form-data`: name, category_id, price, stock, description, is_featured, `images[]`, `attribute_value_ids[]`.
  String get addProduct => "${apiURL}addProduct";

  /// POST `multipart/form-data`: product_id + same fields as [addProduct].
  String get updateProduct => "${apiURL}updateProduct";

  /// POST `form-data`: product_id
  String get deleteProduct => "${apiURL}deleteProduct";
}

class _Common {
  String ipApi = "http://ip-api.com/json/";
}

class _Moderation {
  String moderatorDeletePost = "${apiURL}moderator/moderator_deletePost";
  String moderatorUnFreezeUser = "${apiURL}moderator/moderator_unFreezeUser";
  String moderatorFreezeUser = "${apiURL}moderator/moderator_freezeUser";
  String moderatorDeleteStory = "${apiURL}moderator/moderator_deleteStory";
}

class _Notification {
  String fetchAdminNotifications = "${apiURL}misc/fetchAdminNotifications";
  String fetchActivityNotifications = "${apiURL}misc/fetchActivityNotifications";
  String pushNotificationToSingleUser = "${apiURL}misc/pushNotificationToSingleUser";
}

class _GiftWallet {
  String sendGift = "${apiURL}misc/sendGift";
  String fetchMyWithdrawalRequest = "${apiURL}misc/fetchMyWithdrawalRequest";
  String submitWithdrawalRequest = "${apiURL}misc/submitWithdrawalRequest";
  String buyCoins = "${apiURL}misc/buyCoins";
}

class _User {
  String loginInUser = "${apiURL}user/logInUser";
  String logInFakeUser = "${apiURL}user/logInFakeUser";
  String deleteMyAccount = "${apiURL}user/deleteMyAccount";
  String logOutUser = "${apiURL}user/logOutUser";
  String fetchUserDetails = "${apiURL}user/fetchUserDetails";
  String updateUserDetails = "${apiURL}user/updateUserDetails";
  String checkUsernameAvailability = "${apiURL}user/checkUsernameAvailability";
  String addUserLink = "${apiURL}user/addUserLink";
  String editeUserLink = "${apiURL}user/editeUserLink";
  String deleteUserLink = "${apiURL}user/deleteUserLink";
  String searchUsers = "${apiURL}user/searchUsers";
  String fetchMyFollowers = "${apiURL}user/fetchMyFollowers";
  String fetchUserFollowers = "${apiURL}user/fetchUserFollowers";
  String fetchUserFollowings = "${apiURL}user/fetchUserFollowings";
  String fetchMyFollowings = "${apiURL}user/fetchMyFollowings";
  String followUser = "${apiURL}user/followUser";
  String unFollowUser = "${apiURL}user/unFollowUser";
  String blockUser = "${apiURL}user/blockUser";
  String unBlockUser = "${apiURL}user/unBlockUser";
  String reportUser = "${apiURL}misc/reportUser";
  String fetchMyBlockedUsers = "${apiURL}user/fetchMyBlockedUsers";
  String updateLastUsedAt = "${apiURL}user/updateLastUsedAt";
  String fetchTrendingCreators = "${apiURL}user/fetchTrendingCreators";
}

class _AddPostStory {
  String addPostFeedText = "${apiURL}post/addPost_Feed_Text";
  String searchHashtags = "${apiURL}post/searchHashtags";
  String addPostFeedImage = "${apiURL}post/addPost_Feed_Image";
  String addPostFeedVideo = "${apiURL}post/addPost_Feed_Video";
  String addPostReel = "${apiURL}post/addPost_Reel";
}

class _Post {
  String fetchPostsDiscover = "${apiURL}post/fetchPostsDiscover";
  String fetchPostById = "${apiURL}post/fetchPostById";
  String fetchPostsByLocation = "${apiURL}post/fetchPostsByLocation";
  String fetchPostsNearBy = "${apiURL}post/fetchPostsNearBy";
  String fetchPostsFollowing = "${apiURL}post/fetchPostsFollowing";
  String fetchReelPostsByMusic = "${apiURL}post/fetchReelPostsByMusic";
  String fetchUserPosts = "${apiURL}post/fetchUserPosts";
  String fetchPostsByHashtag = "${apiURL}post/fetchPostsByHashtag";
  String fetchSavedPosts = "${apiURL}post/fetchSavedPosts";
  String deletePost = "${apiURL}post/deletePost";
  String increaseShareCount = "${apiURL}post/increaseShareCount";
  String increaseViewsCount = "${apiURL}post/increaseViewsCount";
  String pinPost = "${apiURL}post/pinPost";
  String unpinPost = "${apiURL}post/unpinPost";
  String likePost = "${apiURL}post/likePost";
  String disLikePost = "${apiURL}post/disLikePost";
  String savePost = "${apiURL}post/savePost";
  String unSavePost = "${apiURL}post/unSavePost";
  String reportPost = "${apiURL}misc/reportPost";
  String addPostComment = "${apiURL}post/addPostComment";
  String likeComment = "${apiURL}post/likeComment";
  String fetchPostComments = "${apiURL}post/fetchPostComments";
  String fetchPostCommentReplies = "${apiURL}post/fetchPostCommentReplies";
  String deleteComment = "${apiURL}post/deleteComment";
  String deleteCommentReply = "${apiURL}post/deleteCommentReply";
  String pinComment = "${apiURL}post/pinComment";
  String unPinComment = "${apiURL}post/unPinComment";
  String disLikeComment = "${apiURL}post/disLikeComment";
  String replyToComment = "${apiURL}post/replyToComment";
  String fetchMusicExplore = "${apiURL}post/fetchMusicExplore";
  String fetchMusicByCategories = "${apiURL}post/fetchMusicByCategories";
  String fetchSavedMusics = "${apiURL}post/fetchSavedMusics";
  String serchMusic = "${apiURL}post/serchMusic";
  String createStory = "${apiURL}post/createStory";
  String viewStory = "${apiURL}post/viewStory";
  String deleteStory = "${apiURL}post/deleteStory";
  String addUserMusic = "${apiURL}post/addUserMusic";
  String fetchStory = "${apiURL}post/fetchStory";
  String fetchStoryByID = "${apiURL}post/fetchStoryByID";
  String fetchExplorePageData = "${apiURL}post/fetchExplorePageData";
  String fetchMostViewedReels = "${apiURL}post/fetchMostViewedReels";
}

class _Setting {
  String fetchSettings = "${apiURL}settings/fetchSettings";
  String uploadFileGivePath = "${apiURL}settings/uploadFileGivePath";
  String deleteFile = "${apiURL}settings/deleteFile";
}

class _Google {
  String get searchTextByPlace {
    return "https://places.googleapis.com/v1/places:searchText?fields=*";
  }

  String searchNearByPlace(double lat, double lon) {
    return 'https://places.googleapis.com/v1/places:searchNearby?fields=*';
  }
}

class _Search {
  String searchPosts = "${apiURL}post/searchPosts";
}
