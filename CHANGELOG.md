# Changelog

Toutes les évolutions notables du projet sont documentées dans ce fichier.

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/)
et le projet respecte le [versionnage sémantique](https://semver.org/lang/fr/).

## [Non publié]

## [1.2.0] - 2026-10-10

### Ajouté

- Internationalisation français / anglais avec gen-l10n (`flutter_localizations`, `intl`) :
  `l10n.yaml`, `lib/l10n/app_fr.arb`, `lib/l10n/app_en.arb`. La langue suit celle du téléphone.
- APK de démonstration (`app-release.apk`) publié dans la release GitHub `v1.2.0`.

## [1.1.0] - 2026-10-10

### Ajouté

- 7 tests de widgets : `ErrorView`, `RecipeCard` (dont les libellés d'accessibilité) et
  `OfflineBanner` (réseau simulé avec `ProviderScope(overrides:)`).
- 3 tests d'intégration sur le backend réel (`integration_test/app_test.dart`) : mot de passe incorrect,
  connexion → liste → détail → retour, déconnexion. Page Object `AppRobot`.
- Clés (`Key`) sur les widgets utilisés par les tests (connexion, onglets, profil, détail).
- Rapport de couverture (`flutter test --coverage`) publié par la CI.

### Modifié

- Tous les tests unitaires et de widgets regroupés directement dans `test/`.
- README réécrit : conformité aux exigences, preuves dans le code, tableau des tests.

## [1.0.0] - 2026-09-26

Première version, livrée pour la certification 4 « Appels Réseau et APIs ».

### Ajouté

- Authentification Supabase (inscription, connexion, déconnexion) en REST avec Dio.
- `AuthInterceptor` : ajout du token JWT à chaque requête et renouvellement automatique
  via le refresh token (`QueuedInterceptor`, un seul refresh pour des requêtes simultanées).
- Stockage chiffré des tokens (`flutter_secure_storage`) et restauration de la session au démarrage.
- Liste des recettes avec scroll infini, recherche (debounce) et tirer pour rafraîchir.
- Détail d'une recette, liste des catégories et recettes par catégorie.
- Page Profil alimentée par `GET /auth/v1/user`.
- Cache local Hive et mode hors ligne (stratégie Online-first) avec bandeau « Hors ligne ».
- Messages d'erreur réseau en français et notifications affichées en haut de l'écran.
- Navigation par onglets (`StatefulShellRoute`) et redirections selon l'état de la session.
- Thème Material 3 personnalisé (police Poppins, formes arrondies).
- 13 tests unitaires (repositories et use case) avec `mocktail`.
- Scripts SQL Supabase (`supabase/`), collection Bruno (`bruno/`) et CI GitHub Actions.

[Non publié]: https://github.com/Cooleliel/recipes-app/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/Cooleliel/recipes-app/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/Cooleliel/recipes-app/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Cooleliel/recipes-app/releases/tag/v1.0.0