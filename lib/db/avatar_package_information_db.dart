import 'dart:io';

import 'package:isar/isar.dart';
import 'package:vrc_avatar_manager/app_dir.dart';
import 'package:vrc_avatar_manager/db/avatar_package_information.dart';

class AvatarPackageInformationDb {
  static AvatarPackageInformationDb? _instance;
  const AvatarPackageInformationDb._(this.isar);

  final Isar isar;

  static Future<AvatarPackageInformationDb> get instance async {
    var dir = "${AppDir.dir}/.avatar_package_informations";
    await Directory(dir).create(recursive: true);
    return _instance ??= AvatarPackageInformationDb._(await Isar.open(
        [AvatarPackageInformationSchema],
        directory: dir, name: 'avatar_package_informations'));
  }

  Future<List<AvatarPackageInformation>> getAll() async {
    return isar.avatarPackageInformations.where().findAll();
  }

  Future<List<AvatarPackageInformation>> getAllByUnitypackageIds(
      Iterable<String> ids) async {
    return isar.avatarPackageInformations
        .where()
        .filter()
        .anyOf(ids, (q, id) => q.unityPackageIdEqualTo(id))
        .findAll();
  }

  Future<void> put(AvatarPackageInformation account) async {
    await isar.writeTxn(() async {
      await isar.avatarPackageInformations.put(account);
    });
  }

  Future<void> delete(String accountId) async {
    await isar.writeTxn(() async {
      await isar.avatarPackageInformations.delete(int.parse(accountId));
    });
  }

  Stream<void> watchAccounts({fireImmediately = false}) {
    return isar.avatarPackageInformations
        .watchLazy(fireImmediately: fireImmediately);
  }
}
