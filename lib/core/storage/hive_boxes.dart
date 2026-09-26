/// Noms des boîtes Hive utilisées pour le cache hors ligne.
///
/// Les boîtes sont ouvertes une seule fois dans `main.dart`, avant `runApp`.
/// Elles stockent du JSON (String) : aucun adapter à générer.
abstract final class HiveBoxes {
  static const String recipes = 'recipes_cache';
  static const String auth = 'auth_cache';
}