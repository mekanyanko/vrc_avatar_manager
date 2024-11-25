import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/avatar_stat.dart';
import 'package:vrc_avatar_manager/avatar_with_stat.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';
import 'package:vrc_avatar_manager/vrc_icons.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:collection/collection.dart';

class AvatarView extends StatelessWidget {
  const AvatarView({super.key, required this.avatar});

  final AvatarWithStat avatar;

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
    return SizedBox(
        width: 200,
        height: 220,
        child: Column(children: [
          CachedNetworkImage(
            imageUrl: avatar.thumbnailImageUrl,
            httpHeaders: {"user-agent": VrcApi.userAgentString},
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) {
              print(error);
              return const Icon(Icons.error);
            },
          ),
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
          )
        ]));
  }
}
