import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:recipes_app/core/di/core_providers.dart';
import 'package:recipes_app/core/storage/hive_boxes.dart';
import 'package:recipes_app/features/auth/data/datasources/auth_local_ds.dart';
import 'package:recipes_app/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:recipes_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:recipes_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:recipes_app/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:recipes_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:recipes_app/features/auth/domain/usecases/logout_use_case.dart';
import 'package:recipes_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:recipes_app/features/auth/domain/usecases/restore_session_use_case.dart';

// Injection des dépendances de la feature auth.
// Les providers sont typés avec les contrats abstraits (AuthRepository…) :
// les tests peuvent les remplacer par des mocks.

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>(
      (Ref ref) => AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
    );

final Provider<AuthLocalDataSource> authLocalDataSourceProvider =
    Provider<AuthLocalDataSource>(
      (Ref ref) => AuthLocalDataSourceImpl(Hive.box<String>(HiveBoxes.auth)),
    );

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) => AuthRepositoryImpl(
        remote: ref.watch(authRemoteDataSourceProvider),
        local: ref.watch(authLocalDataSourceProvider),
        tokenStorage: ref.watch(tokenStorageProvider),
        networkInfo: ref.watch(networkInfoProvider),
      ),
    );

final Provider<LoginUseCase> loginUseCaseProvider = Provider<LoginUseCase>(
  (Ref ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<RegisterUseCase> registerUseCaseProvider =
    Provider<RegisterUseCase>(
      (Ref ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
    );

final Provider<LogoutUseCase> logoutUseCaseProvider = Provider<LogoutUseCase>(
  (Ref ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<GetCurrentUserUseCase> getCurrentUserUseCaseProvider =
    Provider<GetCurrentUserUseCase>(
      (Ref ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
    );

final Provider<RestoreSessionUseCase> restoreSessionUseCaseProvider =
    Provider<RestoreSessionUseCase>(
      (Ref ref) => RestoreSessionUseCase(ref.watch(authRepositoryProvider)),
    );
