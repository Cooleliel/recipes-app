import 'package:fpdart/fpdart.dart' show Either, Left;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

/// Recherche des recettes par nom.
class SearchRecipesUseCase {
  const SearchRecipesUseCase(this._repository);

  final RecipeRepository _repository;

  static const int minQueryLength = 2;

  Future<Either<Failure, RecipePage>> call(String query) async {
    final String trimmed = query.trim();
    if (trimmed.length < minQueryLength) {
      return const Left<Failure, RecipePage>(
        ValidationFailure(
          'Saisis au moins $minQueryLength caractères pour rechercher.',
        ),
      );
    }
    return _repository.searchRecipes(trimmed);
  }
}
