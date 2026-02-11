import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/service/api/post_service.dart';
import 'package:stakBread/common/service/api/user_service.dart';
import 'package:stakBread/common/service/navigation/navigate_with_controller.dart';
import 'package:stakBread/screen/explore_screen/trending_creators_screen.dart';
import 'package:stakBread/screen/reels_screen/reels_screen.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';
import 'package:stakBread/utilities/asset_res.dart';

class ExploreReelItem {
  final String id;
  final String? imagePath;
  final String viewCount;

  ExploreReelItem({required this.id, this.imagePath, required this.viewCount});
}

class ExploreCreatorItem {
  final String id;
  final String name;
  final String profession;
  final String? avatarPath;
  final bool verified;

  ExploreCreatorItem({
    required this.id,
    required this.name,
    required this.profession,
    this.avatarPath,
    this.verified = true,
  });
}

class ExploreTabController extends BaseController {
  RxInt selectedReelCategoryIndex = 1.obs; // 0=Music, 1=Food, 2=Fashion, 3=Games, 4=Comedy

  final List<ExploreReelItem> reelItems = [
    ExploreReelItem(id: '1', imagePath: AssetRes.reel1, viewCount: '12M'),
    ExploreReelItem(id: '2', imagePath: AssetRes.reel2, viewCount: '9M'),
    ExploreReelItem(id: '3', imagePath: AssetRes.reel3, viewCount: '9.3M'),
    ExploreReelItem(id: '4', imagePath: AssetRes.reel4, viewCount: '5M'),
    ExploreReelItem(id: '5', imagePath: AssetRes.reel1, viewCount: '1.5M'),
  ];

  final List<ExploreCreatorItem> creatorItems = [
    ExploreCreatorItem(name: 'Cara Lee', profession: 'Digital Artist', id: 'c1', avatarPath: AssetRes.creator1),
    ExploreCreatorItem(name: 'Lisa Su', profession: 'Digital Artist', id: 'c2', avatarPath: AssetRes.creator2),
    ExploreCreatorItem(name: 'Mike E', profession: 'Interior Designer', id: 'c3'),
  ];

  List<dynamic> get topSellingProducts {
    if (Get.isRegistered<StoreScreenController>()) {
      return Get.find<StoreScreenController>().topSelling;
    }
    return [];
  }

  /// Opens Trending Creators full screen (View All).
  void onTrendingCreatorsViewAll() {
    Get.to(() => TrendingCreatorsScreen(
          creators: creatorItems,
          onCreatorTap: onCreatorTap,
        ));
  }

  /// Fetches trending reels and opens ReelsScreen (View All).
  Future<void> onTrendingReelsViewAll() async {
    showLoader();
    try {
      final list = await PostService.instance.fetchPostsDiscover(type: PostType.reels);
      stopLoader();
      if (list.isNotEmpty) {
        Get.to(() => ReelsScreen(reels: list.obs, position: 0));
      }
    } catch (_) {
      stopLoader();
    }
  }

  /// Tap on a reel thumbnail: fetch post and open ReelsScreen.
  Future<void> onReelTap(ExploreReelItem item) async {
    final postId = int.tryParse(item.id);
    if (postId == null) return;
    showLoader();
    try {
      final model = await PostService.instance.fetchPostById(postId: postId);
      stopLoader();
      final post = model.data?.post;
      if (post != null) {
        Get.to(() => ReelsScreen(reels: [post].obs, position: 0));
      }
    } catch (_) {
      stopLoader();
    }
  }

  /// Map creator id to dummy user id (c1->2, c2->3, c3->4).
  static int? _creatorIdToUserId(String id) {
    switch (id) {
      case 'c1': return 2;
      case 'c2': return 3;
      case 'c3': return 4;
      default: return int.tryParse(id);
    }
  }

  /// Tap on creator: fetch user and open ProfileScreen.
  Future<void> onCreatorTap(ExploreCreatorItem creator) async {
    final userId = _creatorIdToUserId(creator.id);
    if (userId == null) return;
    showLoader();
    try {
      final user = await UserService.instance.fetchUserDetails(userId: userId);
      stopLoader();
      if (user != null) {
        await NavigationService.shared.openProfileScreen(user);
      }
    } catch (_) {
      stopLoader();
    }
  }
}
