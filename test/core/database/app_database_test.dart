import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shellwayz_app/core/database/app_database.dart';
import 'package:shellwayz_app/core/database/tables/auth_methods.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  // =========================
  // HOST TESTS
  // =========================

  test('insert host', () async {
    final id = await db
        .into(db.hosts)
        .insert(HostsCompanion.insert(label: 'test', host: '127.0.0.1'));

    final hosts = await db.select(db.hosts).get();

    expect(hosts.length, 1);
    expect(hosts.first.id, id);
    expect(hosts.first.label, 'test');
  });

  test('update host label', () async {
    final id = await db
        .into(db.hosts)
        .insert(HostsCompanion.insert(label: 'old', host: '127.0.0.1'));

    await (db.update(db.hosts)..where((t) => t.id.equals(id))).write(
      HostsCompanion(label: const Value('new')),
    );

    final host = await (db.select(
      db.hosts,
    )..where((t) => t.id.equals(id))).getSingle();

    expect(host.label, 'new');
  });

  test('delete host', () async {
    final id = await db
        .into(db.hosts)
        .insert(HostsCompanion.insert(label: 'to-delete', host: '127.0.0.1'));

    await (db.delete(db.hosts)..where((t) => t.id.equals(id))).go();

    final hosts = await db.select(db.hosts).get();

    expect(hosts.isEmpty, true);
  });

  // =========================
  // GROUP TESTS
  // =========================

  test('assign host to group', () async {
    final groupId = await db
        .into(db.groups)
        .insert(GroupsCompanion.insert(name: 'Servers'));

    final hostId = await db
        .into(db.hosts)
        .insert(
          HostsCompanion.insert(
            label: 'server',
            host: '10.0.0.1',
            groupId: Value(groupId),
          ),
        );

    final host = await (db.select(
      db.hosts,
    )..where((t) => t.id.equals(hostId))).getSingle();

    expect(host.groupId, groupId);
  });

  // =========================
  // AUTH TESTS
  // =========================

  test('insert ssh password auth', () async {
    final hostId = await db
        .into(db.hosts)
        .insert(HostsCompanion.insert(label: 'server', host: '192.168.1.10'));

    await db
        .into(db.authMethods)
        .insert(
          AuthMethodsCompanion.insert(
            hostId: hostId,
            username: 'root',
            secret: 'encrypted_password',
            type: AuthType.password,
          ),
        );

    final auths = await db.select(db.authMethods).get();

    expect(auths.length, 1);
    expect(auths.first.hostId, hostId);
    expect(auths.first.username, 'root');
  });

  test('insert ssh key auth', () async {
    final hostId = await db
        .into(db.hosts)
        .insert(HostsCompanion.insert(label: 'server', host: '192.168.1.10'));

    await db
        .into(db.authMethods)
        .insert(
          AuthMethodsCompanion.insert(
            hostId: hostId,
            username: 'root',
            secret: 'encrypted_private_key',
            passphrase: const Value('mypassword'),
            type: AuthType.sshKey,
          ),
        );

    final auth = await db.select(db.authMethods).getSingle();

    expect(auth.type, AuthType.sshKey);
    expect(auth.passphrase, 'mypassword');
  });

  // =========================
  // RELATION TESTS
  // =========================

  test('host with multiple auth methods', () async {
    final hostId = await db
        .into(db.hosts)
        .insert(HostsCompanion.insert(label: 'multi-auth', host: '1.1.1.1'));

    for (final item in [
      AuthMethodsCompanion.insert(
        hostId: hostId,
        username: 'root',
        secret: 'password1',
        type: AuthType.password,
      ),
      AuthMethodsCompanion.insert(
        hostId: hostId,
        username: 'root',
        secret: 'key1',
        type: AuthType.sshKey,
      ),
    ]) {
      await db.into(db.authMethods).insert(item);
    }

    final auths = await (db.select(
      db.authMethods,
    )..where((t) => t.hostId.equals(hostId))).get();

    expect(auths.length, 2);
  });

  // =========================
  // EDGE CASES
  // =========================

  test('host without auth methods is valid', () async {
    final hostId = await db
        .into(db.hosts)
        .insert(HostsCompanion.insert(label: 'no-auth', host: '8.8.8.8'));

    final auths = await (db.select(
      db.authMethods,
    )..where((t) => t.hostId.equals(hostId))).get();

    expect(auths.isEmpty, true);
  });
}
