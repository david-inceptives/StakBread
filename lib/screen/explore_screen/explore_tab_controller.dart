import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/common/service/api/post_service.dart';
import 'package:stakBread/common/service/api/user_service.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/post_story/post_model.dart';
import 'package:stakBread/model/user_model/trending_creator_model.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';

class ExploreCreatorItem {
  final String id;
  final String name;
  final String profession;
  final String? avatarPath;
  final String? avatarUrl;
  final bool verified;

  ExploreCreatorItem({
    required this.id,
    required this.name,
    required this.profession,
    this.avatarPath,
    this.avatarUrl,
    this.verified = false,
  });
}

class ExploreTabController extends BaseController {
  static const int trendingCreatorsPreviewMax = 5;
  static const int mostViewedReelsPreviewMax = 5;

  List<Post> mostViewedReelsAll = [];
  bool isMostViewedReelsLoading = false;

  List<Post> get mostViewedReelsPreview {
    final n = mostViewedReelsAll.length;
    if (n <= mostViewedReelsPreviewMax) {
      return List<Post>.from(mostViewedReelsAll);
    }
    return mostViewedReelsAll.sublist(0, mostViewedReelsPreviewMax);
  }

  bool get showMostViewedReelsViewAll =>
      mostViewedReelsAll.length > mostViewedReelsPreviewMax;

  List<ExploreCreatorItem> trendingCreatorsAll = [];
  bool isTrendingCreatorsLoading = false;

  List<ExploreCreatorItem> get trendingCreatorsPreview {
    final n = trendingCreatorsAll.length;
    if (n <= trendingCreatorsPreviewMax) {
      return List<ExploreCreatorItem>.from(trendingCreatorsAll);
    }
    return trendingCreatorsAll.sublist(0, trendingCreatorsPreviewMax);
  }

  bool get showTrendingCreatorsViewAll =>
      trendingCreatorsAll.length > trendingCreatorsPreviewMax;

  /// False until trending reels, trending creators, and top-selling (store) have been loaded once.
  bool exploreInitialLoadComplete = false;

  List<StoreProduct> get topSellingProducts {
    if (Get.isRegistered<StoreScreenController>()) {
      return Get.find<StoreScreenController>().topSelling.toList();
    }
    return [];
  }

  @override
  void onInit() {
    super.onInit();
    _bootstrapExplore();
  }

  Future<void> _bootstrapExplore() async {
    exploreInitialLoadComplete = false;
    update();
    try {
      await Future.wait([
        fetchMostViewedReels(showErrorSnack: true),
        fetchTrendingCreators(showErrorSnack: true),
      ]);
      if (Get.isRegistered<StoreScreenController>()) {
        final sc = Get.find<StoreScreenController>();
        if (sc.topSelling.isEmpty && !sc.isLoadingTopSelling.value) {
          await sc.loadTopSellingProducts(silent: true);
        }
        for (var i = 0; i < 600 && sc.isLoadingTopSelling.value; i++) {
          await Future.delayed(const Duration(milliseconds: 32));
        }
      }
    } finally {
      exploreInitialLoadComplete = true;
      update();
    }
  }

  /// Pull-to-refresh: reload explore sections + store top selling (no full-page shimmer).
  /// Same “Refreshed” pill toast as [StoreScreenController.refreshStoreHome] when all succeed.
  Future<void> refreshExplore() async {
    final futures = <Future<bool>>[
      fetchMostViewedReels(showErrorSnack: false),
      fetchTrendingCreators(showErrorSnack: false),
    ];
    if (Get.isRegistered<StoreScreenController>()) {
      futures.add(Get.find<StoreScreenController>().loadTopSellingProducts(silent: true));
    }
    final results = await Future.wait(futures);
    if (results.every((e) => e)) {
      showSmallCenterToast(LKey.refreshed.tr, second: 1);
    }
    update();
  }

  Future<bool> fetchMostViewedReels({bool showErrorSnack = true}) async {
    isMostViewedReelsLoading = true;
    update();
    try {
      mostViewedReelsAll =
          await PostService.instance.fetchMostViewedReels(limit: 100);
      return true;
    } catch (e) {
      mostViewedReelsAll = [];
      if (showErrorSnack) showSnackBar(LKey.somethingWentWrong.tr);
      return false;
    } finally {
      isMostViewedReelsLoading = false;
      update();
    }
  }

  Future<bool> fetchTrendingCreators({bool showErrorSnack = true}) async {
    isTrendingCreatorsLoading = true;
    update();
    try {
      final models = await UserService.instance.fetchTrendingCreators();
      trendingCreatorsAll = models.map(_mapTrendingToItem).toList();
      return true;
    } catch (e) {
      trendingCreatorsAll = [];
      if (showErrorSnack) showSnackBar(LKey.somethingWentWrong.tr);
      return false;
    } finally {
      isTrendingCreatorsLoading = false;
      update();
    }
  }

  ExploreCreatorItem _mapTrendingToItem(TrendingCreatorModel m) {
    String? url;
    if (m.profilePhotoPath != null && m.profilePhotoPath!.isNotEmpty) {
      final p = m.profilePhotoPath!;
      url = p.startsWith('http') ? p : p.addBaseURL();
    }
    final displayName = m.fullname.trim().isNotEmpty ? m.fullname : m.username;
    final sub = (m.bio != null && m.bio!.trim().isNotEmpty)
        ? m.bio!.trim()
        : '@${m.username}';
    return ExploreCreatorItem(
      id: m.id,
      name: displayName,
      profession: sub,
      avatarUrl: url,
      verified: m.isVerify,
    );
  }
}
