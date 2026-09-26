/// Configuration de l'API Supabase.
///
/// L'URL et la clé publique sont injectées au lancement :
/// `flutter run --dart-define-from-file=config/env.json`
/// Elles ne sont donc jamais écrites dans le code ni envoyées sur GitHub.
abstract final class ApiConstants {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY');

  /// Faux si l'app a été lancée sans le fichier de configuration.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Authentification (Supabase Auth)
  static const String token = '/auth/v1/token';
  static const String signup = '/auth/v1/signup';
  static const String user = '/auth/v1/user';
  static const String logout = '/auth/v1/logout';

  // Données (PostgREST)
  static const String recipes = '/rest/v1/recipes';
  static const String recipeTags = '/rest/v1/recipe_tags';
}