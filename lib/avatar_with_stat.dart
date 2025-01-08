import 'package:vrc_avatar_manager/avatar_stat.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:collection/collection.dart';

// high num high priority
int _variantOrder(String? variant) {
  switch (variant) {
    case "security":
      return 9;
    case "standard":
      return 2;
    case "impostor":
      return 1;
    default:
      throw Exception("Unknown variant: $variant");
    // return 0;
  }
}

int _unityVersionOrder(UnityPackage up) {
  // 5.6系などはなぜかcreatedAtが2024-09-25とかのレコードが存在し、それのfileが404になるため優先度を下げる
  if (up.unityVersion.startsWith("5")) return 0;
  return 1;
}

class AvatarWithStat {
  AvatarWithStat(this.avatar) {
    var ups = avatar.unityPackages
        .sortedBy<num>((up) =>
            -_unityVersionOrder(up) *
                10000000000 *
                1000 // 10000000000(current 1736327388 * 10 order)
            -
            (up.createdAt?.millisecondsSinceEpoch ?? 0) * 10 -
            _variantOrder(up.variant))
        .toList();
    pc = AvatarStat(
        main: ups.firstWhereOrNull((u) =>
            u.platform == "standalonewindows" && u.variant != "impostor"),
        impostor: ups.firstWhereOrNull((u) =>
            u.platform == "standalonewindows" && u.variant == "impostor"));
    android = AvatarStat(
        main: ups.firstWhereOrNull(
            (u) => u.platform == "android" && u.variant != "impostor"),
        impostor: ups.firstWhereOrNull(
            (u) => u.platform == "android" && u.variant == "impostor"));
  }

  final Avatar avatar;

  late final AvatarStat pc;
  late final AvatarStat android;

  bool get hasPc => pc.hasMain;
  bool get hasAndroid => android.hasMain;
  bool get hasCrossPlatform => hasPc && hasAndroid;
  bool get hasImpostor => pc.hasImpostor || android.hasImpostor;

  String get id => avatar.id;
  String get name => avatar.name;
  String get desctipion => avatar.description;
  String get thumbnailImageUrl => avatar.thumbnailImageUrl;
  ReleaseStatus get releaseStatus => avatar.releaseStatus;
  DateTime get createdAt => avatar.createdAt;
  DateTime get updatedAt => avatar.updatedAt;
  int get version => avatar.version;

  bool hasUnityPackageIdInMain(Iterable<String> ids) =>
      pc.hasMain && ids.contains(pc.main!.id) ||
      android.hasMain && ids.contains(android.main!.id);
  List<String> get mainUnityPackageIds =>
      [if (pc.hasMain) pc.main!.id, if (android.hasMain) android.main!.id];
}
