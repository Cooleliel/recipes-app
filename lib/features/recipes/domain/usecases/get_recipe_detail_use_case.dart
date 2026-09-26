import 'package:fpdart/fpdart.dart' show Either, Left;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

/// Charge le détail d'une recette.
class GetRecipeDetailUseCase {
  const GetRecipeDetailUseCase(this._repository);

  final RecipeRepository _repository;

  Future<Either<Failure, Recipe>> call(int id) async {
    if (id <= 0) {
      return const Left<Failure, Recipe>(NotFoundFailure('Recette introuvable.'));
    }
    return _repository.getRecipeDetail(id);
  }
}