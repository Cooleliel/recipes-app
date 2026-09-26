/// Chemins de navigation de l'app (une seule source de vérité).
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Onglets de la barre de navigation.
  static const String recipes = '/recipes';
  static const String categories = '/categories';
  static const String profile = '/profile';

  // Sous-route de Catégories : '/categories/recipes?tag=Italian'.
  static const String recipesByTagSegment = 'recipes';
  static const String recipesByTagPath = '$categories/$recipesByTagSegment';

  // Détail, affiché par-dessus la barre de navigation.
  static const String recipeDetailPattern = '/recipe/:id';

  static String recipeDetail(int id) => '/recipe/$id';

  /// Le tag passe en paramètre de requête : `Uri` gère l'encodage
  /// (espaces, accents…).
  static String recipesByTag(String tag) => Uri(
        path: recipesByTagPath,
        queryParameters: <String, String>{'tag': tag},
      ).toString();
}