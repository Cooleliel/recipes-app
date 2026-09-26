import 'package:fpdart/fpdart.dart' show Either, Left;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

/// Charge les recettes d'une catégorie.
class GetRecipesByTagUseCase {
  const GetRecipesByTagUseCase(this._repository);

  final RecipeRepository _repository;

  Future<Either<Failure, RecipePage>> call(String tag) async {
    final String trimmed = tag.trim();
    if (trimmed.isEmpty) {
      return const Left<Failure, RecipePage>(
        ValidationFailure('Catégorie invalide.'),
      );
    }
    return _repository.getRecipesByTag(trimmed);
  }
}
