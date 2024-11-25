import 'dart:io';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_response_validator/dio_response_validator.dart';
import 'package:vrc_avatar_manager/store.dart';
import 'package:vrchat_dart/vrchat_dart.dart';

class VrcApi {
  const VrcApi({required this.account, required this.vrchatDart});

  final String account;
  final VrchatDart vrchatDart;

  static String appVersion = "0.0.1";

  static Future<VrcApi?> loadCurrent() async {
    var actualAccount = await Store().account;
    if (actualAccount == null) {
      return null;
    }
    return load(actualAccount);
  }

  static VrcApi load(String account) {
    return VrcApi(account: account, vrchatDart: getVrchatDart(account));
  }

  static VrcApi loadByAuthToken(String account, String authToken) {
    var vrchatDart = getVrchatDart(account);
    var cookieManager = (vrchatDart.rawApi.dio.interceptors
        .firstWhere((i) => i is CookieManager) as CookieManager);
    cookieManager.cookieJar.saveFromResponse(
        Uri.https("api.vrchat.cloud", "/"), [
      Cookie.fromSetCookieValue(
          'auth=$authToken; Path=/; HttpOnly; SameSite=Lax;')
    ]);
    return VrcApi(account: account, vrchatDart: vrchatDart);
  }

  static VrchatDart getVrchatDart(String account) {
    return VrchatDart(cookiePath: ".cookie/$account", userAgent: userAgent);
  }

  static VrchatUserAgent? _userAgent;

  static VrchatUserAgent get userAgent {
    return _userAgent ??= VrchatUserAgent(
        applicationName: "VRCAvatarManager",
        version: appVersion,
        contactInfo: "VRCAvatarManager");
  }

  static String? _userAgentString;
  static String get userAgentString {
    return _userAgentString ??= userAgent.toString();
  }

  Future<bool> checkValid() async {
    return (await check()).succeeded;
  }

  Future<ValidatedResponse<CurrentUser, CurrentUser>> check() async {
    return vrchatDart.rawApi
        .getAuthenticationApi()
        .getCurrentUser()
        .validateVrc();
  }

  Future<void> logout() async {
    await vrchatDart.auth.logout();
    await Store().deleteAccount();
  }

  Future<List<Avatar>?> avatars(int page) async {
    var res = await vrchatDart.rawApi
        .getAvatarsApi()
        .searchAvatars(
            releaseStatus: ReleaseStatus.all,
            user: "me",
            sort: SortOption.created,
            order: OrderOption.descending,
            n: 100,
            offset: (page - 1) * 100)
        .validateVrc();
    if (res.succeeded) {
      return res.success!.data;
    }
    print(res.failure.toString());
    return null;
  }

  Future<ValidatedResponse<CurrentUser, CurrentUser>> changeAvatar(
      String id) async {
    return await vrchatDart.rawApi
        .getAvatarsApi()
        .selectAvatar(avatarId: id)
        .validateVrc();
  }
}
