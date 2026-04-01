import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/service/api/post_service.dart';
import 'package:stakBread/common/service/api/user_service.dart';
import 'package:stakBread/common/service/location/location_service.dart';
import 'package:stakBread/languages/languages_keys.dart';
import 'package:stakBread/model/post_story/post_model.dart';
import 'package:stakBread/model/post_story/story/story_model.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/camera_screen/camera_screen.dart';
import 'package:stakBread/screen/profile_screen/profile_screen_controller.dart';
import 'package:stakBread/screen/story_view_screen/story_view_screen.dart';

class FeedScreenController extends BaseController {
  RxList<Post> posts = RxList();
  RxList<User> stories = RxList();
  Rx<PostCategory> selectedPostCategory = PostCategory.discover.obs;
  ScrollController postScrollController = ScrollController();
  RxBool isStoriesLoading = false.obs;
  Rx<User?> myUser;

  FeedScreenController(this.myUser);

  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void onInit() {
    super.onInit();
    initData();
    postScrollController.addListener(_loadMoreData);
  }

  initData() {
    Future.wait([fetchDiscoverPost(), _fetchStory()]);
  }

  Future<void> _fetchMyUser() async {
    myUser.value = await UserService.instance.fetchUserDetails();
  }

  Future<void> _fetchStory({bool isEmpty = false}) async {
    isStoriesLoading.value = true;
    List<User> items = await PostService.instance.fetchStory();
    if (isEmpty) {
      stories.clear();
    }
    stories.addAll(items);
    isStoriesLoading.value = false;
  }

  int? _lastItemIdForPage({required bool isEmpty}) {
    if (isEmpty) return null;
    if (posts.isEmpty) return null;
    return posts.last.id?.toInt();
  }

  Future<void> fetchDiscoverPost({bool isEmpty = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    final lastId = _lastItemIdForPage(isEmpty: isEmpty);
    List<Post> _post = await PostService.instance.fetchPostsDiscover(
        type: PostType.posts, lastItemId: lastId);
    _addDataInPostList(_post, isEmpty);
  }

  Future<void> _fetchPostsFollowing({bool isEmpty = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    final lastId = _lastItemIdForPage(isEmpty: isEmpty);
    List<Post> _post = await PostService.instance.fetchPostsFollowing(
        type: PostType.posts, lastItemId: lastId);
    _addDataInPostList(_post, isEmpty);
  }

  Future<void> _fetchPostsNearBy({bool isEmpty = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    Position position = await LocationService.instance
        .getCurrentLocation(isPermissionDialogShow: true);

    final lastId = _lastItemIdForPage(isEmpty: isEmpty);
    List<Post> _post = await PostService.instance.fetchPostsNearBy(
        type: PostType.posts,
        placeLat: position.latitude,
        placeLon: position.longitude,
        lastItemId: lastId);

    _addDataInPostList(_post, isEmpty);
  }

  _addDataInPostList(List<Post> newList, bool isEmpty) async {
    if (isEmpty) {
      posts.clear();
    }
    if (newList.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      isLoading.value = false;
      return;
    }
    if (isEmpty) {
      posts.addAll(newList);
    } else {
      final existingIds = posts.map((p) => p.id).toSet();
      final toAdd = newList
          .where((p) => p.id != null && !existingIds.contains(p.id))
          .toList();
      posts.addAll(toAdd);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    isLoading.value = false;
  }

  void _removeAndDisposeListener() {
    postScrollController.removeListener(_loadMoreData);
    postScrollController.dispose();
  }

  Future<void> onChangeCategory(PostCategory value) async {
    selectedPostCategory.value = value;
    isLoading.value = false;
    switch (value) {
      case PostCategory.discover:
        await fetchDiscoverPost(isEmpty: true);
      case PostCategory.nearby:
        try {
          await _fetchPostsNearBy(isEmpty: true);
        } catch (e) {
          selectedPostCategory.value = PostCategory.discover;
          await fetchDiscoverPost(isEmpty: true);
        }
      case PostCategory.following:
        await _fetchPostsFollowing(isEmpty: true);
    }
  }

  Future<void> onRefresh() async {
    await onChangeCategory(selectedPostCategory.value);
    await _fetchStory(isEmpty: true);
    await _fetchMyUser();
  }

  void onCreateStory() {
    Get.to(() => const CameraScreen(cameraType: CameraScreenType.story));
  }

  void onAddStory(Story? story) {
    if (story == null) return; // Exit early if story is null
    myUser.update((val) {
      val?.stories?.add(story);
    });
  }

  void onWatchStory(List<User> users, int index, String watchType) {
    Get.bottomSheet(
      StoryViewSheet(
        stories: users,
        userIndex: index,
        onUpdateDeleteStory: (story) {
          final userId = story?.userId;
          final storyId = story?.id;

          if (userId == SessionManager.instance.getUserID()) {
            // Update profile screen controller if registered
            if (Get.isRegistered<ProfileScreenController>(
                tag: ProfileScreenController.tag)) {
              final controller = Get.find<ProfileScreenController>(
                  tag: ProfileScreenController.tag);
              controller.userData.update((val) {
                val?.stories?.removeWhere((s) => s.id == storyId);
              });
            }

            // Update current user stories
            myUser.update((val) {
              val?.stories?.removeWhere((s) => s.id == storyId);
            });
          } else {
            // Remove story from other user's list
            final userIndex = stories.indexWhere((u) => u.id == userId);
            if (userIndex != -1) {
              (stories[userIndex].stories ?? [])
                  .removeWhere((s) => s.id == storyId);
            }
          }
        },
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
      useRootNavigator:
          true, // Ensures the BottomSheet is on top of all navigators
    ).then((value) {
      // For check story view or not
      switch (watchType) {
        case 'my_story':
          _fetchMyUser();
          break;
        case 'other_story':
          _fetchStory(isEmpty: true);
      }
    });
  }

  Future<void> _loadMoreData() async {
    if (!postScrollController.hasClients) return;
    final pos = postScrollController.position;
    if (pos.maxScrollExtent <= 0) return;
    if (pos.pixels < pos.maxScrollExtent - 300) return;
    if (isLoading.value) return;

    switch (selectedPostCategory.value) {
      case PostCategory.discover:
        await fetchDiscoverPost();
      case PostCategory.nearby:
        await _fetchPostsNearBy();
      case PostCategory.following:
        await _fetchPostsFollowing();
    }
  }

  @override
  void onClose() {
    super.onClose();
    _removeAndDisposeListener();
  }
}

enum PostCategory {
  discover,
  nearby,
  following;

  String get title {
    switch (this) {
      case PostCategory.discover:
        return LKey.discover.tr;
      case PostCategory.nearby:
        return LKey.nearby.tr;
      case PostCategory.following:
        return LKey.following.tr;
    }
  }
}
