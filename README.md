# Recipes App

Recipes App est une application mobile Flutter de recettes de cuisine connectée à un **backend réel Supabase**.
L'utilisateur crée un compte, se connecte avec un **token JWT** renouvelé automatiquement (refresh token),
parcourt 50 recettes chargées depuis une **API REST** (liste paginée avec recherche, détail, catégories)
et consulte son profil. Les données sont **mises en cache avec Hive** : l'application reste utilisable
**hors ligne**. Le code suit une **Clean Architecture organisée par feature** (domain / data / presentation),
avec Riverpod pour l'état et l'injection de dépendances, Dio pour le réseau et fpdart pour une gestion
fonctionnelle des erreurs. Le projet est **testé** (tests unitaires, de widgets et d'intégration), analysé
en mode strict et vérifié à chaque push par une **CI GitHub Actions**.

[![CI](https://github.com/Cooleliel/recipes-app/actions/workflows/ci.yml/badge.svg)](https://github.com/Cooleliel/recipes-app/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.38-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart)
![Riverpod](https://img.shields.io/badge/state-Riverpod%203-2D9CDB)
![Backend](https://img.shields.io/badge/backend-Supabase-3ECF8E?logo=supabase)

> Projet de certification **FlutterFire Summer Camp 2026** (NextFlutter) :
> certification 4 « Appels Réseau et APIs », puis certification 5 « Tests en Flutter »
> (application *production-ready* testée et optimisée).

**English summary —** Flutter recipes app backed by a real Supabase instance (REST via Dio, no SDK):
JWT authentication with automatic refresh-token rotation, 8 screens, Hive offline cache (online-first),
feature-first Clean Architecture, Riverpod 3, fpdart `Either` error handling, unit + widget tests with
mocktail, strict static analysis and a GitHub Actions CI pipeline.

---

## Sommaire

1. [Conformité aux exigences](#1-conformité-aux-exigences)
2. [Captures d'écran](#2-captures-décran)
3. [Fonctionnalités](#3-fonctionnalités)
4. [Architecture](#4-architecture)
5. [Authentification JWT et refresh token](#5-authentification-jwt-et-refresh-token)
6. [API REST : écrans et endpoints](#6-api-rest--écrans-et-endpoints)
7. [Cache local et mode hors ligne](#7-cache-local-et-mode-hors-ligne)
8. [Gestion des erreurs](#8-gestion-des-erreurs)
9. [Tests](#9-tests)
10. [Qualité, CI et versions](#10-qualité-ci-et-versions)
11. [Performance et accessibilité](#11-performance-et-accessibilité)
12. [Installation et lancement](#12-installation-et-lancement)
13. [Stack technique](#13-stack-technique)
14. [Sécurité](#14-sécurité)
15. [Limites connues](#15-limites-connues)

---

## 1. Conformité aux exigences

Chaque exigence renvoie au fichier qui la prouve.

### Certification 5 — « App production-ready testée et optimisée »

| Exigence | État | Preuve |
|---|---|---|
| Au moins 5 écrans | ✅ **8 écrans** | `lib/features/*/presentation/pages/` (splash, connexion, inscription, liste, détail, catégories, recettes d'une catégorie, profil) |
| Au moins 10 tests unitaires | ✅ **13 tests** | `test/auth_repository_impl_test.dart`, `test/recipe_repository_impl_test.dart`, `test/search_recipes_use_case_test.dart` |
| Au moins 5 tests de widgets | ✅ **7 tests** | `test/error_view_widget_test.dart`, `test/recipe_card_widget_test.dart`, `test/offline_banner_widget_test.dart` |
| Au moins 2 tests d'intégration | ⏳ en cours | `integration_test/` |
| Images optimisées et lazy-loadées | ✅ | `RecipeImage` (`cacheWidth`), `ListView.builder`, scroll infini ([section 11](#11-performance-et-accessibilité)) |
| Pas de rebuilds inutiles | ✅ | Constructeurs `const` imposés par le lint `prefer_const_constructors`, état Riverpod ciblé |
| Accessibilité (semantic labels) | ✅ | `Semantics`, `tooltip`, `semanticLabel` ([section 11](#11-performance-et-accessibilité)), testé dans `test/recipe_card_widget_test.dart` |
| Internationalisation FR + EN | ⏳ en cours | — |
| CI GitHub Actions (lint + tests) | ✅ | [`.github/workflows/ci.yml`](.github/workflows/ci.yml) |
| `flutter analyze` sans avertissement | ✅ | [`analysis_options.yaml`](analysis_options.yaml) (mode strict), étape « Analyse statique » de la CI |
| README professionnel + badges | ✅ | Ce fichier |
| CHANGELOG avec au moins 3 versions | 🔄 1 version publiée | [`CHANGELOG.md`](CHANGELOG.md) |
| APK de démonstration | ⏳ prévu | Onglet *Releases* du dépôt |

### Certification 4 — « App connectée avec backend réel »

| Exigence | Preuve |
|---|---|
| Authentification login / register / logout (JWT) | `lib/features/auth/data/datasources/auth_remote_ds.dart`, [section 5](#5-authentification-jwt-et-refresh-token) |
| Au moins 3 écrans de données REST | Liste, Détail, Catégories, Profil : [section 6](#6-api-rest--écrans-et-endpoints) |
| Cache local (Hive) | `lib/features/*/data/datasources/*_local_ds.dart` |
| Mode hors ligne | `lib/features/recipes/data/repositories/recipe_repository_impl.dart`, [section 7](#7-cache-local-et-mode-hors-ligne) |
| Erreurs réseau avec messages utilisateur | `lib/core/network/dio_error_mapper.dart`, `lib/core/errors/`, [section 8](#8-gestion-des-erreurs) |
| Clean Architecture / Feature-First + Repository | [section 4](#4-architecture) |
| Dio + intercepteur (token + refresh) | `lib/core/network/auth_interceptor.dart` |
| Au moins 3 tests unitaires du repository | **12 tests** : `test/auth_repository_impl_test.dart` (5), `test/recipe_repository_impl_test.dart` (7) |

---

## 2. Captures d'écran

| Connexion | Inscription | Liste des recettes |
|:---:|:---:|:---:|
| <img src="docs/screenshots/01_login.png" width="230" alt="Écran de connexion"> | <img src="docs/screenshots/02_register.png" width="230" alt="Écran d'inscription"> | <img src="docs/screenshots/03_recipes.png" width="230" alt="Liste des recettes"> |
| **Recherche** | **Détail** | **Catégories** |
| <img src="docs/screenshots/04_search.png" width="230" alt="Recherche de recettes"> | <img src="docs/screenshots/05_detail.png" width="230" alt="Détail d'une recette"> | <img src="docs/screenshots/06_categories.png" width="230" alt="Catégories"> |
| **Recettes d'une catégorie** | **Profil** | **Mode hors ligne** |
| <img src="docs/screenshots/07_recipes_by_tag.png" width="230" alt="Recettes d'une catégorie"> | <img src="docs/screenshots/08_profile.png" width="230" alt="Profil"> | <img src="docs/screenshots/09_offline.png" width="230" alt="Mode hors ligne"> |

---

## 3. Fonctionnalités

- **Compte utilisateur** : inscription (pseudo facultatif), connexion, déconnexion, session restaurée au redémarrage.
- **Liste des recettes** : scroll infini (pages de 10), recherche par nom avec *debounce* de 400 ms,
  tirer pour rafraîchir, pied de liste avec chargement, erreur ou fin de liste.
- **Détail** : photo qui se replie au défilement (`SliverAppBar`), temps, portions, calories, difficulté,
  ingrédients, étapes numérotées, catégories cliquables.
- **Catégories** : toutes les catégories (vue SQL `recipe_tags`), puis les recettes de chacune.
- **Profil** : données du compte (`GET /auth/v1/user`), date d'inscription et de dernière connexion.
- **Hors ligne** : bandeau « Hors ligne » en temps réel, données servies depuis le cache, recherche locale.
- **Navigation** : 3 onglets (`StatefulShellRoute`) qui conservent leur état ; redirections automatiques
  selon la session (écran de connexion si la session expire).
- **Interface** : Material 3, thème clair/sombre, police Poppins, notifications affichées en haut de l'écran.

---

## 4. Architecture

Clean Architecture **organisée par feature** : chaque feature possède ses propres couches.

```
recipes-app/
├── lib/
│   ├── core/                      # Partagé, ne dépend d'aucune feature
│   │   ├── di/                    # Providers partagés : Dio, stockage, réseau
│   │   ├── errors/                # Exceptions (data), Failures (domain), FailureMapper
│   │   ├── network/               # ApiConstants, DioClient, AuthInterceptor, DioErrorMapper, NetworkInfo
│   │   ├── storage/               # TokenStorage (chiffré), noms des boîtes Hive
│   │   ├── theme/                 # Thème Material 3
│   │   └── widgets/               # ErrorView, EmptyView, OfflineBanner, AppToast
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/            # User, AuthRepository (contrat), use cases, validateurs
│   │   │   ├── data/              # Modèles JSON, datasources remote/local, AuthRepositoryImpl
│   │   │   ├── presentation/      # AuthNotifier, pages (splash, connexion, inscription, profil)
│   │   │   └── di/                # Providers de la feature
│   │   └── recipes/
│   │       ├── domain/            # Recipe, RecipePage, RecipeRepository (contrat), 5 use cases
│   │       ├── data/              # Modèles, datasources remote/local, RecipeRepositoryImpl
│   │       ├── presentation/      # Notifier et providers, 4 pages, widgets
│   │       └── di/
│   ├── router/                    # go_router : routes, redirections selon la session, onglets
│   ├── app.dart
│   └── main.dart
├── test/                          # Tests unitaires et de widgets (à plat)
├── integration_test/              # Tests d'intégration (parcours complets)
├── supabase/                      # schema.sql (table, RLS, vue) et seed.sql (50 recettes)
├── bruno/                         # Collection Bruno de toutes les requêtes de l'app
├── docs/screenshots/              # Captures du README
├── .github/workflows/ci.yml       # CI : analyse + tests + couverture
└── CHANGELOG.md
```

**Règle de dépendance : `presentation → domain ← data`.**

| Couche | Contenu | Dépend de |
|---|---|---|
| **domain** | Entités, contrats de repository (`abstract interface class`), use cases. Dart pur : ni Flutter, ni Dio, ni Hive | rien |
| **data** | Modèles JSON, datasources, implémentations des repositories. Les datasources lancent des `Exception`, le repository renvoie toujours `Either<Failure, T>` | domain, core |
| **presentation** | Pages, widgets, notifiers Riverpod. Ne parle qu'aux use cases | domain |
| **di** | Providers Riverpod qui assemblent les couches, typés avec les contrats (remplaçables par des mocks) | toutes |

Le routeur vit dans `lib/router/` et non dans `core/`, car il importe les pages de toutes les features :
`core/` ne dépend ainsi jamais d'une feature.

---

## 5. Authentification JWT et refresh token

L'authentification utilise **Supabase Auth en REST** (sans SDK) : l'app gère elle-même les tokens.

| Action | Requête | Fichier |
|---|---|---|
| Inscription | `POST /auth/v1/signup` | `lib/features/auth/data/datasources/auth_remote_ds.dart` |
| Connexion | `POST /auth/v1/token?grant_type=password` → `access_token` (JWT) + `refresh_token` | idem |
| Profil | `GET /auth/v1/user` (Bearer JWT) | idem |
| Déconnexion | `POST /auth/v1/logout` + effacement local des tokens | idem + `auth_repository_impl.dart` |
| Renouvellement | `POST /auth/v1/token?grant_type=refresh_token` | `lib/core/network/auth_interceptor.dart` |

Les tokens sont stockés **chiffrés** par `lib/core/storage/token_storage.dart` (`flutter_secure_storage` :
Keystore Android, Keychain iOS).

**Ajout du JWT à chaque requête** — `AuthInterceptor.onRequest` :

```dart
if (options.extra[skipAuth] != true) {
  final String? accessToken = await _tokenStorage.readAccessToken();
  if (accessToken != null) {
    options.headers['Authorization'] = 'Bearer $accessToken';
  }
}
```

**Renouvellement automatique** — `AuthInterceptor.onError`, sur une réponse 401 (PostgREST) ou 403 `bad_jwt` (Auth) :

```dart
final Response<Map<String, dynamic>> response =
    await _plainDio.post<Map<String, dynamic>>(
  ApiConstants.token,
  queryParameters: <String, String>{'grant_type': 'refresh_token'},
  data: <String, String>{'refresh_token': refreshToken},
);
// Le refresh token Supabase est à usage unique : on enregistre la NOUVELLE paire.
await _tokenStorage.saveTokens(
  accessToken: body['access_token'] as String,
  refreshToken: body['refresh_token'] as String,
);
await _retry(request, newAccessToken, handler); // rejoue la requête d'origine
```

```
Requête ──> AuthInterceptor ajoute « Authorization: Bearer <JWT> »
               │
     réponse 401 / 403 bad_jwt
               │
               ├─ une autre requête a déjà renouvelé le token ? ──> rejoue avec le nouveau
               └─ sinon POST /auth/v1/token?grant_type=refresh_token
                        ├─ succès        ──> enregistre la nouvelle paire, rejoue la requête
                        ├─ pas de réseau ──> garde la session, le repository sert le cache
                        └─ refusé        ──> efface les tokens, retour à l'écran de connexion
```

- **`QueuedInterceptor`** : si plusieurs requêtes échouent en même temps, **un seul** refresh a lieu.
- Le refresh et le rejeu passent par un **second client Dio sans intercepteur** (`plainDio`, créé dans
  `lib/core/di/core_providers.dart`) : un échec ne repasse pas par l'intercepteur, donc aucune boucle.
- La fin de session est signalée par `lib/core/network/session_events.dart` ; `AuthNotifier` l'écoute et
  le routeur renvoie vers l'écran de connexion avec le message « Ta session a expiré ».

---

## 6. API REST : écrans et endpoints

Toutes les données viennent de **PostgREST** (API REST générée par Supabase), appelé par
`lib/features/recipes/data/datasources/recipe_remote_ds.dart`.

| Écran | Fichier de la page | Requête REST |
|---|---|---|
| Liste (scroll infini) | `lib/features/recipes/presentation/pages/recipes_page.dart` | `GET /rest/v1/recipes?select=*&order=id.asc&limit=10&offset=0` + en-tête `Prefer: count=exact` (total lu dans `Content-Range`) |
| Recherche | idem | `GET /rest/v1/recipes?name=ilike.*pizza*` |
| Détail | `lib/features/recipes/presentation/pages/recipe_detail_page.dart` | `GET /rest/v1/recipes?id=eq.5&limit=1` |
| Catégories | `lib/features/recipes/presentation/pages/tags_page.dart` | `GET /rest/v1/recipe_tags?select=tag&order=tag.asc` |
| Recettes d'une catégorie | `lib/features/recipes/presentation/pages/recipes_by_tag_page.dart` | `GET /rest/v1/recipes?tags=cs.{"Italian"}` |
| Profil | `lib/features/auth/presentation/pages/profile_page.dart` | `GET /auth/v1/user` |

Les tables sont protégées par la **Row Level Security** (`supabase/schema.sql`) : sans JWT valide,
`/rest/v1/recipes` renvoie une liste vide. La collection [`bruno/`](bruno/) permet de rejouer chaque requête.

---

## 7. Cache local et mode hors ligne

Stratégie **Online-first**, écrite une seule fois dans `RecipeRepositoryImpl._onlineFirst` et appliquée
aux 5 méthodes du repository :

```dart
Future<Either<Failure, T>> _onlineFirst<T>({
  required Future<T> Function() remote,   // API, puis mise à jour du cache
  required T? Function() cache,           // lecture du cache Hive
}) async {
  if (!await _networkInfo.isConnected) {
    return _fromCacheOr<T>(cache, const NetworkFailure());
  }
  try {
    return Right<Failure, T>(await remote());
  } on NetworkException {
    return _fromCacheOr<T>(cache, const NetworkFailure());
  } on Exception catch (error) {
    return Left<Failure, T>(FailureMapper.fromException(error));
  }
}
```

1. En ligne : appel API, puis enregistrement dans Hive.
2. Hors ligne, ou Wi-Fi sans internet (`NetworkException`) : lecture du cache (`isFromCache = true`, bandeau à l'écran).
3. Rien en cache : `NetworkFailure` avec un message clair et un bouton « Réessayer ».

| Clé Hive (`recipes_cache`) | Contenu | Usage hors ligne |
|---|---|---|
| `page_{offset}_{limit}` | une page + le total | liste |
| `recipe_{id}` | une recette | détail et **recherche locale** parmi les recettes déjà vues |
| `tags` | les catégories | écran Catégories |
| `tag_{nom}` | ids des recettes d'une catégorie | recettes d'une catégorie |

Le profil est mis en cache dans la boîte `auth_cache`. Les tokens ne sont **jamais** dans Hive, uniquement
dans le stockage chiffré.

---

## 8. Gestion des erreurs

```
DioException ──DioErrorMapper──> Exception (data) ──FailureMapper──> Failure (domain) ──> message à l'écran
```

- `lib/core/network/dio_error_mapper.dart` traduit les erreurs HTTP et les codes Supabase
  (`invalid_credentials`, `user_already_exists`, `weak_password`…) en messages français.
- `lib/core/errors/failures.dart` : `sealed class Failure` (`NetworkFailure`, `ServerFailure`, `AuthFailure`,
  `NotFoundFailure`, `CacheFailure`, `ValidationFailure`) ; le compilateur vérifie que tous les cas sont traités.
- Affichage : `ErrorView` (message + « Réessayer »), `EmptyView` (aucun résultat), `AppToast` (notification
  en haut de l'écran), bandeau `OfflineBanner`.

---

## 9. Tests

```bash
flutter test               # tests unitaires et de widgets
flutter test --coverage    # + rapport de couverture (coverage/lcov.info)
```

Tous les tests unitaires et de widgets sont **directement dans `test/`**. Les dépendances (datasources,
stockage, réseau) sont remplacées par des mocks **mocktail** ; les tests de widgets remplacent les providers
avec `ProviderScope(overrides: [...])`.

| Fichier | Type | Nb | Ce qui est vérifié |
|---|---|---|---|
| `test/auth_repository_impl_test.dart` | Unitaire (repository) | 5 | Connexion : succès (tokens enregistrés, profil en cache), identifiants refusés, hors ligne sans appel serveur ; déconnexion hors ligne ; profil depuis le cache |
| `test/recipe_repository_impl_test.dart` | Unitaire (repository) | 7 | En ligne + mise en cache, hors ligne, repli sur le cache après erreur réseau, cache vide, session expirée, recette introuvable, détail hors ligne |
| `test/search_recipes_use_case_test.dart` | Unitaire (use case) | 1 | Recherche trop courte refusée sans appel au repository |
| `test/error_view_widget_test.dart` | Widget | 2 | Message + bouton « Réessayer » ; bouton masqué sans action |
| `test/recipe_card_widget_test.dart` | Widget | 3 | Nom, cuisine, note, durée, difficulté ; clic ; **libellés d'accessibilité** |
| `test/offline_banner_widget_test.dart` | Widget | 2 | Bandeau visible hors ligne, invisible en ligne (réseau simulé via `ProviderScope`) |
| **Total** | | **20** | 13 unitaires + 7 widgets |

Les tests d'intégration (`integration_test/`) sont en cours d'ajout.

---

## 10. Qualité, CI et versions

- **Analyse statique stricte** (`analysis_options.yaml`) : `strict-raw-types`, `strict-inference` et des lints
  comme `prefer_const_constructors`, `prefer_final_locals`, `always_declare_return_types`, `avoid_print`.
  Tout le code est **explicitement typé**.
- **CI GitHub Actions** ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) à chaque push et pull request
  sur `main` : `flutter pub get` → `flutter analyze` → `flutter test --coverage` → rapport de couverture
  publié comme artefact.
- **Commits conventionnels** (`feat`, `fix`, `test`, `docs`, `chore`…), un commit par fichier.
- **Versions** : versionnage sémantique, tags Git (`v1.0.0`…) et [`CHANGELOG.md`](CHANGELOG.md) au format
  *Keep a Changelog*.

---

## 11. Performance et accessibilité

**Performance**

- Images décodées à leur taille d'affichage (`cacheWidth` dans
  `lib/features/recipes/presentation/widgets/recipe_image.dart`) : environ 10 fois moins de mémoire que
  les photos d'origine.
- Listes construites à la demande (`ListView.builder`) et **scroll infini** par pages de 10.
- Recherche avec *debounce* (une requête quand l'utilisateur arrête de taper) et réponses obsolètes ignorées.
- Constructeurs `const` partout où c'est possible (imposé par le lint) : ces widgets ne sont jamais reconstruits.
- Un seul refresh de token pour des requêtes simultanées (`QueuedInterceptor`).

**Accessibilité**

- Libellés lus par les lecteurs d'écran : note, durée, difficulté des cartes (`Semantics`), photos
  (`semanticLabel`), titres de section (`Semantics(header: true)`).
- `tooltip` sur tous les boutons-icônes (afficher le mot de passe, effacer la recherche, déconnexion…).
- Messages annoncés automatiquement (`Semantics(liveRegion: true)`) : bandeau hors ligne, notifications.
- Libellés testés dans `test/recipe_card_widget_test.dart`.

---

## 12. Installation et lancement

### Prérequis

- Flutter **3.38** ou plus récent (Dart 3.10)
- Un compte [Supabase](https://supabase.com) (gratuit)
- Windows : activer le **Mode développeur** (`start ms-settings:developers`), requis par les plugins natifs

### 1. Créer le backend Supabase

1. Crée un projet Supabase.
2. **Authentication → Sign In / Providers → Email** : désactive **Confirm email**.
3. **SQL Editor** : exécute [`supabase/schema.sql`](supabase/schema.sql) (table `recipes`, Row Level Security, vue `recipe_tags`).
4. **SQL Editor** : suis les instructions en tête de [`supabase/seed.sql`](supabase/seed.sql) pour importer les
   50 recettes de [DummyJSON](https://dummyjson.com/recipes).
5. Récupère l'**URL du projet** et la clé **publishable** (`sb_publishable_…`)
   (bouton **Connect** du tableau de bord, ou **Project Settings → API Keys**).

> N'utilise **jamais** la clé `secret` / `service_role` dans l'application.

### 2. Configurer l'application

```bash
git clone https://github.com/Cooleliel/recipes-app.git
cd recipes-app
flutter pub get
cp config/env.example.json config/env.json
```

Remplis `config/env.json` (ce fichier est ignoré par Git) :

```json
{
  "SUPABASE_URL": "https://VOTRE-REF.supabase.co",
  "SUPABASE_KEY": "sb_publishable_xxxxxxxxxxxxxxxx"
}
```

### 3. Lancer

```bash
flutter run --dart-define-from-file=config/env.json
```

Dans VS Code, la configuration **recipes_app** de `.vscode/launch.json` passe déjà ce fichier (touche F5).
Sans configuration, l'app affiche un écran qui explique la commande à utiliser.

### 4. Explorer l'API avec Bruno (facultatif)

1. Copie `bruno/.env.example` en `bruno/.env` et remplis-le (ignoré par Git).
2. Ouvre le dossier `bruno/` dans [Bruno](https://www.usebruno.com), choisis l'environnement **Supabase**.
3. Lance `A - Verifications / 01 Connexion`, puis les autres requêtes.

---

## 13. Stack technique

| Besoin | Package | Pourquoi |
|---|---|---|
| HTTP | `dio` | Intercepteurs, `QueuedInterceptor`, options par requête |
| État + injection de dépendances | `flutter_riverpod` 3 | Providers testables et remplaçables (`overrides`) |
| Navigation | `go_router` | Redirections selon la session, `StatefulShellRoute` pour les onglets |
| Erreurs fonctionnelles | `fpdart` | `Either<Failure, T>` : les erreurs font partie du type de retour |
| Cache local | `hive_ce`, `hive_ce_flutter` | **Hive Community Edition**, le fork maintenu de `hive` (dont le développement est arrêté), même API |
| Stockage sécurisé | `flutter_secure_storage` | Tokens chiffrés (Keystore / Keychain) |
| Connectivité | `connectivity_plus` | Détection hors ligne en temps réel |
| Police | `google_fonts` | Poppins |
| Tests | `flutter_test`, `mocktail` | Mocks sans génération de code |

Backend : **Supabase** (PostgreSQL + PostgREST + Auth), appelé **en REST pur avec Dio**, sans le SDK
`supabase_flutter`, pour maîtriser les en-têtes, l'intercepteur et le refresh du token.

---

## 14. Sécurité

- Seule la clé **publishable** est utilisée ; elle est injectée au lancement (`--dart-define-from-file`)
  et n'est pas versionnée (`config/env.json` est ignoré par Git).
- Données protégées par la **Row Level Security** : lecture réservée aux utilisateurs authentifiés.
- Tokens stockés **chiffrés** ; le cache Hive ne contient que des recettes et le profil.
- À la déconnexion, la session est révoquée côté serveur **et** effacée localement, même hors ligne.

## 15. Limites connues

- Les images sont mises en cache en mémoire uniquement : après un redémarrage hors ligne,
  les photos sont remplacées par une icône (les textes restent disponibles).
- La police Poppins est téléchargée au premier lancement ; hors ligne, la police système est utilisée.

---

Réalisé par **Cooeliel** — FlutterFire Summer Camp 2026.
