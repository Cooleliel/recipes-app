import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/auth/di/auth_providers.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';
import 'package:recipes_app/features/auth/presentation/notifiers/auth_notifier.dart';

/// Profil de l'utilisateur connecté (écran Profil).
///
/// Il se recharge à chaque changement de session, pour ne jamais afficher
/// le profil d'un compte précédent.
final FutureProvider<User> currentUserProvider = FutureProvider<User>((
  Ref ref,
) async {
  final AuthState authState = ref.watch(authNotifierProvider);
  if (authState is! Authenticated) throw const AuthFailure('Non connecté.');

  final Either<Failure, User> result = await ref
      .watch(getCurrentUserUseCaseProvider)
      .call();
  return result.fold<User>(
    (Failure failure) => throw failure,
    (User user) => user,
  );
});
