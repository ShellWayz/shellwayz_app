import 'package:drift/drift.dart';
import 'package:shellwayz_app/core/database/app_database.dart';

class HostReadDataSource {
  final AppDatabase db;

  HostReadDataSource(this.db);

  // =========================
  // HOSTS
  // =========================
  Future<List<Host>> getHosts() {
    return db.select(db.hosts).get();
  }

  Future<List<Host>> getHostsByGroup(int groupId) {
    return (db.select(
      db.hosts,
    )..where((tbl) => tbl.groupId.equals(groupId))).get();
  }

  Future<Host?> getHostById(int id) {
    return (db.select(
      db.hosts,
    )..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<List<AuthMethod>> getHostAuths(int hostId) async {
    return (db.select(
      db.authMethods,
    )..where((tbl) => tbl.hostId.equals(hostId))).get();
  }

  // =========================
  // AUTH METHODS
  // =========================
  Future<List<AuthMethod>> getAuths() {
    return db.select(db.authMethods).get();
  }

  Future<AuthMethod?> getAuthById(int authId) {
    return (db.select(
      db.authMethods,
    )..where((a) => a.id.equals(authId))).getSingleOrNull();
  }

  // =========================
  // GROUPS
  // =========================
  Future<List<Group>> getGroups() {
    return db.select(db.groups).get();
  }

  Future<Group?> getGroupById(int groupId) {
    return (db.select(
      db.groups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
  }

  // =========================
  // TAGS
  // =========================
  Future<List<Tag>> getTags() {
    return db.select(db.tags).get();
  }

  Future<Tag?> getTagById(int tagId) {
    return (db.select(
      db.tags,
    )..where((t) => t.id.equals(tagId))).getSingleOrNull();
  }

  // =========================
  // RELATIONS
  // =========================
  Future<List<Tag>> getHostTags(int hostId) async {
    final query = db.select(db.tags).join([
      innerJoin(db.hostTags, db.hostTags.tagId.equalsExp(db.tags.id)),
    ])..where(db.hostTags.hostId.equals(hostId));

    final rows = await query.get();

    return rows.map((r) => r.readTable(db.tags)).toList();
  }

  Future<List<Host>> getTagHosts(int tagId) async {
    final query = db.select(db.hosts).join([
      innerJoin(db.hostTags, db.hostTags.hostId.equalsExp(db.hosts.id)),
    ])..where(db.hostTags.tagId.equals(tagId));

    final rows = await query.get();

    return rows.map((r) => r.readTable(db.hosts)).toList();
  }
}
