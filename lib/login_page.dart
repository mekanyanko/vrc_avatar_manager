import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:vrc_avatar_manager/store.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _twoFactorController = TextEditingController();
  final _authTokenController = TextEditingController();
  final _uuid = const Uuid();

  VrcApi? _api;

  void _loginByUsernamePassword() async {
    var username = _usernameController.text;
    var password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      _showError("Username and password cannot be empty");
      return;
    }
    var account = _uuid.v4();
    var api = VrcApi.load(account);
    var res =
        await api.vrchatDart.auth.login(username: username, password: password);
    if (!res.succeeded) {
      _showError("Cannot login with that username/password");
      return;
    }
    var authResponse = res.success!.data;
    if (authResponse.requiresTwoFactorAuth) {
      setState(() {
        _api = api;
      });
      return;
    }
    await Store().setAccount(account);

    await Navigator.pushReplacementNamed(context, "/avatars");
  }

  void _loginBy2FA() async {
    if (_api == null) {
      _showError("No API to login with 2FA");
      return;
    }
    var code = _twoFactorController.text;
    if (code.isEmpty) {
      _showError("2FA code cannot be empty");
      return;
    }
    _twoFactorController.text = "";
    var res = await _api!.vrchatDart.auth.verify2fa(code);
    if (!res.succeeded) {
      _showError("Cannot login with that 2FA code");
      return;
    }

    await Store().setAccount(_api!.account);
    await Navigator.pushReplacementNamed(context, "/avatars");
  }

  void _cancel2FA() {
    setState(() {
      _api = null;
    });
  }

  void _loginByAuthToken() async {
    var authToken =
        RegExp(r"authcookie_[\w-]+").stringMatch(_authTokenController.text);
    if (authToken == null) {
      _showError("Invalid auth token");
      return;
    }
    var account = _uuid.v4();
    var api = VrcApi.loadByAuthToken(account, authToken);
    var checked = await api.checkValid();
    if (!checked) {
      _showError("Cannot login with that auth token");
      return;
    }
    await Navigator.pushReplacementNamed(context, "/avatars");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: true,
        backgroundColor: const Color(0xFFFF6600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Login"),
      ),
      body: Center(
          child: SizedBox(
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Login by username/password',
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              controller: _usernameController,
              enabled: _api == null,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              onSubmitted: (value) => _loginByUsernamePassword(),
            ),
            TextField(
              controller: _passwordController,
              enabled: _api == null,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              onSubmitted: (value) => _loginByUsernamePassword(),
            ),
            if (_api != null)
              TextField(
                controller: _twoFactorController,
                decoration: const InputDecoration(
                  labelText: '2FA code',
                ),
                onSubmitted: (value) => _loginBy2FA(),
              ),
            ElevatedButton(
              onPressed: _api == null ? _loginByUsernamePassword : _loginBy2FA,
              child: const Text("Login"),
            ),
            if (_api != null)
              ElevatedButton(
                onPressed: _cancel2FA,
                child: const Text("Cancel 2FA"),
              ),
            const Divider(),
            const Text(
              'Login by auth token',
              style: TextStyle(fontSize: 20),
            ),
            TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse("https://vrchat.com/home/login"));
                },
                child: const Text("VRChat login page")),
            TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse("https://vrchat.com/api/1/auth"));
                },
                child: const Text("VRChat auth token (after login)")),
            TextField(
              controller: _authTokenController,
              decoration: const InputDecoration(
                labelText: 'Auth token',
              ),
              onSubmitted: (value) => _loginByAuthToken(),
            ),
            ElevatedButton(
              onPressed: _loginByAuthToken,
              child: const Text("Login"),
            ),
          ],
        ),
      )),
    );
  }
}
