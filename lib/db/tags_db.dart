import 'dart:io';

import 'package:isar/isar.dart';
import 'package:vrc_avatar_manager/app_dir.dart';
import 'package:vrc_avatar_manager/db/tag.dart';
import 'package:vrc_avatar_manager/db/tag_avatar.dart';
import 'package:vrc_avatar_manager/prefs.dart';

const _intMin = -9223372036854775808;

class TagsDb {
  static final Map<String, TagsDb> _instances = {};
  const TagsDb._({required this.isar, required this.account});

  final Isar isar;
  final String account;

  static Future<TagsDb> instance(String account) async {
    if (_instances.containsKey(account)) {
      return _instances[account]!;
    }
    var dir = "${AppDir.dir}/.tags/$account";
    await Directory(dir).create(recursive: true);
    return _instances[account] = TagsDb._(
        account: account,
        isar: await Isar.open([TagSchema, TagAvatarSchema],
            directory: dir, name: 'tags_$account'));
  }

  Future<List<Tag>> getAll() async {
    return isar.tags.where().sortByOrder().findAll();
  }

  Future<void> put(Tag tag) async {
    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
  }

  Future<void> delete(Tag tag) async {
    await isar.writeTxn(() async {
      await isar.tags.delete(tag.id);
    });
  }

  Future<void> reorder(List<Tag> orderedTags) async {
    await isar.writeTxn(() async {
      final fetchedTags =
          (await isar.tags.getAll(orderedTags.map((e) => e.id).toList()))
              .where((t) => t != null)
              .map((t) => t!)
              .toList();
      if (fetchedTags.length != orderedTags.length) {
        throw Exception("Some tags are missing");
      }
      for (var i = 0; i < fetchedTags.length; i++) {
        var tag = fetchedTags[i];
        if (tag.id != orderedTags[i].id) {
          throw Exception("Tags are not in the same order");
        }
        tag.order = i;
      }
      await isar.tags.putAll(fetchedTags);
    });
  }

  Future<TagAvatar> findOrCreateTagAvatar(String avatarId) async {
    return await isar.tagAvatars
            .where()
            .filter()
            .avatarIdEqualTo(avatarId)
            .findFirst() ??
        TagAvatar()
      ..avatarId = avatarId;
  }

  Future<List<TagAvatar>> findTagAvatars(Iterable<String> avatarIds) {
    return isar.tagAvatars
        .where()
        .filter()
        .anyOf(avatarIds, (q, avatarId) => q.avatarIdEqualTo(avatarId))
        .findAll();
  }

  Future<List<TagAvatar>> findOrCreateTagAvatars(
      Iterable<String> avatarIds) async {
    final tagAvatars = await findTagAvatars(avatarIds);
    final missingAvatarIds = avatarIds.toSet()
      ..removeAll(tagAvatars.map((ta) => ta.avatarId));
    final missingTagAvatars = missingAvatarIds
        .map((avatarId) => TagAvatar()..avatarId = avatarId)
        .toList();
    return [...tagAvatars, ...missingTagAvatars];
  }

  Future<void> putLinked(Tag tag, TagAvatar tagAvatar) async {
    await isar.writeTxn(() async {
      await isar.tagAvatars.put(tagAvatar);
      await tag.tagAvatars.save();
    });
  }

  Future<void> putLinkedAll(Tag tag, List<TagAvatar> tagAvatars) async {
    await isar.writeTxn(() async {
      await isar.tagAvatars.putAll(tagAvatars);
      await tag.tagAvatars.save();
    });
  }

  Stream<void> watchTags({fireImmediately = false}) {
    return isar.tags.watchLazy(fireImmediately: fireImmediately);
  }

  Stream<void> watchTagAvatars({fireImmediately = false}) {
    return isar.tagAvatars.watchLazy(fireImmediately: fireImmediately);
  }

  Future<void> migrate() async {
    final prefs = await Prefs.instance;
    final version = await prefs.tagDbVersion(account);
    if (version < 1) {
      await _migrateTo1();
      await prefs.setTagDbVersion(account, 1);
    }
  }

  Future<void> _migrateTo1() async {
    final count = await isar.tags.where().count();
    for (var i = 0; i < count; i += 50) {
      await isar.writeTxn(() async {
        final tags = await isar.tags.where().offset(i).limit(50).findAll();
        final toPutTags = <Tag>[];
        for (var tag in tags) {
          if (tag.groupId == _intMin) {
            tag.groupId = 0;
            toPutTags.add(tag);
          }
        }
        if (toPutTags.isNotEmpty) await isar.tags.putAll(toPutTags);
      });
    }
  }
}
