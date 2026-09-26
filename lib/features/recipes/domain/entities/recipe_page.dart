import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';

/// Une liste de recettes, telle qu'affichée à l'écran.
class RecipePage {
  const RecipePage({
    required this.recipes,
    required this.hasMore,
    this.isFromCache = false,
  });

  final List<Recipe> recipes;

  /// Vrai s'il reste des recettes à charger (scroll infini).
  final bool hasMore;

  /// Vrai si les données viennent du cache local (mode hors ligne).
  final bool isFromCache;
}