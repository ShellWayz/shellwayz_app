import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/auth_methods.dart';
import 'tables/groups.dart';
import 'tables/host_tags.dart';
import 'tables/hosts.dart';
import 'tables/tags.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Hosts, Groups, Tags, HostTags, AuthMethods])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
  },
);

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();

    final file = File(p.join(dir.path, 'shellwayz.sqlite'));

    return NativeDatabase(file);
  });
}
