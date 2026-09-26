import 'package:fpdart/fpdart.dart' show Either, Left;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';
import 'package:recipes_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:recipes_app/features/auth/domain/validators/credentials_validator.dart';

/// Crée un compte puis connecte l'utilisateur.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final String? error = CredentialsValidator.email(email) ??
        CredentialsValidator.password(password) ??
        CredentialsValidator.displayName(displayName);
    if (error != null) return Left<Failure, User>(ValidationFailure(error));

    final String name = displayName?.trim() ?? '';
    return _repository.register(
      email: email.trim(),
      password: password,
      displayName: name.isEmpty ? null : name,
    );
  }
}