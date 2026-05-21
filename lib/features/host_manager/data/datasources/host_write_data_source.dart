import 'package:drift/drift.dart';
import 'package:shellwayz_app/core/database/app_database.dart';
import 'package:shellwayz_app/core/database/tables/auth_methods.dart';

class HostWriteDataSource {
  final AppDatabase db;

  HostWriteDataSource(this.db);

  // =========================
  // HOSTS
  // =========================
  Future<int> createHost({
    required String label,
    required String host,
    int port = 22,
    int? groupId,
  }) {
    return db
        .into(db.hosts)
        .insert(
          HostsCompanion.insert(
            label: label,
            host: host,
            port: Value(port),
            groupId: Value(groupId),
          ),
        );
  }

  Future<void> updateHost({
    required int id,
    String? label,
    String? host,
    int? port,
    int? groupId,
  }) {
    return (db.update(db.hosts)..where((h) => h.id.equals(id))).write(
      HostsCompanion(
        label: Value.absentIfNull(label),
        host: Value.absentIfNull(host),
        port: Value.absentIfNull(port),
        groupId: Value(groupId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteHost(int hostId) {
    return db.transaction(() async {
      await (db.delete(
        db.hostTags,
      )..where((t) => t.hostId.equals(hostId))).go();

      await (db.delete(
        db.authMethods,
      )..where((a) => a.hostId.equals(hostId))).go();

      await (db.delete(db.hosts)..where((h) => h.id.equals(hostId))).go();
    });
  }

  // =========================
  // AUTH METHODS
  // =========================
  Future<int> createAuthMethod({
    required int hostId,
    required AuthType type,
    required String username,
    required String secret,
    String? passphrase,
    bool isDefault = false,
  }) {
    return db
        .into(db.authMethods)
        .insert(
          AuthMethodsCompanion.insert(
            hostId: hostId,
            type: type,
            username: username,
            secret: secret,
            passphrase: Value(passphrase),
            isDefault: Value(isDefault),
          ),
        );
  }

  Future<void> updateAuthMethod({
    required int authId,
    AuthType? type,
    String? username,
    String? secret,
    String? passphrase,
    bool? isDefault,
  }) {
    return (db.update(db.authMethods)..where((a) => a.id.equals(authId))).write(
      AuthMethodsCompanion(
        type: type != null ? Value(type) : const Value.absent(),
        username: Value.absentIfNull(username),
        secret: Value.absentIfNull(secret),
        passphrase: Value(passphrase),
        isDefault: isDefault != null ? Value(isDefault) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteAuthMethod(int authId) {
    return (db.delete(db.authMethods)..where((a) => a.id.equals(authId))).go();
  }

  // =========================
  // TAGS
  // =========================
  Future<int> createTag({required String name, String? color}) {
    return db
        .into(db.tags)
        .insert(TagsCompanion.insert(name: name, color: Value(color)));
  }

  Future<void> updateTag({required int tagId, String? name, String? color}) {
    return (db.update(db.tags)..where((t) => t.id.equals(tagId))).write(
      TagsCompanion(name: Value.absentIfNull(name), color: Value(color)),
    );
  }

  Future<void> deleteTag(int tagId) {
    return db.transaction(() async {
      await (db.delete(db.hostTags)..where((t) => t.tagId.equals(tagId))).go();

      await (db.delete(db.tags)..where((t) => t.id.equals(tagId))).go();
    });
  }

  Future<void> addTagToHost({required int hostId, required int tagId}) {
    return db
        .into(db.hostTags)
        .insert(HostTagsCompanion.insert(hostId: hostId, tagId: tagId));
  }

  Future<void> removeTagFromHost({required int hostId, required int tagId}) {
    return (db.delete(
      db.hostTags,
    )..where((t) => t.hostId.equals(hostId) & t.tagId.equals(tagId))).go();
  }

  // =========================
  // GROUPS
  // =========================
  Future<int> createGroup({required String name, String? color}) {
    return db
        .into(db.groups)
        .insert(GroupsCompanion.insert(name: name, color: Value(color)));
  }

  Future<void> updateGroup({
    required int groupId,
    String? name,
    String? color,
  }) {
    return (db.update(db.groups)..where((g) => g.id.equals(groupId))).write(
      GroupsCompanion(name: Value.absentIfNull(name), color: Value(color)),
    );
  }

  Future<void> deleteGroup(int groupId) {
    return db.transaction(() async {
      await (db.update(db.hosts)..where((h) => h.groupId.equals(groupId)))
          .write(const HostsCompanion(groupId: Value(null)));

      await (db.delete(db.groups)..where((g) => g.id.equals(groupId))).go();
    });
  }
}
