import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<String?> get account async => read("account");
  Future<void> setAccount(String account) async => write("account", account);
  Future<void> deleteAccount() async => delete("account");
}
