import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:stakBread/common/controller/base_controller.dart';
import 'package:stakBread/common/manager/firebase_notification_manager.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/manager/share_manager.dart';
import 'package:stakBread/common/service/api/api_service.dart';
import 'package:stakBread/common/service/api/common_service.dart';
import 'package:stakBread/common/service/api/post_service.dart';
import 'package:stakBread/common/service/api/user_service.dart';
import 'package:stakBread/common/service/location/location_service.dart';
import 'package:stakBread/common/service/navigation/navigate_with_controller.dart';
import 'package:stakBread/model/general/place_detail.dart';
import 'package:stakBread/model/post_story/post_by_id.dart';
import 'package:stakBread/model/post_story/post_model.dart';
import 'package:stakBread/model/user_model/user_model.dart';
import 'package:stakBread/screen/post_screen/single_post_screen.dart';
import 'package:stakBread/screen/reels_screen/reels_screen.dart';
import 'package:stakBread/screen/reels_screen/reels_screen_controller.dart';
import 'package:stakBread/utilities/app_res.dart';

class HomeScreenController extends BaseController with GetSingleTickerProviderStateMixin {
  Rx<TabType> selectedReelCategory = TabType.values.first.obs;
  RxList<Post> reels = <Post>[].obs;
  late AnimationController controller;
  late Animation<double> animation;
  RxBool isAnimateTab = false.obs;
  StreamSubscription<Map>? streamSubscription;
  CancelToken token = CancelToken();
  /// Prevents multiple simultaneous "load more" calls and duplicate data.
  bool _isLoadMoreInProgress = false;

  Rx<User?> get myUser => Rx(SessionManager.instance.getUser());

  @override
  void onInit() {
    controller = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);

    // Call both methods concurrently
    Future.wait([
      onRefreshPage(),
      _onNotificationTap(),
      _fetchLocation(),
      _readDeepLink(),
    ]);

