import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vrc_avatar_manager/avatar_with_stat.dart';
import 'package:vrc_avatar_manager/image_cache_manager.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';
import 'package:vrc_avatar_manager/vrc_icons.dart';
import 'package:vrchat_dart/vrchat_dart.dart';

final dateFormat = DateFormat('y-MM-dd');

class AvatarView extends StatelessWidget {
  const AvatarView(
      {super.key,
      required this.avatar,
      this.selected = false,
      this.detailed = false});

  final AvatarWithStat avatar;
  final bool selected;
  final bool detailed;

  static Image performanceIcon(PerformanceRatings p) {
    switch (p) {
      case PerformanceRatings.excellent:
        return VrcIcons.excellent;
      case PerformanceRatings.good:
        return VrcIcons.good;
      case PerformanceRatings.medium:
        return VrcIcons.medium;
      case PerformanceRatings.poor:
        return VrcIcons.poor;
      case PerformanceRatings.veryPoor:
        return VrcIcons.verypoor;
      default:
        return VrcIcons.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        height: detailed ? 260 : 220,
        color: selected ? Colors.green : null,
        child: Column(children: [
          SizedBox(
              width: 200,
              height: 150,
              child: CachedNetworkImage(
                imageUrl: avatar.thumbnailImageUrl,
                httpHeaders: {"user-agent": VrcApi.userAgentString},
                fadeOutDuration: const Duration(milliseconds: 200),
                fadeInDuration: const Duration(milliseconds: 200),
                errorWidget: (context, url, error) {
                  print(error);
                  return const Icon(Icons.error);
                },
                cacheManager: ImageCacheManager.instance,
              )),
          Text(avatar.name),
          Row(
            children: [
              if (avatar.releaseStatus == ReleaseStatus.public)
                const Text("Public"),
              if (avatar.pc.hasMain) VrcIcons.pc,
              if (avatar.pc.performanceRating != null)
                performanceIcon(avatar.pc.performanceRating!),
              if (avatar.android.hasMain) VrcIcons.android,
              if (avatar.android.performanceRating != null)
                performanceIcon(avatar.android.performanceRating!),
            ],
          ),
          if (detailed)
            Text(avatar.desctipion,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          if (detailed)
            Text("作成: ${dateFormat.format(avatar.createdAt.toLocal())}"),
          if (detailed)
            Text("更新: ${dateFormat.format(avatar.updatedAt.toLocal())}"),
        ]));
  }
}
