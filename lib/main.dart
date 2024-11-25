import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vrc_avatar_manager/avatars_page.dart';
import 'package:vrc_avatar_manager/home_page.dart';
import 'package:vrc_avatar_manager/login_page.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VrcApi.appVersion = (await PackageInfo.fromPlatform()).version;
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
        '/login': (BuildContext context) => const LoginPage(),
        '/avatars': (BuildContext context) => const AvatarsPage(),
      },
    );
  }
}
