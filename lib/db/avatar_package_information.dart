import 'package:isar/isar.dart';

part 'avatar_package_information.g.dart';

@collection
class AvatarPackageInformation {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String unityPackageId;
  late int size;
}
