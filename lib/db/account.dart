import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  late String name;

  @ignore
  String get accountId => id.toString();
}
