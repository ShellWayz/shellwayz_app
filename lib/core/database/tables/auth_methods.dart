import 'package:drift/drift.dart';

import 'hosts.dart';

enum AuthType { password, sshKey }

@DataClassName('AuthMethod')
class AuthMethods extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get hostId => integer().references(Hosts, #id)();

  IntColumn get type => intEnum<AuthType>()();

  TextColumn get username => text()();

  TextColumn get secret => text()(); // encrypted password OR PEM

  TextColumn get passphrase => text().nullable()();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
