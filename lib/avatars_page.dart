import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/avatar_view.dart';
import 'package:vrc_avatar_manager/avatar_with_stat.dart';
import 'package:vrc_avatar_manager/clickable_view.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';
import 'package:vrc_avatar_manager/vrc_icons.dart';

class AvatarsPage extends StatefulWidget {
  const AvatarsPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<AvatarsPage> createState() => _AvatarsPageState();
}

class _AvatarsPageState extends State<AvatarsPage> {
  final MapValueSet<String, AvatarWithStat> _avatars =
      MapValueSet({}, (avatar) => avatar.id);

  MapValueSet<String, AvatarWithStat> _newAvatars =
      MapValueSet({}, (avatar) => avatar.id);

  final _searchController = TextEditingController();

  String _search = "";
  final List<bool> _isPlatformSelected = [false, false, false];

  @override
  void initState() {
    super.initState();
    _loadAvatars();
  }

  void _loadAvatars() async {
    var api = await _api;
    _newAvatars =
        MapValueSet<String, AvatarWithStat>({}, (avatar) => avatar.id);
    var page = 1;
    while (true) {
      var avatars = await api.avatars(page);
      if (avatars == null) {
        break;
      } else {
        if (avatars.isEmpty) {
          break;
        }
        var avatarStats =
            avatars.map((avatar) => AvatarWithStat(avatar)).toList();
        _newAvatars.addAll(avatarStats);
        setState(() {
          _avatars.addAll(avatarStats);
        });
      }
      page++;
    }
    setState(() {
      _avatars.removeAll(_avatars.difference(_newAvatars));
    });
  }

  void _logout() async {
    var api = await _api;
    await api.logout();
    await Navigator.pushReplacementNamed(
      context,
      "/login",
    );
  }

  void _changeAvatar(String id) async {
    var api = await _api;
    var res = await api.changeAvatar(id);
    if (res.succeeded) {
      _showInfo("Avatar changed");
    } else {
      _showError("Avatar change failed!");
      print(res.failure);
    }
  }

  Future<VrcApi> get _api async => (await VrcApi.loadCurrent())!;

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: true,
        backgroundColor: const Color(0xFF0066FF),
      ),
    );
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

  Iterable<AvatarWithStat> get _filteredAvatars {
    var search = _search.toLowerCase();
    return _avatars.where((avatar) {
      if (_isPlatformSelected[0] && !avatar.hasPc) {
        return false;
      }
      if (_isPlatformSelected[1] && !avatar.hasAndroid) {
        return false;
      }
      if (_isPlatformSelected[2] && !avatar.hasCrossPlatform) {
        return false;
      }
      if (search.isNotEmpty) {
        return avatar.name.toLowerCase().contains(search);
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: _avatars.length != _newAvatars.length
            ? Text(
                "${_avatars.length} avatars (fetching ${_newAvatars.length} avatars)")
            : Text(
                '${_avatars.length} avatars',
              ),
        actions: [
          ToggleButtons(
            isSelected: _isPlatformSelected,
            onPressed: (int index) {
              setState(() {
                for (var buttonIndex = 0;
                    buttonIndex < _isPlatformSelected.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    _isPlatformSelected[buttonIndex] =
                        !_isPlatformSelected[buttonIndex];
                  } else {
                    _isPlatformSelected[buttonIndex] = false;
                  }
                }
              });
            },
            children: [
              VrcIcons.pc,
              VrcIcons.android,
              VrcIcons.crossPlatform,
            ],
          ),
          SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: "Search",
                ),
                onChanged: (value) => setState(() {
                  _search = value;
                }),
              )),
          const SizedBox(width: 40),
          IconButton(
            iconSize: 36,
            icon: const Icon(Icons.refresh),
            onPressed: _loadAvatars,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            children: _filteredAvatars
                .map((avatar) => ClickableView(
                      key: Key(avatar.id),
                      child: AvatarView(avatar: avatar),
                      onTap: () => _changeAvatar(avatar.id),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