    super.onInit();
  }

  @override
  void onReady() {
    isLoading.value = true;
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    controller.dispose();
    streamSubscription?.cancel();
  }

  Future<void> _onNotificationTap() async {
    if (Platform.isIOS) {
      // Handle the iOS notification payload once
      final payload = FirebaseNotificationManager.instance.notificationPayload.value;
      if (payload.isNotEmpty) {
        FirebaseNotificationManager.instance.handleNotification(payload);
      }
    } else {
      // Set up a listener to handle future payload changes
      // Android: Get the message if the app was opened via notification
      RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();

      if (message != null) {
        await FirebaseNotificationManager.instance.handleNotification(jsonEncode(message.toMap()));
      }
    }

    FirebaseNotificationManager.instance.notificationPayload.listen((p0) {
      if (p0.isNotEmpty) {
        FirebaseNotificationManager.instance.handleNotification(p0);
      }
    });
  }

  Future<void> _readDeepLink() async {
    ShareManager.shared.listen((key, value) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (key == ShareKeys.post.value) {
        PostByIdModel model = await PostService.instance.fetchPostById(postId: value);
        if (model.status == true) {
          Post? post = model.data?.post;
          if (post != null) {
            await Get.to(() => SinglePostScreen(post: post, isFromNotification: true), preventDuplicates: false);
          }
        }
      } else if (key == ShareKeys.reel.value) {
        PostByIdModel model = await PostService.instance.fetchPostById(postId: value);
        if (model.status == true) {
          Post? post = model.data?.post;
          if (post != null) {
            await Get.to(() => ReelsScreen(reels: [post].obs, position: 0), preventDuplicates: false);
          }
        }
      } else if (key == ShareKeys.user.value) {
        User? user = await UserService.instance.fetchUserDetails(userId: value);
        if (user != null) {
          await NavigationService.shared.openProfileScreen(user);
        }
      }
    });
  }

  Future<void> onRefreshPage({bool reset = true}) async {
    if (reset) {
      isLoading.value = true;
    }
    switch (selectedReelCategory.value) {
      case TabType.discover:
        await fetchDiscoverPost(reset);
        break;
      case TabType.following:
        await _fetchFollowingPost(reset);
        break;
      case TabType.nearby:
        try {
          await _fetchPostsNearBy(reset);
        } catch (e) {
          selectedReelCategory.value = TabType.discover;
        }
        break;
    }
  }

  onTabTypeChanged(TabType tabType) async {
    onAnimationBack();
    if (selectedReelCategory.value == tabType) {
      return;
    }
    selectedReelCategory.value = tabType;
    await onRefreshPage.call(reset: true);
  }

  onToggleDropDown() {
    if (animation.status != AnimationStatus.completed) {
      controller.forward();
      isAnimateTab.value = true;
    } else {
      onAnimationBack();
    }
  }

  onAnimationBack() {
    isAnimateTab.value = false;
    controller.animateBack(0, duration: const Duration(milliseconds: 250), curve: Curves.linear);
  }

  Future<void> fetchDiscoverPost(bool resetData) async {
    if (!resetData && _isLoadMoreInProgress) return;
    if (!resetData) _isLoadMoreInProgress = true;
    isLoading.value = true;
    final lastId = resetData ? null : (reels.isNotEmpty ? reels.last.id : null);
    List<Post> newPosts = await PostService.instance.fetchPostsDiscover(
      type: PostType.reels,
      lastItemId: lastId?.toInt(),
      cancelToken: token,
    );
    addResponseData(newPosts, resetData);
    if (!resetData) _isLoadMoreInProgress = false;
  }

  Future<void> _fetchFollowingPost(bool resetData) async {
    if (!resetData && _isLoadMoreInProgress) return;
    if (!resetData) _isLoadMoreInProgress = true;
    isLoading.value = true;
    final lastId = resetData ? null : (reels.isNotEmpty ? reels.last.id : null);
    List<Post> newPosts = await PostService.instance.fetchPostsFollowing(
      type: PostType.reels,
      lastItemId: lastId?.toInt(),
      cancelToken: token,
    );
    addResponseData(newPosts, resetData);
    if (!resetData) _isLoadMoreInProgress = false;
  }

  Future<void> _fetchPostsNearBy(bool resetData) async {
    if (!resetData && _isLoadMoreInProgress) return;
    if (!resetData) _isLoadMoreInProgress = true;
    isLoading.value = true;
    Position position = await LocationService.instance.getCurrentLocation(isPermissionDialogShow: true);
    final lastId = resetData ? null : (reels.isNotEmpty ? reels.last.id : null);
    List<Post> newPosts = await PostService.instance.fetchPostsNearBy(
      type: PostType.reels,
      placeLat: position.latitude,
      placeLon: position.longitude,
      lastItemId: lastId?.toInt(),
      cancelToken: token,
    );
    addResponseData(newPosts, resetData);
    if (!resetData) _isLoadMoreInProgress = false;
  }

  static int? _postId(Post p) => p.id?.toInt();

  void addResponseData(List<Post> newPosts, bool resetData) {
    if (resetData) {
      reels.clear();
      if (Get.isRegistered<ReelsScreenController>(tag: ReelsScreenController.tag)) {
        var controller = Get.find<ReelsScreenController>(tag: ReelsScreenController.tag);
        controller.handleRefresh(() async {});
      }
    }
    if (newPosts.isEmpty) {
      isLoading.value = false;
      return;
    }
    if (resetData) {
      // Deduplicate by id so we never show same post twice even if API returns duplicates
      final seenIds = <int>{};
      for (final p in newPosts) {
        final id = _postId(p);
        if (id != null && !seenIds.contains(id)) {
          seenIds.add(id);
          reels.add(p);
        }
      }
    } else {
      final existingIds = reels.map(_postId).whereType<int>().toSet();
      for (final p in newPosts) {
        final id = _postId(p);
        if (id != null && !existingIds.contains(id)) {
          existingIds.add(id);
          reels.add(p);
        }
      }
    }
    isLoading.value = false;
  }

  Future<void> _fetchLocation() async {
    PlaceDetail? detail;
    try {
      detail = await CommonService.instance.getIPPlaceDetail();
    } catch (e) {
      Loggers.error('Location error : $e');
    }

    if (detail != null) {
      UserService.instance
          .updateUserDetails(region: detail.region, regionName: detail.regionName, timezone: detail.timezone);
    }
  }
}
