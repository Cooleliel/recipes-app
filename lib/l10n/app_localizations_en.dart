// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Recipes App';

  @override
  String get tabRecipes => 'Recipes';

  @override
  String get tabCategories => 'Categories';

  @override
  String get tabProfile => 'Profile';

  @override
  String get loginSubtitle => 'Sign in to access the recipes';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get goToRegister => 'No account yet? Create one';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get searchHint => 'Search for a recipe…';

  @override
  String get allRecipesShown => 'All recipes are displayed.';

  @override
  String get cachedDataNotice => 'Saved data: pull down to refresh.';

  @override
  String get retry => 'Retry';
}
