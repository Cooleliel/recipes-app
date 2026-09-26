import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';
import 'package:recipes_app/features/auth/domain/repositories/auth_repository.dart';

/// Au démarrage : restaure la session enregistrée, si elle est encore valide.
///
/// Renvoie l'utilisateur, ou `null` s'il faut se reconnecter.
class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() async {
    if (!await _repository.hasSession()) return null;
    final Either<Failure, User> result = await _repository.getCurrentUser();
    return result.fold<User?>((Failure failure) => null, (User user) => user);
  }
}
