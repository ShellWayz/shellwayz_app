import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../security/master_key_service.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  if (getIt.isRegistered<FlutterSecureStorage>()) return;

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        resetOnError: true,
        migrateOnAlgorithmChange: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        synchronizable: false,
      ),
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        synchronizable: false,
      ),
    ),
  );

  getIt.registerLazySingleton<MasterKeyService>(
    () => MasterKeyService(getIt<FlutterSecureStorage>()),
  );
}
