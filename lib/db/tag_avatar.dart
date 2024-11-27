import 'package:isar/isar.dart';
import 'package:vrc_avatar_manager/db/tag.dart';

part 'tag_avatar.g.dart';

@collection
class TagAvatar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String avatarId;

  final tags = IsarLinks<Tag>();
}
