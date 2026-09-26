import 'package:fpdart/fpdart.dart' show Either, Left, Right, Unit, unit;
import 'package:recipes_app/core/errors/exceptions.dart';
import 'package:recipes_app/core/errors/failure_mapper.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/network/network_info.dart';
import 'package:recipes_app/core/storage/token_storage.dart';
import 'package:recipes_app/features/auth/data/datasources/auth_local_ds.dart';
import 'package:recipes_app/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:recipes_app/features/auth/data/models/auth_session_model.dart';
import 'package:recipes_app/features/auth/data/models/user_model.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';
import 'package:recipes_app/features/auth/domain/repositories/auth_repository.dart';

/// Orchestre l'API (Supabase Auth), le cache (Hive) et les tokens chiffrés.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required TokenStorage tokenStorage,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _tokenStorage = tokenStorage,
       _networkInfo = networkInfo;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final TokenStorage _tokenStorage;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left<Failure, User>(
        NetworkFailure('Connexion internet requise pour se connecter.'),
      );
    }
    try {
      final AuthSessionModel session = await _remote.login(
        email: email,
        password: password,
      );
      await _saveSession(session);
      return Right<Failure, User>(session.user.toEntity());
    } on Exception catch (error) {
      return Left<Failure, User>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left<Failure, User>(
        NetworkFailure('Connexion internet requise pour créer un compte.'),
      );
    }
    try {
      final AuthSessionModel? session = await _remote.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (session == null) {
        return const Left<Failure, User>(
          ServerFailure('Compte créé : confirme ton email, puis connecte-toi.'),
        );
      }
      await _saveSession(session);
      return Right<Failure, User>(session.user.toEntity());
    } on Exception catch (error) {
      return Left<Failure, User>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      if (await _networkInfo.isConnected) await _remote.logout();
    } on Exception {
      // Échec côté serveur (réseau, session déjà expirée…) : sans importance,
      // la session locale est effacée dans tous les cas.
    } finally {
      await _tokenStorage.clear();
      await _local.clear();
    }
    return const Right<Failure, Unit>(unit);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (!await _networkInfo.isConnected) {
      return _cachedUserOr(const NetworkFailure());
    }
    try {
      final UserModel user = await _remote.getCurrentUser();
      await _local.cacheUser(user);
      return Right<Failure, User>(user.toEntity());
    } on NetworkException {
      return _cachedUserOr(const NetworkFailure());
    } on Exception catch (error) {
      return Left<Failure, User>(FailureMapper.fromException(error));
    }
  }

  @override
  Future<bool> hasSession() => _tokenStorage.hasSession();

  Future<void> _saveSession(AuthSessionModel session) async {
    await _tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _local.cacheUser(session.user);
  }

  Either<Failure, User> _cachedUserOr(Failure failure) {
    final UserModel? cached = _local.getCachedUser();
    return cached != null
        ? Right<Failure, User>(cached.toEntity())
        : Left<Failure, User>(failure);
  }
}
