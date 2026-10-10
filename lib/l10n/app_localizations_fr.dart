// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Recipes App';

  @override
  String get tabRecipes => 'Recettes';

  @override
  String get tabCategories => 'Catégories';

  @override
  String get tabProfile => 'Profil';

  @override
  String get loginSubtitle => 'Connecte-toi pour accéder aux recettes';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get goToRegister => 'Pas encore de compte ? Créer un compte';

  @override
  String get recipesTitle => 'Recettes';

  @override
  String get searchHint => 'Rechercher une recette…';

  @override
  String get allRecipesShown => 'Toutes les recettes sont affichées.';

  @override
  String get cachedDataNotice =>
      'Données enregistrées : tire vers le bas pour actualiser.';

  @override
  String get retry => 'Réessayer';
}
