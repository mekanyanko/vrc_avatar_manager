import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager {
  static const key = 'imageCache';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 4096,
    ),
  );
}
