import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MasterKeyService {
  static const _keyName = 'master_key';

  final FlutterSecureStorage _storage;

  MasterKeyService(this._storage);

  /// get or create master key
  Future<Uint8List> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);

    if (existing != null) {
      return base64Decode(existing);
    }

    final newKey = _generateKey();

    await _storage.write(key: _keyName, value: base64Encode(newKey));

    return newKey;
  }

  /// generate 256-bit key
  Uint8List _generateKey() {
    final rnd = Random.secure();

    return Uint8List.fromList(List.generate(32, (_) => rnd.nextInt(256)));
  }

  /// optional: delete key (reset app)
  Future<void> deleteKey() async {
    await _storage.delete(key: _keyName);
  }
}
