import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:shellwayz_app/core/security/crypto_service.dart';

void main() {
  late CryptoService crypto;

  setUp(() {
    final key = Uint8List.fromList(List.generate(32, (i) => i + 1));
    crypto = CryptoService(key);
  });

  test('encrypt returns non-empty string', () async {
    final encrypted = await crypto.encrypt('hello');

    expect(encrypted, isNotEmpty);
  });

  test('decrypt(encrypt(text)) returns original text', () async {
    const text = 'hello world 123';

    final encrypted = await crypto.encrypt(text);
    final decrypted = await crypto.decrypt(encrypted);

    expect(decrypted, text);
  });

  test(
    'encrypt produces different output each time (nonce randomness)',
    () async {
      const text = 'same input';

      final e1 = await crypto.encrypt(text);
      final e2 = await crypto.encrypt(text);

      expect(e1, isNot(e2));
    },
  );

  test('decrypt fails with wrong key', () async {
    const text = 'secret';

    final encrypted = await crypto.encrypt(text);

    final wrongKey = Uint8List.fromList(List.generate(32, (i) => i + 2));
    final wrongCrypto = CryptoService(wrongKey);

    expect(
      () async => await wrongCrypto.decrypt(encrypted),
      throwsA(isA<Exception>()),
    );
  });
}
