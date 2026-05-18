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
  AppDatabase(super.e);

  // =========================
  // Production DB (file system)
  // =========================
  factory AppDatabase.file({String name = 'shellwayz.sqlite'}) {
    return AppDatabase(_openConnection(name));
  }

  // =========================
  // Test / Memory DB
  // =========================
  factory AppDatabase.memory() {
    return AppDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 1;
}

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
  },
);

LazyDatabase _openConnection(String name) {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();

    final file = File(p.join(dir.path, name));

    return NativeDatabase(file);
  });
}
