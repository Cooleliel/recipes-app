import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/di/core_providers.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/auth/di/auth_providers.dart';
import 'package:recipes_app/features/auth/domain/entities/user.dart';

/// État de l'authentification. `sealed` : le routeur traite les 3 cas.
sealed class AuthState {
  const AuthState();
}

/// Démarrage : vérification de la session enregistrée.
final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final User user;
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.message});

  /// Raison affichée sur l'écran de connexion (ex. session expirée).
  final String? message;
}

/// Source de vérité de la session, écoutée par le routeur.
final NotifierProvider<AuthNotifier, AuthState> authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // L'intercepteur signale une session expirée (refresh refusé).
    final StreamSubscription<void> subscription = ref
        .watch(sessionEventsProvider)
        .onSessionExpired
        .listen((void event) {
          state = const Unauthenticated(
            message: 'Ta session a expiré. Reconnecte-toi.',
          );
        });
    ref.onDispose(subscription.cancel);

    unawaited(Future<void>.microtask(_restoreSession));
    return const AuthChecking();
  }

  Future<void> _restoreSession() async {
    try {
      final User? user = await ref.read(restoreSessionUseCaseProvider).call();
      state = user != null ? Authenticated(user) : const Unauthenticated();
    } on Exception {
      // Stockage illisible (ex. Keystore réinitialisé) : on repart de zéro
      // plutôt que de rester bloqué sur l'écran de démarrage.
      state = const Unauthenticated();
    }
  }

  /// Renvoie `null` si la connexion a réussi, sinon l'erreur à afficher.
  Future<Failure?> login({
    required String email,
    required String password,
  }) async {
    final Either<Failure, User> result = await ref
        .read(loginUseCaseProvider)
        .call(email: email, password: password);
    return _applyResult(result);
  }

  /// Renvoie `null` si l'inscription a réussi, sinon l'erreur à afficher.
  Future<Failure?> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final Either<Failure, User> result = await ref
        .read(registerUseCaseProvider)
        .call(email: email, password: password, displayName: displayName);
    return _applyResult(result);
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    state = const Unauthenticated();
  }

  Failure? _applyResult(Either<Failure, User> result) {
    return result.fold<Failure?>((Failure failure) => failure, (User user) {
      state = Authenticated(user);
      return null;
    });
  }
}
