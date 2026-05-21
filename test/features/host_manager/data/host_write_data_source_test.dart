import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:shellwayz_app/core/database/app_database.dart';
import 'package:shellwayz_app/core/database/tables/auth_methods.dart';
import 'package:shellwayz_app/features/host_manager/data/datasources/host_write_data_source.dart';

void main() {
  late AppDatabase db;
  late HostWriteDataSource dataSource;

  late int groupId;
  late int hostId;
  late int tagId;
  late int authId;

  setUp(() async {
    db = AppDatabase.memory();
    dataSource = HostWriteDataSource(db);

    groupId = await db
        .into(db.groups)
        .insert(GroupsCompanion.insert(name: 'production'));

    hostId = await db
        .into(db.hosts)
        .insert(
          HostsCompanion.insert(
            label: 'server-main',
            host: '192.168.1.10',
            groupId: Value(groupId),
          ),
        );

    tagId = await db.into(db.tags).insert(TagsCompanion.insert(name: 'prod'));

    authId = await db
        .into(db.authMethods)
        .insert(
          AuthMethodsCompanion.insert(
            hostId: hostId,
            type: AuthType.password,
            username: 'root',
            secret: 'secret',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('hosts', () {
    test('createHost inserts host correctly', () async {
      final id = await dataSource.createHost(
        label: 'new-host',
        host: '1.1.1.1',
      );

      final host = await (db.select(
        db.hosts,
      )..where((h) => h.id.equals(id))).getSingle();

      expect(host.label, 'new-host');
      expect(host.host, '1.1.1.1');
      expect(host.port, 22);
    });

    test('updateHost updates host fields', () async {
      await dataSource.updateHost(
        id: hostId,
        label: 'updated-host',
        port: 2222,
      );

      final host = await (db.select(
        db.hosts,
      )..where((h) => h.id.equals(hostId))).getSingle();

      expect(host.label, 'updated-host');
      expect(host.port, 2222);
      expect(host.updatedAt, isNotNull);
    });

    test('deleteHost deletes host and relations', () async {
      await dataSource.addTagToHost(hostId: hostId, tagId: tagId);

      await dataSource.deleteHost(hostId);

      final hosts = await db.select(db.hosts).get();
      final auths = await db.select(db.authMethods).get();
      final hostTags = await db.select(db.hostTags).get();

      expect(hosts.any((h) => h.id == hostId), false);
      expect(auths.any((a) => a.hostId == hostId), false);
      expect(hostTags.any((t) => t.hostId == hostId), false);
    });
  });

  group('auth methods', () {
    test('createAuthMethod inserts auth correctly', () async {
      final id = await dataSource.createAuthMethod(
        hostId: hostId,
        type: AuthType.sshKey,
        username: 'ubuntu',
        secret: 'pem',
      );

      final auth = await (db.select(
        db.authMethods,
      )..where((a) => a.id.equals(id))).getSingle();

      expect(auth.username, 'ubuntu');
      expect(auth.type, AuthType.sshKey);
    });

    test('updateAuthMethod updates auth fields', () async {
      await dataSource.updateAuthMethod(
        authId: authId,
        username: 'deploy',
        secret: 'new-secret',
        isDefault: true,
      );

      final auth = await (db.select(
        db.authMethods,
      )..where((a) => a.id.equals(authId))).getSingle();

      expect(auth.username, 'deploy');
      expect(auth.secret, 'new-secret');
      expect(auth.isDefault, true);
    });

    test('deleteAuthMethod removes auth', () async {
      await dataSource.deleteAuthMethod(authId);

      final auths = await db.select(db.authMethods).get();

      expect(auths.any((a) => a.id == authId), false);
    });
  });

  group('tags', () {
    test('createTag inserts tag correctly', () async {
      final id = await dataSource.createTag(name: 'backend', color: '#ff0000');

      final tag = await (db.select(
        db.tags,
      )..where((t) => t.id.equals(id))).getSingle();

      expect(tag.name, 'backend');
      expect(tag.color, '#ff0000');
    });

    test('updateTag updates tag fields', () async {
      await dataSource.updateTag(
        tagId: tagId,
        name: 'production',
        color: '#00ff00',
      );

      final tag = await (db.select(
        db.tags,
      )..where((t) => t.id.equals(tagId))).getSingle();

      expect(tag.name, 'production');
      expect(tag.color, '#00ff00');
    });

    test('deleteTag deletes tag and host relations', () async {
      await dataSource.addTagToHost(hostId: hostId, tagId: tagId);

      await dataSource.deleteTag(tagId);

      final tags = await db.select(db.tags).get();
      final hostTags = await db.select(db.hostTags).get();

      expect(tags.any((t) => t.id == tagId), false);
      expect(hostTags.any((t) => t.tagId == tagId), false);
    });

    test('addTagToHost creates relation', () async {
      await dataSource.addTagToHost(hostId: hostId, tagId: tagId);

      final relations = await db.select(db.hostTags).get();

      expect(
        relations.any((r) => r.hostId == hostId && r.tagId == tagId),
        true,
      );
    });

    test('removeTagFromHost removes relation', () async {
      await dataSource.addTagToHost(hostId: hostId, tagId: tagId);

      await dataSource.removeTagFromHost(hostId: hostId, tagId: tagId);

      final relations = await db.select(db.hostTags).get();

      expect(
        relations.any((r) => r.hostId == hostId && r.tagId == tagId),
        false,
      );
    });
  });

  group('groups', () {
    test('createGroup inserts group correctly', () async {
      final id = await dataSource.createGroup(
        name: 'staging',
        color: '#123456',
      );

      final group = await (db.select(
        db.groups,
      )..where((g) => g.id.equals(id))).getSingle();

      expect(group.name, 'staging');
      expect(group.color, '#123456');
    });

    test('updateGroup updates group fields', () async {
      await dataSource.updateGroup(
        groupId: groupId,
        name: 'prod',
        color: '#ffffff',
      );

      final group = await (db.select(
        db.groups,
      )..where((g) => g.id.equals(groupId))).getSingle();

      expect(group.name, 'prod');
      expect(group.color, '#ffffff');
    });

    test('deleteGroup removes group and unassigns hosts', () async {
      await dataSource.deleteGroup(groupId);

      final groups = await db.select(db.groups).get();

      final host = await (db.select(
        db.hosts,
      )..where((h) => h.id.equals(hostId))).getSingle();

      expect(groups.any((g) => g.id == groupId), false);
      expect(host.groupId, isNull);
    });
  });
}
