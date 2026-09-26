import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';

/// Contrat d'accès aux recettes (API REST + cache hors ligne).
abstract interface class RecipeRepository {
  Future<Either<Failure, RecipePage>> getRecipes({
    required int offset,
    required int limit,
  });

  Future<Either<Failure, RecipePage>> searchRecipes(String query);

  Future<Either<Failure, Recipe>> getRecipeDetail(int id);

  Future<Either<Failure, List<String>>> getTags();

  Future<Either<Failure, RecipePage>> getRecipesByTag(String tag);
}