import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:mocktail/mocktail.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipes_app/features/recipes/domain/usecases/search_recipes_use_case.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  test('refuse une recherche trop courte sans appeler le repository',
      () async {
    final MockRecipeRepository repository = MockRecipeRepository();
    final SearchRecipesUseCase useCase = SearchRecipesUseCase(repository);

    final Either<Failure, RecipePage> result = await useCase(' a ');

    result.fold<void>(
      (Failure failure) => expect(failure, isA<ValidationFailure>()),
      (RecipePage page) => fail('Une erreur était attendue'),
    );
    verifyZeroInteractions(repository);
  });
}