import 'package:fpdart/fpdart.dart' show Either, Unit;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';

/// Contrat d'accès à l'authentification.
///
/// Le domaine ne connaît que cette interface : l'implémentation (Supabase
/// via Dio, cache Hive, tokens chiffrés) vit dans la couche Data.
abstract interface class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Toujours un succès : la session locale est effacée même hors ligne.
  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<bool> hasSession();
}