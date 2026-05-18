import 'package:drift/drift.dart';

import 'groups.dart';

@DataClassName('Host')
class Hosts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get label => text()();

  TextColumn get host => text()();

  IntColumn get port => integer().withDefault(const Constant(22))();

  IntColumn get groupId => integer().nullable().references(Groups, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().nullable()();
}
