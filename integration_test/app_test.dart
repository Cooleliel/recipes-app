import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recipes_app/features/auth/presentation/pages/login_page.dart';
import 'package:recipes_app/features/auth/presentation/pages/profile_page.dart';
import 'package:recipes_app/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:recipes_app/main.dart' as app;
import 'package:recipes_app/router/home_shell.dart';

/// Compte de test Supabase, lu dans `config/env.json` au lancement :
/// flutter test integration_test/app_test.dart --dart-define-from-file=config/env.json
const String testEmail = String.fromEnvironment('TEST_EMAIL');
const String testPassword = String.fromEnvironment('TEST_PASSWORD');

void main() {
  // Indispensable : relie les tests à l'appareil (émulateur ou téléphone).
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Sans compte de test configuré, les tests sont ignorés au lieu d'échouer.
  const bool missingAccount = testEmail == '' || testPassword == '';

  group('Parcours de bout en bout (backend Supabase réel)', () {
    testWidgets(
      'mot de passe incorrect : notification d’erreur, on reste sur la connexion',
      (WidgetTester tester) async {
        final AppRobot robot = AppRobot(tester);
        await robot.launchLoggedOut();

        await robot.login(email: testEmail, password: 'mauvais-mot-de-passe');

        // L'erreur du serveur s'affiche dans la notification (icône d'erreur).
        await robot.waitFor(find.byIcon(Icons.error_outline));
        expect(find.byKey(LoginPage.emailFieldKey), findsOneWidget);
        expect(find.byType(HomeShell), findsNothing);
      },
      skip: missingAccount,
    );

    testWidgets(
      'connexion, liste des recettes, détail puis retour à la liste',
      (WidgetTester tester) async {
        final AppRobot robot = AppRobot(tester);
        await robot.launchLoggedOut();

        await robot.login(email: testEmail, password: testPassword);

        // Liste chargée depuis l'API REST.
        await robot.waitFor(find.byType(RecipeCard));
        expect(find.byType(HomeShell), findsOneWidget);

        // Détail de la première recette.
        await tester.tap(find.byType(RecipeCard).first);
        await robot.waitFor(find.byKey(RecipeDetailPage.contentKey));

        // Retour à la liste.
        await tester.pageBack();
        await robot.waitFor(find.byType(RecipeCard));
        expect(find.byKey(RecipeDetailPage.contentKey), findsNothing);
      },
      skip: missingAccount,
    );

    testWidgets(
      'déconnexion depuis le profil : retour à l’écran de connexion',
      (WidgetTester tester) async {
        final AppRobot robot = AppRobot(tester);
        await robot.launchLoggedOut();
        await robot.login(email: testEmail, password: testPassword);
        await robot.waitFor(find.byType(RecipeCard));

        await robot.logout();

        expect(find.byKey(LoginPage.emailFieldKey), findsOneWidget);
        expect(find.byType(HomeShell), findsNothing);
      },
      skip: missingAccount,
    );
  });
}

/// « Page Object » conseillé par le cours : regroupe les interactions avec
/// l'app pour que chaque test se lise comme un scénario.
class AppRobot {
  AppRobot(this.tester);

  final WidgetTester tester;

  /// Attend qu'un widget apparaisse. Les appels réseau sont réels :
  /// `pumpAndSettle` ne suffit pas, il n'attend que les animations.
  Future<void> waitFor(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final DateTime deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Introuvable après ${timeout.inSeconds} s : $finder');
  }

  /// Lance l'app et s'assure de partir de l'écran de connexion
  /// (une session peut rester d'une exécution précédente).
  Future<void> launchLoggedOut() async {
    await app.main();
    await waitFor(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget.key == LoginPage.emailFieldKey || widget is HomeShell,
      ),
    );
    if (find.byType(HomeShell).evaluate().isNotEmpty) {
      await logout();
    }
  }

  Future<void> login({required String email, required String password}) async {
    await tester.enterText(find.byKey(LoginPage.emailFieldKey), email);
    await tester.enterText(find.byKey(LoginPage.passwordFieldKey), password);

    // Ferme le clavier pour que le bouton soit visible, puis le touche.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final Finder submitButton = find.byKey(LoginPage.submitButtonKey);
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();
  }

  Future<void> logout() async {
    await tester.tap(find.byKey(HomeShell.profileTabKey));
    await waitFor(find.byKey(ProfilePage.logoutButtonKey));
    await tester.tap(find.byKey(ProfilePage.logoutButtonKey));
    await waitFor(find.byKey(ProfilePage.confirmLogoutButtonKey));
    await tester.tap(find.byKey(ProfilePage.confirmLogoutButtonKey));
    await waitFor(find.byKey(LoginPage.emailFieldKey));
  }
}