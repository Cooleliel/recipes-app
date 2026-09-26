import 'package:fpdart/fpdart.dart' show Either, Left;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

/// Charge une page de recettes (scroll infini).
class GetRecipesUseCase {
  const GetRecipesUseCase(this._repository);

  final RecipeRepository _repository;

  static const int maxPageSize = 50;

  Future<Either<Failure, RecipePage>> call({
    required int offset,
    required int limit,
  }) async {
    if (offset < 0 || limit < 1 || limit > maxPageSize) {
      return const Left<Failure, RecipePage>(
        ValidationFailure('Pagination invalide.'),
      );
    }
    return _repository.getRecipes(offset: offset, limit: limit);
  }
}
