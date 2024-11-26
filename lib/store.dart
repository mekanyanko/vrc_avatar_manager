import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _defaultAccountId = "defaultAccountId";

class Store {
  static final Store _store = Store._internal();

  factory Store() {
    return _store;
  }

  Store._internal();

  final storage = const FlutterSecureStorage();

  Future<String?> read(String key) async {
    return await storage.read(key: key);
  }

  Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  Future<String?> get defaultAccountId async => read(_defaultAccountId);
  Future<void> setDefaultAccountId(String account) async =>
      write(_defaultAccountId, account);
  Future<void> deleteDefaultAccountId() async => delete(_defaultAccountId);

  Future<void> setCredentials(
      String account, String username, String password) async {
    await write("$account.username", username);
    await write("$account.password", password);
  }

  Future<(String, String)?> getCredentials(String account) async {
    var username = await read("$account.username");
    var password = await read("$account.password");
    if (username == null || password == null) {
      return null;
    }
    return (username, password);
  }

  Future<void> deleteCredentials(String account) async {
    await delete("$account.username");
    await delete("$account.password");
  }
}
