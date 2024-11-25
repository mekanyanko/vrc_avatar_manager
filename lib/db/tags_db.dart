import 'dart:io';

import 'package:isar/isar.dart';
import 'package:vrc_avatar_manager/db/tag.dart';
import 'package:vrc_avatar_manager/db/tag_avatar.dart';

class TagsDb {
  static TagsDb? _instance;
  const TagsDb._(this.isar);

  final Isar isar;

  static Future<TagsDb> get instance async {
    await Directory(".db").create(recursive: true);
    return _instance ??= TagsDb._(
        await Isar.open([TagSchema, TagAvatarSchema], directory: ".db"));
  }

  Future<List<Tag>> getAll() async {
    return isar.tags.where().findAll();
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

  Future<TagAvatar> findOrCreateTagAvatar(String avatarId) async {
    return await isar.tagAvatars
            .where()
            .filter()
            .avatarIdEqualTo(avatarId)
            .findFirst() ??
        TagAvatar()
      ..avatarId = avatarId;
  }

  Future<void> putLinked(Tag tag, TagAvatar tagAvatar) async {
    await isar.writeTxn(() async {
      print(tag.tagAvatars.map((t) => t.avatarId));
      await isar.tagAvatars.put(tagAvatar);
      await tag.tagAvatars.save();
    });
  }

  Stream<void> watchTags({fireImmediately = false}) {
    return isar.tags.watchLazy(fireImmediately: fireImmediately);
  }

  Stream<void> watchTagAvatars({fireImmediately = false}) {
    return isar.tagAvatars.watchLazy(fireImmediately: fireImmediately);
  }
}
