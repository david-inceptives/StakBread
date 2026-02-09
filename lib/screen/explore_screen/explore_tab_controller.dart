import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
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
}
