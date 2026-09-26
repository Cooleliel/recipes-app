# Changelog

Toutes les évolutions notables du projet sont documentées dans ce fichier.

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/)
et le projet respecte le [versionnage sémantique](https://semver.org/lang/fr/).

## [Non publié]

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

[Non publié]: https://github.com/Cooleliel/recipes-app/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Cooleliel/recipes-app/releases/tag/v1.0.0