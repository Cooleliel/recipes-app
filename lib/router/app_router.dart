import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:recipes_app/features/auth/presentation/pages/login_page.dart';
import 'package:recipes_app/features/auth/presentation/pages/profile_page.dart';
import 'package:recipes_app/features/auth/presentation/pages/register_page.dart';
import 'package:recipes_app/features/auth/presentation/pages/splash_page.dart';
import 'package:recipes_app/router/app_routes.dart';

/// Le routeur de l'app. Il connaît les pages de toutes les features : c'est
/// pourquoi il vit dans `lib/router/` et non dans `core/`.
///
/// Il écoute [authNotifierProvider] : à chaque changement de session, la
/// redirection est recalculée (connexion → Profil, déconnexion → Login).
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<AuthState> authState =
      ValueNotifier<AuthState>(ref.read(authNotifierProvider));
  ref.listen<AuthState>(
    authNotifierProvider,
    (AuthState? previous, AuthState next) => authState.value = next,
  );

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authState,
    redirect: (BuildContext context, GoRouterState state) =>
        _redirect(authState.value, state.matchedLocation),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) =>
            const ProfilePage(),
      ),
    ],
  );

  ref.onDispose(() {
    authState.dispose();
    router.dispose();
  });
  return router;
});

/// Règles d'accès selon l'état de la session.
String? _redirect(AuthState authState, String location) {
  final bool onAuthPage =
      location == AppRoutes.login || location == AppRoutes.register;
  final bool onSplash = location == AppRoutes.splash;

  return switch (authState) {
    AuthChecking() => onSplash ? null : AppRoutes.splash,
    Unauthenticated() => onAuthPage ? null : AppRoutes.login,
    Authenticated() => onAuthPage || onSplash ? AppRoutes.profile : null,
  };
}