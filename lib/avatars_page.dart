import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/avatar_view.dart';
import 'package:vrc_avatar_manager/avatar_with_stat.dart';
import 'package:vrc_avatar_manager/clickable_view.dart';
import 'package:vrc_avatar_manager/db/tag.dart';
import 'package:vrc_avatar_manager/db/tag_type.dart';
import 'package:vrc_avatar_manager/db/tags_db.dart';
import 'package:vrc_avatar_manager/performance_selector.dart';
import 'package:vrc_avatar_manager/prefs.dart';
import 'package:vrc_avatar_manager/sort_by.dart';
import 'package:vrc_avatar_manager/tag_button.dart';
import 'package:vrc_avatar_manager/tag_edit_dialog.dart';
import 'package:vrc_avatar_manager/vrc_api.dart';
import 'package:vrc_avatar_manager/vrc_icons.dart';
import 'package:vrchat_dart/vrchat_dart.dart';

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

  List<AvatarWithStat> _sortedAvatars = [];

  bool _confirmWhenChangeAvatar = false;
  bool _ascending = false;
  SortBy _sortBy = SortBy.createdAt;
  bool _editTagAvatars = false;
  bool _editTags = false;
  Tag? _editTagAvatarTag;

  final Set<PerformanceRatings> _pcPerformanceBlocks = {};
  final Set<PerformanceRatings> _androidPerformanceBlocks = {};
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
    _restoreSettings();
  }

  void _restoreSettings() async {
    final prefs = await Prefs.instance;
    var confirmWhenChangeAvatar = await prefs.confirmWhenChangeAvatar;
    var ascending = await prefs.ascending;
    var sortBy = await prefs.sortBy;
    setState(() {
      _confirmWhenChangeAvatar = confirmWhenChangeAvatar;
      _ascending = ascending;
      _sortBy = sortBy;
      _sortAvatars();
    });
  }

  Future<void> _ensureDb() async {
    _tagsDb = await TagsDb.instance(widget.accountId);
  }

  void _sortAvatars() {
    var comparator = _ascending
        ? <T extends Comparable<T>>(T a, T b) => a.compareTo(b)
        : <T extends Comparable<T>>(T a, T b) => b.compareTo(a);
    _sortedAvatars = switch (_sortBy) {
      SortBy.createdAt => _avatars.sorted((a, b) =>
          comparator(a.createdAt, b.createdAt) * 10 +
          comparator(a.updatedAt, b.updatedAt)),
      SortBy.updatedAt => _avatars.sorted((a, b) =>
          comparator(a.updatedAt, b.updatedAt) * 10 +
          comparator(a.createdAt, b.createdAt)),
      SortBy.name => _avatars.sorted((a, b) =>
          comparator(a.name, b.name) * 100 +
          comparator(a.createdAt, b.createdAt) * 10 +
          comparator(a.updatedAt, b.updatedAt)),
    };
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
          _sortAvatars();
        });
      }
      page++;
    }
    setState(() {
      _avatars.removeAll(_avatars.difference(_newAvatars));
      _sortAvatars();
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

  Future<void> _changeAvatar(String id) async {
    if (_confirmWhenChangeAvatar) {
      var avatar = _avatars.firstWhereOrNull((avatar) => avatar.id == id);
      var confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("アバター変更"),
              content: avatar == null
                  ? const Text("?")
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [AvatarView(avatar: avatar)]),
              actions: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text("Yes")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text("No")),
              ],
            );
          });
      if (confirmed != true) {
        return;
      }
    }
    await _doChangeAvatar(id);
  }

  Future<void> _doChangeAvatar(String id) async {
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

  void _setConfirmWhenChangeAvatar(bool? value) async {
    final prefs = await Prefs.instance;
    setState(() {
      _confirmWhenChangeAvatar = value ?? false;
    });
    await prefs.setConfirmWhenChangeAvatar(_confirmWhenChangeAvatar);
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
    Iterable<AvatarWithStat> avatars = _sortedAvatars;
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
    if (_pcPerformanceBlocks.isNotEmpty) {
      avatars = avatars.where((avatar) =>
          avatar.pc.performanceRating == null ||
          !_pcPerformanceBlocks.contains(avatar.pc.performanceRating));
    }
    if (_androidPerformanceBlocks.isNotEmpty) {
      avatars = avatars.where((avatar) =>
          avatar.android.performanceRating == null ||
          !_androidPerformanceBlocks
              .contains(avatar.android.performanceRating));
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
    var filteredAvatars = _filteredAvatars.toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: _avatars.length != _newAvatars.length
            ? Text(
                "${filteredAvatars.length} avatars (fetching ${_newAvatars.length} avatars)")
            : Text(
                '${filteredAvatars.length} avatars',
              ),
        actions: [
          SizedBox(
              width: 200,
              child: CheckboxListTile(
                  title: const Text('アバター変更確認'),
                  value: _confirmWhenChangeAvatar,
                  onChanged: _setConfirmWhenChangeAvatar)),
          DropdownButton<SortBy>(
            value: _sortBy,
            onChanged: (SortBy? value) async {
              setState(() {
                _sortBy = value!;
                _sortAvatars();
              });
              final prefs = await Prefs.instance;
              await prefs.setSortBy(_sortBy);
            },
            items: SortBy.values
                .map((sortBy) => DropdownMenuItem(
                      value: sortBy,
                      child: Text(switch (sortBy) {
                        SortBy.createdAt => "Created At",
                        SortBy.updatedAt => "Updated At",
                        SortBy.name => "Name",
                      }),
                    ))
                .toList(),
          ),
          IconButton(
              onPressed: () async {
                setState(() {
                  _ascending = !_ascending;
                  _sortAvatars();
                });
                final prefs = await Prefs.instance;
                await prefs.setAscending(_ascending);
              },
              icon:
                  Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward)),
          VrcIcons.pc,
          PerformanceRankSelector(
              selected: PerformanceRatings.values
                  .toSet()
                  .difference(_pcPerformanceBlocks),
              onChanged: (p) {
                setState(() {
                  if (_pcPerformanceBlocks.contains(p)) {
                    _pcPerformanceBlocks.remove(p);
                  } else {
                    _pcPerformanceBlocks.add(p);
                  }
                });
              }),
          VrcIcons.android,
          PerformanceRankSelector(
              selected: PerformanceRatings.values
                  .toSet()
                  .difference(_androidPerformanceBlocks),
              onChanged: (p) {
                setState(() {
                  if (_androidPerformanceBlocks.contains(p)) {
                    _androidPerformanceBlocks.remove(p);
                  } else {
                    _androidPerformanceBlocks.add(p);
                  }
                });
              }),
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
          const SizedBox(width: 8),
          SizedBox(
              width: 140,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: "Search",
                ),
                onChanged: (value) => setState(() {
                  _search = value;
                }),
              )),
          const SizedBox(width: 8),
          IconButton(
            iconSize: 36,
            icon: const Icon(Icons.refresh),
            onPressed: _loadAvatars,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Row(
              children: [
                SizedBox(
                    width: 120,
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
                      ],
                    )),
                SizedBox(
                    width: MediaQuery.of(context).size.width - 120,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8,
                          children: _tags
                              .map((tag) => Column(children: [
                                    TagButton(
                                        tag: tag,
                                        selected:
                                            _selectedTagIds.contains(tag.id),
                                        onPressed: () {
                                          setState(() {
                                            if (_selectedTagIds
                                                .contains(tag.id)) {
                                              _selectedTagIds.remove(tag.id);
                                            } else {
                                              _selectedTagIds.add(tag.id);
                                            }
                                          });
                                        }),
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
                        )))
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
            children: filteredAvatars
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
