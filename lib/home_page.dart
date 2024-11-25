import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/loading.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _login();
  }

  void _login() async {
    var api = await VrcApi.loadCurrent();
    if (api == null || !await api.checkValid()) {
      await Navigator.pushReplacementNamed(
        context,
        "/login",
      );
    } else {
      await Navigator.pushReplacementNamed(
        context,
        "/avatars",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Loading();
  }
}
