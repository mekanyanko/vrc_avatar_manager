import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/avatar_view.dart';
import 'package:vrc_avatar_manager/avatar_with_stat.dart';
import 'package:vrc_avatar_manager/clickable_view.dart';
import 'package:vrc_avatar_manager/db/tag.dart';
import 'package:vrc_avatar_manager/db/tag_type.dart';
import 'package:vrc_avatar_manager/db/tags_db.dart';
import 'package:vrc_avatar_manager/tag_edit_dialog.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';
import 'package:vrc_avatar_manager/vrc_icons.dart';

class AvatarsPage extends StatefulWidget {
  const AvatarsPage({super.key, required this.accountId});

  final String accountId;

  @override
  State<AvatarsPage> createState() => _AvatarsPageState();
}

class _AvatarsPageState extends State<AvatarsPage> {
  late final VrcApi _api;
  late final TagsDb _tagsDb;
  bool _tagsDbLoaded = false;

  final _searchController = TextEditingController();

  final MapValueSet<String, AvatarWithStat> _avatars =
      MapValueSet({}, (avatar) => avatar.id);

  MapValueSet<String, AvatarWithStat> _newAvatars =
      MapValueSet({}, (avatar) => avatar.id);

  bool _editTagAvatars = false;
  bool _editTags = false;
  Tag? _editTagAvatarTag;

  String _search = "";
  final List<bool> _isPlatformSelected = [false, false, false];
  final Set<int> _selectedTagIds = {};
  List<Tag> _tags = [];
  Iterable<Tag> get _selectedTags =>
      _tags.where((tag) => _selectedTagIds.contains(tag.id));

  @override
  void initState() {
    super.initState();
    _api = VrcApi.load(widget.accountId);
    _ensureDb().then((_) {
      setState(() {
        _tagsDbLoaded = true;
      });
      _loadAvatars();
      _watchTagsDb();
    });
  }

  Future<void> _ensureDb() async {
    _tagsDb = await TagsDb.instance(widget.accountId);
  }

  void _loadAvatars() async {
    _newAvatars =
        MapValueSet<String, AvatarWithStat>({}, (avatar) => avatar.id);
    var page = 1;
    while (true) {
      var avatars = await _api.avatars(page);
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

  void _watchTagsDb() async {
    _tagsDb.watchTags(fireImmediately: true).listen((_) {
      _loadTags();
    });
    _tagsDb.watchTagAvatars(fireImmediately: true).listen((_) {
      _loadTags();
    });
  }

  void _loadTags() async {
    var tags = await _tagsDb.getAll();
    setState(() {
      _tags = tags;
      if (_editTagAvatarTag != null) {
        _editTagAvatarTag =
            tags.firstWhereOrNull((tag) => tag.id == _editTagAvatarTag!.id);
      }
    });
  }

  void _logout() async {
    await _api.logout();
    await Navigator.pushReplacementNamed(
      context,
      "/login",
    );
  }

  void _changeAvatar(String id) async {
    var res = await _api.changeAvatar(id);
    if (res.succeeded) {
      _showInfo("Avatar changed");
    } else {
      _showError("Avatar change failed!");
      print(res.failure);
    }
  }

  void _toggleTagAvatar(String id) async {
    if (_editTagAvatarTag == null) {
      return;
    }
    await _editTagAvatarTag!.toggleAvatar(id, _tagsDb);
  }

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
    Iterable<AvatarWithStat> avatars = _avatars;
    for (var tag in _selectedTags) {
      avatars = tag.filterAvatars(avatars);
    }
    if (_isPlatformSelected[0]) {
      avatars = avatars.where((avatar) => avatar.hasPc);
    } else if (_isPlatformSelected[1]) {
      avatars = avatars.where((avatar) => avatar.hasAndroid);
    } else if (_isPlatformSelected[2]) {
      avatars = avatars.where((avatar) => avatar.hasCrossPlatform);
    }
    if (_search.isNotEmpty) {
      var search = _search.toLowerCase();
      avatars =
          avatars.where((avatar) => avatar.name.toLowerCase().contains(search));
    }
    return avatars;
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
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      if (!_tagsDbLoaded) {
                        return;
                      }
                      TagEditDialog.show(
                          context, Tag()..empty(), true, _tagsDb);
                    },
                    icon: const Icon(Icons.add)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _editTagAvatars = !_editTagAvatars;
                        if (_editTagAvatars) {
                          _editTags = false;
                        } else {
                          _editTagAvatarTag = null;
                        }
                      });
                    },
                    icon: const Icon(Icons.edit)),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _editTags = !_editTags;
                        if (_editTags) {
                          _editTagAvatars = false;
                          _editTagAvatarTag = null;
                        }
                      });
                    },
                    icon: const Icon(Icons.settings)),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8,
                      children: _tags
                          .map((tag) => Column(children: [
                                ElevatedButton(
                                    style: _selectedTagIds.contains(tag.id)
                                        ? ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary)
                                        : null,
                                    onPressed: () {
                                      setState(() {
                                        if (_selectedTagIds.contains(tag.id)) {
                                          _selectedTagIds.remove(tag.id);
                                        } else {
                                          _selectedTagIds.add(tag.id);
                                        }
                                      });
                                    },
                                    child: Text(tag.name)),
                                if (_editTags)
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    iconSize: 16,
                                    onPressed: () {
                                      TagEditDialog.show(
                                          context, tag, false, _tagsDb);
                                    },
                                    icon: const Icon(Icons.settings),
                                  ),
                                if (_editTagAvatars &&
                                    tag.type == TagType.items)
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    iconSize: 16,
                                    onPressed: () {
                                      setState(() {
                                        if (_editTagAvatarTag == tag) {
                                          _editTagAvatarTag = null;
                                        } else {
                                          _editTagAvatarTag = tag;
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.edit),
                                    style: _editTagAvatarTag == tag
                                        ? IconButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          )
                                        : null,
                                  ),
                              ]))
                          .toList(),
                    ))
              ],
            )),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filteredAvatars
                .map((avatar) => ClickableView(
                      key: Key(avatar.id),
                      child: AvatarView(
                          avatar: avatar,
                          selected: _editTagAvatarTag != null &&
                              _editTagAvatarTag!.avatarIds.contains(avatar.id)),
                      onTap: () => _editTagAvatarTag == null
                          ? _changeAvatar(avatar.id)
                          : _toggleTagAvatar(avatar.id),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
