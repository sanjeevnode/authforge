import 'package:authforge/src/data/data.dart';
import 'package:authforge/src/domain/domain.dart';
import 'package:authforge/src/ui/cubit/vault_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

/// Service locator. Call configureDependencies() once at startup.
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // --- External ---
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // --- Services ---
  sl.registerLazySingleton(() => AuthLockService());

  // --- Authenticator: data ---
  sl.registerLazySingleton<VaultLocalDataSource>(
    () => VaultLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VaultRepository>(() => VaultRepositoryImpl(sl()));

  // --- Authenticator: usecases ---
  sl.registerLazySingleton(() => GetAccounts(sl()));
  sl.registerLazySingleton(() => AddAccountFromUri(sl()));
  sl.registerLazySingleton(() => AddAccountManual(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));

  // --- Authenticator: cubit (factory — new instance per screen) ---
  sl.registerFactory(
    () => VaultCubit(
      getAccounts: sl(),
      addAccountFromUri: sl(),
      addAccountManual: sl(),
      deleteAccount: sl(),
    ),
  );
}
