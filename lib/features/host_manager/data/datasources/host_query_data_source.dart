import 'package:drift/drift.dart';
import 'package:shellwayz_app/core/database/app_database.dart';
import 'package:shellwayz_app/features/host_manager/data/models/host_filter.dart';
import 'package:shellwayz_app/features/host_manager/data/models/host_search_result.dart';

class HostQueryDataSource {
  final AppDatabase db;

  HostQueryDataSource(this.db);

  /// Searches hosts using a text query across host fields, group name, and auth usernames,
  /// and applies optional tag filters. Returns hosts with their related group, auth methods, and tags.
  Future<List<HostSearchResult>> searchHost({
    String? query,
    HostFilter? filter,
  }) async {
    final q = query?.trim().toLowerCase();

    final hosts = await db.select(db.hosts).get();

    if (hosts.isEmpty) return [];

    final hostIds = hosts.map((e) => e.id).toList();

    final groups = await db.select(db.groups).get();
    final auths = await (db.select(
      db.authMethods,
    )..where((a) => a.hostId.isIn(hostIds))).get();

    final hostTags = await (db.select(
      db.hostTags,
    )..where((ht) => ht.hostId.isIn(hostIds))).get();

    final tags = await db.select(db.tags).get();

    final groupMap = {for (final g in groups) g.id: g};

    final Map<int, List<AuthMethod>> authMap = {};
    for (final a in auths) {
      authMap.putIfAbsent(a.hostId, () => []).add(a);
    }

    final tagMap = {for (final t in tags) t.id: t};

    final Map<int, List<Tag>> hostTagMap = {};
    for (final ht in hostTags) {
      final tag = tagMap[ht.tagId];
      if (tag != null) {
        hostTagMap.putIfAbsent(ht.hostId, () => []).add(tag);
      }
    }

    if (filter?.hasTags == true) {
      final allowedHostIds = hostTags
          .where((ht) => filter!.tagIds!.contains(ht.tagId))
          .map((e) => e.hostId)
          .toSet();

      hosts.removeWhere((h) => !allowedHostIds.contains(h.id));
    }

    final result = <HostSearchResult>[];

    for (final host in hosts) {
      final group = groupMap[host.groupId];
      final hostAuths = authMap[host.id] ?? [];
      final hostTagsList = hostTagMap[host.id] ?? [];

      final matches = q == null || q.isEmpty
          ? true
          : (host.label.toLowerCase().contains(q) ||
                host.host.toLowerCase().contains(q) ||
                (group?.name.toLowerCase().contains(q) ?? false) ||
                hostAuths.any((a) => a.username.toLowerCase().contains(q)));

      if (!matches) continue;

      result.add(
        HostSearchResult(
          host: host,
          group: group,
          tags: hostTagsList,
          authMethods: hostAuths,
        ),
      );
    }

    return result;
  }

  /// Searches tags using a text query across tags names
  Future<List<Tag>> searchTag({String? query}) {
    final q = query?.trim().toLowerCase();

    if (q == null || q.isEmpty) {
      return db.select(db.tags).get();
    }

    return (db.select(
      db.tags,
    )..where((tbl) => tbl.name.lower().like('%$q%'))).get();
  }
}
