import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import 'package:shellwayz_app/core/database/app_database.dart';
import 'package:shellwayz_app/core/database/tables/auth_methods.dart';
import 'package:shellwayz_app/features/host_manager/data/datasources/host_query_data_source.dart';
import 'package:shellwayz_app/features/host_manager/data/models/host_filter.dart';

void main() {
  late AppDatabase db;
  late HostQueryDataSource dataSource;

  late int tagProdId;
  late int tagDevId;

  late int host1Id;
  late int host2Id;
  late int host3Id;

  setUp(() async {
    db = AppDatabase.memory();
    dataSource = HostQueryDataSource(db);

    tagProdId = await db
        .into(db.tags)
        .insert(TagsCompanion.insert(name: 'prod'));

    tagDevId = await db.into(db.tags).insert(TagsCompanion.insert(name: 'dev'));

    final group1Id = await db
        .into(db.groups)
        .insert(GroupsCompanion.insert(name: 'production'));

    final group2Id = await db
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

    await db
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
            hostId: host2Id,
            type: AuthType.password,
            username: 'deploy',
            secret: 'x',
          ),
        );

    await db
        .into(db.authMethods)
        .insert(
          AuthMethodsCompanion.insert(
            hostId: host3Id,
            type: AuthType.password,
            username: 'guest',
            secret: 'x',
          ),
        );

    await db
        .into(db.hostTags)
        .insert(HostTagsCompanion.insert(hostId: host1Id, tagId: tagProdId));

    await db
        .into(db.hostTags)
        .insert(HostTagsCompanion.insert(hostId: host2Id, tagId: tagDevId));
  });

  tearDown(() async {
    await db.close();
  });

  group('searchHost', () {
    test('search by host.label returns correct host', () async {
      final result = await dataSource.searchHost(query: 'server-main');

      expect(result.length, 1);
      expect(result.first.host.id, host1Id);
    });

    test('search by host IP returns correct host', () async {
      final result = await dataSource.searchHost(query: '10.0.0.5');

      expect(result.length, 1);
      expect(result.first.host.id, host2Id);
    });

    test('search by group name returns host', () async {
      final result = await dataSource.searchHost(query: 'production');

      expect(result.length, 1);
      expect(result.first.host.id, host1Id);
    });

    test('search by auth username returns host', () async {
      final result = await dataSource.searchHost(query: 'deploy');

      expect(result.length, 1);
      expect(result.first.host.id, host2Id);
    });

    test('search returns empty when no match', () async {
      final result = await dataSource.searchHost(query: 'not-exists');

      expect(result, isEmpty);
    });

    test('filter with prod tag returns only server-main', () async {
      final result = await dataSource.searchHost(
        filter: HostFilter(tagIds: [tagProdId]),
      );

      expect(result.length, 1);
      expect(result.first.host.id, host1Id);
    });

    test('empty query returns all hosts', () async {
      final result = await dataSource.searchHost();

      expect(result.length, 3);
    });

    test('query + tag filter returns correct host', () async {
      final result = await dataSource.searchHost(
        query: 'server',
        filter: HostFilter(tagIds: [tagProdId]),
      );

      expect(result.length, 1);
      expect(result.first.host.id, host1Id);
    });

    test(
      'wrong tag filters out non-matching hosts but keeps valid ones',
      () async {
        final result = await dataSource.searchHost(
          query: 'server',
          filter: HostFilter(tagIds: [tagDevId]),
        );

        expect(result.length, 1);
        expect(result.first.host.id, host2Id);
      },
    );
  });

  group('searchTag', () {
    test('returns all tags when query is null', () async {
      final result = await dataSource.searchTag();

      expect(result.length, 2);

      final names = result.map((e) => e.name).toList();

      expect(names, contains('prod'));
      expect(names, contains('dev'));
    });

    test('returns all tags when query is empty', () async {
      final result = await dataSource.searchTag(query: '');

      expect(result.length, 2);
    });

    test('searches tags by partial name', () async {
      final result = await dataSource.searchTag(query: 'pro');

      expect(result.length, 1);
      expect(result.first.name, 'prod');
    });

    test('search is case insensitive', () async {
      final result = await dataSource.searchTag(query: 'PROD');

      expect(result.length, 1);
      expect(result.first.name, 'prod');
    });

    test('returns empty when tag does not exist', () async {
      final result = await dataSource.searchTag(query: 'not-found');

      expect(result, isEmpty);
    });

    test('trims query before searching', () async {
      final result = await dataSource.searchTag(query: '  prod  ');

      expect(result.length, 1);
      expect(result.first.name, 'prod');
    });
  });
}
