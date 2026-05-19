import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  final Uint8List _key;

  CryptoService(this._key);

  final _algo = AesGcm.with256bits();

  Future<String> encrypt(String plain) async {
    final nonce = _algo.newNonce();

    final result = await _algo.encrypt(
      utf8.encode(plain),
      secretKey: SecretKey(_key),
      nonce: nonce,
    );

    return base64Encode(result.concatenation());
  }

  Future<String> decrypt(String encrypted) async {
    final bytes = base64Decode(encrypted);

    final box = SecretBox.fromConcatenation(
      bytes,
      nonceLength: 12,
      macLength: 16,
    );

    final decrypted = await _algo.decrypt(box, secretKey: SecretKey(_key));

    return utf8.decode(decrypted);
  }
}
