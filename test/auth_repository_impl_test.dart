import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Either, Unit;
import 'package:mocktail/mocktail.dart';
import 'package:recipes_app/core/errors/exceptions.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/network/network_info.dart';
import 'package:recipes_app/core/storage/token_storage.dart';
import 'package:recipes_app/features/auth/data/datasources/auth_local_ds.dart';
import 'package:recipes_app/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:recipes_app/features/auth/data/models/auth_session_model.dart';
import 'package:recipes_app/features/auth/data/models/user_model.dart';
import 'package:recipes_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late MockTokenStorage tokenStorage;
  late MockNetworkInfo networkInfo;
  late AuthRepositoryImpl repository;

  const UserModel user = UserModel(
    id: 'user-1',
    email: 'test@exemple.com',
    displayName: 'Testeur',
  );
  const AuthSessionModel session = AuthSessionModel(
    accessToken: 'access-1',
    refreshToken: 'refresh-1',
    user: user,
  );

  setUpAll(() {
    registerFallbackValue(user);
  });

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    tokenStorage = MockTokenStorage();
    networkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remote: remote,
      local: local,
      tokenStorage: tokenStorage,
      networkInfo: networkInfo,
    );
    when(
      () => networkInfo.isConnected,
    ).thenAnswer((Invocation invocation) async => true);
    when(
      () => tokenStorage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((Invocation invocation) async {});
    when(
      () => tokenStorage.clear(),
    ).thenAnswer((Invocation invocation) async {});
    when(
      () => local.cacheUser(any()),
    ).thenAnswer((Invocation invocation) async {});
    when(() => local.clear()).thenAnswer((Invocation invocation) async {});
  });

  group('login', () {
    test('succès : enregistre les tokens et met le profil en cache', () async {
      when(
        () => remote.login(email: 'test@exemple.com', password: 'secret123'),
      ).thenAnswer((Invocation invocation) async => session);

      final Either<Failure, User> result = await repository.login(
        email: 'test@exemple.com',
        password: 'secret123',
      );

      final User loggedIn = result.fold(
        (Failure failure) => fail('Échec inattendu : $failure'),
        (User value) => value,
      );
      expect(loggedIn.email, 'test@exemple.com');
      verify(
        () => tokenStorage.saveTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      ).called(1);
      verify(() => local.cacheUser(user)).called(1);
    });

    test(
      'identifiants refusés : message clair et aucun token enregistré',
      () async {
        when(
          () => remote.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const ServerException(
            'Email ou mot de passe incorrect.',
            statusCode: 400,
          ),
        );

        final Either<Failure, User> result = await repository.login(
          email: 'test@exemple.com',
          password: 'mauvais',
        );

        result.fold<void>((Failure failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Email ou mot de passe incorrect.');
        }, (User value) => fail('Une erreur était attendue'));
        verifyNever(
          () => tokenStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        );
      },
    );

    test('hors ligne : NetworkFailure sans appel au serveur', () async {
      when(
        () => networkInfo.isConnected,
      ).thenAnswer((Invocation invocation) async => false);

      final Either<Failure, User> result = await repository.login(
        email: 'test@exemple.com',
        password: 'secret123',
      );

      result.fold<void>(
        (Failure failure) => expect(failure, isA<NetworkFailure>()),
        (User value) => fail('Une erreur était attendue'),
      );
      verifyNever(
        () => remote.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });
  });

  group('logout', () {
    test(
      'efface la session locale même si le serveur est injoignable',
      () async {
        when(() => remote.logout()).thenThrow(const NetworkException());

        final Either<Failure, Unit> result = await repository.logout();

        expect(result.isRight(), isTrue);
        verify(() => tokenStorage.clear()).called(1);
        verify(() => local.clear()).called(1);
      },
    );
  });

  group('getCurrentUser', () {
    test('hors ligne : renvoie le profil enregistré', () async {
      when(
        () => networkInfo.isConnected,
      ).thenAnswer((Invocation invocation) async => false);
      when(() => local.getCachedUser()).thenReturn(user);

      final Either<Failure, User> result = await repository.getCurrentUser();

      final User cached = result.fold(
        (Failure failure) => fail('Échec inattendu : $failure'),
        (User value) => value,
      );
      expect(cached.displayName, 'Testeur');
      verifyNever(() => remote.getCurrentUser());
    });
  });
}
