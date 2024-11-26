import 'package:shared_preferences/shared_preferences.dart';

const _confirmWhenChangeAvatar = "confirmWhenChangeAvatar";

class Prefs {
  static Prefs? _instance;

  Prefs._(this._prefs);

  final SharedPreferences _prefs;

  static Future<Prefs> get instance async {
    return _instance ??= Prefs._(await SharedPreferences.getInstance());
  }

  Future<bool> get confirmWhenChangeAvatar async {
    return _prefs.getBool(_confirmWhenChangeAvatar) ?? false;
  }

  Future<void> setConfirmWhenChangeAvatar(bool value) async {
    await _prefs.setBool(_confirmWhenChangeAvatar, value);
  }
}
