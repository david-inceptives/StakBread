import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/model/post_story/post_model.dart';

/// Preloads next N reel videos into default cache so when user scrolls they play faster (TikTok-style).
class ReelPreloadService {
  static const int preloadCount = 5;

  /// Preload the NEXT [preloadCount] videos (fromIndex+1, fromIndex+2, ...) into cache.
  /// Call on init and onPageChanged. Fire-and-forget; does not block.
  static void preloadNextReels(List<Post> reels, int fromIndex) {
    if (reels.isEmpty) return;
    final start = (fromIndex + 1).clamp(0, reels.length);
    final end = (fromIndex + 1 + preloadCount).clamp(0, reels.length);
    for (var i = start; i < end; i++) {
      final post = reels[i];
      final url = post.video?.addBaseURL() ?? '';
      if (url.isEmpty) continue;
      DefaultCacheManager().getSingleFile(url);
    }
  }
}
