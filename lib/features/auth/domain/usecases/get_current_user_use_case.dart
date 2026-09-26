import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';
import 'package:recipes_app/features/auth/domain/repositories/auth_repository.dart';

/// Récupère le profil de l'utilisateur connecté (écran Profil).
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call() => _repository.getCurrentUser();
}
