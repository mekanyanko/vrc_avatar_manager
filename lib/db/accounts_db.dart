import 'dart:io';

import 'package:isar/isar.dart';
import 'package:vrc_avatar_manager/app_dir.dart';
import 'package:vrc_avatar_manager/db/account.dart';

class AccountsDb {
  static AccountsDb? _instance;
  const AccountsDb._(this.isar);

  final Isar isar;

  static Future<AccountsDb> get instance async {
    var dir = "${AppDir.dir}/.accounts";
    await Directory(dir).create(recursive: true);
    return _instance ??= AccountsDb._(
        await Isar.open([AccountSchema], directory: dir, name: 'accounts'));
  }

  Future<List<Account>> getAll() async {
    return isar.accounts.where().findAll();
  }

  Future<void> put(Account account) async {
    await isar.writeTxn(() async {
      await isar.accounts.put(account);
    });
  }

  Future<void> delete(String accountId) async {
    await isar.writeTxn(() async {
      await isar.accounts.delete(int.parse(accountId));
    });
  }

  Stream<void> watchAccounts({fireImmediately = false}) {
    return isar.accounts.watchLazy(fireImmediately: fireImmediately);
  }
}
