import 'package:isar/isar.dart';
import 'package:vrc_avatar_manager/avatar_with_stat.dart';
import 'package:vrc_avatar_manager/db/tag_avatar.dart';
import 'package:vrc_avatar_manager/db/tag_target.dart';
import 'package:vrc_avatar_manager/db/tag_type.dart';
import 'package:collection/collection.dart';
import 'package:vrc_avatar_manager/db/tags_db.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  late String name;

  int color = 0xFF0066FF;

  @ignore
  int get validColor => color <= 0 ? 0xFF0066FF : color;

  int inactiveColor = 0xFFFFFFFF;

  @ignore
  int get validInactiveColor => inactiveColor <= 0 ? 0xFFFFFFFF : inactiveColor;

  @enumerated
  late TagType type;

  @enumerated
  late TagTarget target;

  late String search;

  bool invert = false;

  bool caseSensitive = false;

  @Backlink(to: 'tags')
  final tagAvatars = IsarLinks<TagAvatar>();

  @ignore
  Set<String> get avatarIds => tagAvatars.map((e) => e.avatarId).toSet();

  void init(String name, TagType type, TagTarget target, String search,
      bool caseSensitive) {
    this.name = name;
    this.type = type;
    this.target = target;
    this.search = search;
    this.caseSensitive = caseSensitive;
  }

  void empty() {
    name = "";
    color = 0xFF0066FF;
    inactiveColor = 0xFFFFFFFF;
    type = TagType.items;
    target = TagTarget.name;
    search = "";
    caseSensitive = false;
  }

  Future<void> toggleAvatar(String avatarId, TagsDb tagsDb) async {
    var tagAvatar =
        tagAvatars.firstWhereOrNull((ta) => ta.avatarId == avatarId);
    if (tagAvatar == null) {
      tagAvatar = await tagsDb.findOrCreateTagAvatar(avatarId);
      tagAvatars.add(tagAvatar);
    } else {
      tagAvatars.remove(tagAvatar);
    }
    await tagsDb.putLinked(this, tagAvatar);
  }

  Iterable<AvatarWithStat> filterAvatars(Iterable<AvatarWithStat> avatars) {
    switch (type) {
      case TagType.items:
        var ids = avatarIds;
        return avatars.where((avatar) => ids.contains(avatar.id));
      case TagType.simple:
        if (search.isEmpty) {
          return [];
        }
        var pick = _genPick();
        var contains = _genSimpleFilter();
        return avatars.where((avatar) => contains(pick(avatar)));
      case TagType.regexp:
        if (search.isEmpty) {
          return [];
        }
        var pick = _genPick();
        var contains = _genRegexpFilter();
        return avatars.where((avatar) => contains(pick(avatar)));
    }
  }

  String Function(AvatarWithStat) _genPick() => switch (target) {
        TagTarget.name => (AvatarWithStat avatar) => avatar.name,
        TagTarget.description => (AvatarWithStat avatar) =>
            avatar.avatar.description,
      };

  bool Function(String) _genSimpleFilter() {
    if (caseSensitive) {
      return invert
          ? (String s) => !s.contains(search)
          : (String s) => s.contains(search);
    } else {
      var lowerSearch = search.toLowerCase();
      return invert
          ? (String s) => !s.toLowerCase().contains(lowerSearch)
          : (String s) => s.toLowerCase().contains(lowerSearch);
    }
  }

  bool Function(String) _genRegexpFilter() {
    var regexp = RegExp(search, caseSensitive: caseSensitive);
    return invert
        ? (String s) => !regexp.hasMatch(s)
        : (String s) => regexp.hasMatch(s);
  }
}
