import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vrc_avatar_manager/app_dir.dart';
import 'package:vrc_avatar_manager/avatars_page.dart';
import 'package:vrc_avatar_manager/home_page.dart';
import 'package:vrc_avatar_manager/accounts_page.dart';
import 'package:vrc_avatar_manager/login_page.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VrcApi.appVersion = (await PackageInfo.fromPlatform()).version;
  AppDir.dir = (await getApplicationSupportDirectory()).path;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VRC Avatar Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "/accounts") {
          if (settings.arguments is String) {
            return MaterialPageRoute(
              builder: (context) =>
                  AccountsPage(goAccount: settings.arguments as String),
            );
          }
          return MaterialPageRoute(
            builder: (context) => const AccountsPage(),
          );
        } else if (settings.name == "/login") {
          if (settings.arguments is String) {
            return MaterialPageRoute(
              builder: (context) =>
                  LoginPage(accountId: settings.arguments as String),
            );
          }
          return MaterialPageRoute(
            builder: (context) => const AccountsPage(),
          );
        } else if (settings.name == "/avatars" &&
            settings.arguments is String) {
          return MaterialPageRoute(
            builder: (context) =>
                AvatarsPage(accountId: settings.arguments as String),
          );
        }
        return null;
      },
    );
  }
}
