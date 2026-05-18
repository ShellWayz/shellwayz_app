import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:shellwayz_app/core/security/master_key_service.dart';

void main() {
  late MasterKeyService service;
  late FakeSecureStorage storage;

  setUp(() {
    storage = FakeSecureStorage();
    service = MasterKeyService(storage);
  });

  test('creates master key if not exists', () async {
    final key = await service.getOrCreateKey();

    expect(key.length, 32);
  });

  test('returns same key if already exists', () async {
    final key1 = await service.getOrCreateKey();
    final key2 = await service.getOrCreateKey();

    expect(key1, key2);
  });

  test('persists key in storage', () async {
    final key1 = await service.getOrCreateKey();

    final stored = await storage.read(key: 'master_key');

    expect(stored, isNotNull);
    expect(stored, isNotEmpty);

    final key2 = await service.getOrCreateKey();
    expect(key1, key2);
  });
}

class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    }
  }

  @override
  AndroidOptions get aOptions => throw UnimplementedError();

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    throw UnimplementedError();
  }

  @override
  Map<String, List<ValueChanged<String?>>> get getListeners =>
      throw UnimplementedError();

  @override
  IOSOptions get iOptions => throw UnimplementedError();

  @override
  Future<bool?> isCupertinoProtectedDataAvailable() {
    throw UnimplementedError();
  }

  @override
  LinuxOptions get lOptions => throw UnimplementedError();

  @override
  AppleOptions get mOptions => throw UnimplementedError();

  @override
  Stream<bool>? get onCupertinoProtectedDataAvailabilityChanged =>
      throw UnimplementedError();

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    throw UnimplementedError();
  }

  @override
  void registerListener({
    required String key,
    required ValueChanged<String?> listener,
  }) {}

  @override
  void unregisterAllListeners() {}

  @override
  void unregisterAllListenersForKey({required String key}) {}

  @override
  void unregisterListener({
    required String key,
    required ValueChanged<String?> listener,
  }) {}

  @override
  WindowsOptions get wOptions => throw UnimplementedError();

  @override
  WebOptions get webOptions => throw UnimplementedError();
}
