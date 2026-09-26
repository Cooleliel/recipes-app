import 'package:fpdart/fpdart.dart' show Either, Unit;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/auth/domain/repositories/auth_repository.dart';

/// Déconnecte l'utilisateur (serveur si possible, et toujours en local).
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call() => _repository.logout();
}
