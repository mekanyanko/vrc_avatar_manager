import 'package:vrc_avatar_manager/avatar_stat.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:collection/collection.dart';

class AvatarWithStat {
  AvatarWithStat(this.avatar) {
    var ups = avatar.unityPackages
        .sorted((a, b) => -a.assetVersion.compareTo(b.assetVersion));
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
  String get thumbnailImageUrl => avatar.thumbnailImageUrl;
  ReleaseStatus get releaseStatus => avatar.releaseStatus;
}
