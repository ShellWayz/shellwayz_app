import 'package:shellwayz_app/core/database/app_database.dart';

class HostSearchResult {
  final Host host;
  final Group? group;
  final List<Tag> tags;
  final List<AuthMethod> authMethods;

  HostSearchResult({
    required this.host,
    required this.group,
    required this.tags,
    required this.authMethods,
  });
}
