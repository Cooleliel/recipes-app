import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

/// Charge la liste des catégories (tags) de recettes.
class GetTagsUseCase {
  const GetTagsUseCase(this._repository);

  final RecipeRepository _repository;

  Future<Either<Failure, List<String>>> call() => _repository.getTags();
}
