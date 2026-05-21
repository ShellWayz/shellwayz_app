import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:shellwayz_app/core/database/app_database.dart';
import 'package:shellwayz_app/core/database/tables/auth_methods.dart';
import 'package:shellwayz_app/features/host_manager/data/datasources/host_read_data_source.dart';

void main() {
  late AppDatabase db;
  late HostReadDataSource dataSource;

  late int group1Id;
  late int group2Id;

  late int host1Id;
  late int host2Id;
  late int host3Id;

  late int authMethod1;

  late int tagProdId;
  late int tagDevId;

  setUp(() async {
    db = AppDatabase.memory();
    dataSource = HostReadDataSource(db);

    group1Id = await db
        .into(db.groups)
        .insert(GroupsCompanion.insert(name: 'production'));

    group2Id = await db
        .into(db.groups)
        .insert(GroupsCompanion.insert(name: 'staging'));

    host1Id = await db
        .into(db.hosts)
        .insert(
          HostsCompanion.insert(
            label: 'server-main',
            host: '192.168.1.10',
            groupId: Value(group1Id),
          ),
        );

    host2Id = await db
        .into(db.hosts)
        .insert(
          HostsCompanion.insert(
            label: 'api-server',
            host: '10.0.0.5',
            groupId: Value(group2Id),
          ),
        );

    host3Id = await db
        .into(db.hosts)
        .insert(
          HostsCompanion.insert(
            label: 'random-box',
            host: '127.0.0.1',
            groupId: const Value(null),
          ),
        );

    authMethod1 = await db
        .into(db.authMethods)
        .insert(
          AuthMethodsCompanion.insert(
            hostId: host1Id,
            type: AuthType.password,
            username: 'root-user',
            secret: 'x',
          ),
        );

    await db
        .into(db.authMethods)
        .insert(
          AuthMethodsCompanion.insert(
            hostId: host1Id,
            type: AuthType.sshKey,
            username: 'ubuntu',
            secret: 'y',
          ),
        );

    await db
        .into(db.authMethods)
        .insert(
          AuthMethodsCompanion.insert(
            hostId: host2Id,
            type: AuthType.password,
            username: 'deploy',
            secret: 'z',
          ),
        );

    tagProdId = await db
        .into(db.tags)
        .insert(TagsCompanion.insert(name: 'prod'));

    tagDevId = await db.into(db.tags).insert(TagsCompanion.insert(name: 'dev'));

    await db
        .into(db.hostTags)
        .insert(HostTagsCompanion.insert(hostId: host1Id, tagId: tagProdId));

    await db
        .into(db.hostTags)
        .insert(HostTagsCompanion.insert(hostId: host1Id, tagId: tagDevId));

    await db
        .into(db.hostTags)
        .insert(HostTagsCompanion.insert(hostId: host2Id, tagId: tagDevId));
  });

  tearDown(() async {
    await db.close();
  });

  group('getHosts', () {
    test('returns all hosts', () async {
      final result = await dataSource.getHosts();

      expect(result.length, 3);
    });
  });

  group('getHostsByGroup', () {
    test('returns correct hosts', () async {
      final result = await dataSource.getHostsByGroup(group1Id);
      expect(result.length, 1);
      expect(result.first.label, 'server-main');
    });
  });

  group('getHostById', () {
    test('returns correct host when exists', () async {
      final result = await dataSource.getHostById(host1Id);

      expect(result, isNotNull);
      expect(result!.id, host1Id);
      expect(result.label, 'server-main');
    });

    test('returns null when host does not exist', () async {
      final result = await dataSource.getHostById(99999);

      expect(result, isNull);
    });
  });

  group('getHostAuths', () {
    test('returns all auth methods for host', () async {
      final result = await dataSource.getHostAuths(host1Id);

      expect(result.length, 2);

      final usernames = result.map((e) => e.username).toList();

      expect(usernames, contains('root-user'));
      expect(usernames, contains('ubuntu'));
    });

    test('returns empty when host has no auths', () async {
      final result = await dataSource.getHostAuths(host3Id);

      expect(result, isEmpty);
    });
  });

  group('getAuths', () {
    test('returns all auth methods', () async {
      final result = await dataSource.getAuths();

      expect(result.length, 3);
    });
  });

  group('getAuthById', () {
    test('returns correct auth method', () async {
      final result = await dataSource.getAuthById(authMethod1);

      expect(result, isNotNull);
      expect(result!.username, 'root-user');
    });
  });

  group('getGroups', () {
    test('returns all groups', () async {
      final result = await dataSource.getGroups();

      expect(result.length, 2);

      final names = result.map((e) => e.name).toList();

      expect(names, contains('production'));
      expect(names, contains('staging'));
    });
  });

  group('getGroupById', () {
    test('returns correct group', () async {
      final result = await dataSource.getGroupById(group1Id);

      expect(result, isNotNull);

      expect(result!.name, 'production');
    });
  });

  group('getTags', () {
    test('returns all tags', () async {
      final result = await dataSource.getTags();

      expect(result.length, 2);

      final names = result.map((e) => e.name).toList();

      expect(names, contains('prod'));
      expect(names, contains('dev'));
    });
  });

  group('getTagById', () {
    test('returns correct tag', () async {
      final result = await dataSource.getTagById(tagProdId);

      expect(result, isNotNull);
      expect(result!.name, 'prod');
    });
  });

  group('getHostTags', () {
    test('returns correct tags', () async {
      final result1 = await dataSource.getHostTags(host1Id);
      expect(result1.length, 2);

      final result2 = await dataSource.getHostTags(host2Id);
      expect(result2.length, 1);
    });
  });

  group('getTagHosts', () {
    test('returns correct hosts', () async {
      final result1 = await dataSource.getTagHosts(tagDevId);
      expect(result1.length, 2);

      final result2 = await dataSource.getTagHosts(tagProdId);
      expect(result2.length, 1);
    });
  });
}
