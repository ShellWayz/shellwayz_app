import 'package:drift/drift.dart';

import 'hosts.dart';
import 'tags.dart';

@DataClassName('HostTag')
class HostTags extends Table {
  IntColumn get hostId => integer().references(Hosts, #id)();

  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {hostId, tagId};
}
