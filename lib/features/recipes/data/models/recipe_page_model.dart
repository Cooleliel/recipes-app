import 'package:recipes_app/features/recipes/data/models/recipe_model.dart';

/// Une page de recettes renvoyée par l'API, avec le nombre total de
/// recettes (lu dans l'en-tête `Content-Range`, ex. `0-9/50`).
class RecipePageModel {
  const RecipePageModel({required this.recipes, required this.total});

  factory RecipePageModel.fromJson(Map<String, dynamic> json) {
    final Object? items = json['recipes'];
    return RecipePageModel(
      recipes: items is List<dynamic>
          ? items
                .map(
                  (dynamic item) =>
                      RecipeModel.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : <RecipeModel>[],
      total: (json['total'] as num?)?.toInt() ?? unknownTotal,
    );
  }

  /// Total inconnu (en-tête absent).
  static const int unknownTotal = -1;

  final List<RecipeModel> recipes;
  final int total;

  /// Vrai s'il reste des recettes après cette page.
  bool hasMoreAfter({required int offset, required int limit}) {
    if (total == unknownTotal) return recipes.length == limit;
    return offset + recipes.length < total;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'recipes': recipes.map((RecipeModel recipe) => recipe.toJson()).toList(),
    'total': total,
  };
}
