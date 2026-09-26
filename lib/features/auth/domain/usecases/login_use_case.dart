import 'package:fpdart/fpdart.dart' show Either, Left;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';
import 'package:recipes_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:recipes_app/features/auth/domain/validators/credentials_validator.dart';

/// Connecte l'utilisateur après avoir validé ses identifiants.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    final String? error =
        CredentialsValidator.email(email) ??
        CredentialsValidator.password(password);
    if (error != null) return Left<Failure, User>(ValidationFailure(error));
    return _repository.login(email: email.trim(), password: password);
  }
}
