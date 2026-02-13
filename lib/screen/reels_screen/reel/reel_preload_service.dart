import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:stakBread/common/extensions/string_extension.dart';
import 'package:stakBread/model/post_story/post_model.dart';

/// TikTok/Shorts-style: sequential preload so current + next 5 are cached in order → instant play.
class ReelPreloadService {
  static const int preloadCount = 5;

  static final _cache = DefaultCacheManager();

  /// Preload first 5 reels in order (0,1,2,3,4) so current + next swipes play instantly. Fire-and-forget.
  static void preloadInitialReels(List<Post> reels) {
    if (reels.isEmpty) return;
    final end = preloadCount.clamp(0, reels.length);
    Future(() async {
      for (var i = 0; i < end; i++) {
        final url = reels[i].video?.addBaseURL() ?? '';
        if (url.isEmpty) continue;
        try {
          await _cache.getSingleFile(url).timeout(const Duration(seconds: 30));
        } catch (_) {}
      }
    });
  }

  /// Preload next 5 reels in order (fromIndex+1, +2, ...) so next swipes play instantly. Fire-and-forget.
  static void preloadNextReels(List<Post> reels, int fromIndex) {
    if (reels.isEmpty) return;
    final start = (fromIndex + 1).clamp(0, reels.length);
    final end = (fromIndex + 1 + preloadCount).clamp(0, reels.length);
    Future(() async {
      for (var i = start; i < end; i++) {
        final url = reels[i].video?.addBaseURL() ?? '';
        if (url.isEmpty) continue;
        try {
          await _cache.getSingleFile(url).timeout(const Duration(seconds: 30));
        } catch (_) {}
      }
    });
  }
}
