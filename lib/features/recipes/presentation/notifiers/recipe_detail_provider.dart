import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/di/recipes_providers.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';

/// Détail d'une recette, identifiée par son id.
final FutureProviderFamily<Recipe, int> recipeDetailProvider =
    FutureProvider.family<Recipe, int>((Ref ref, int id) async {
      final Either<Failure, Recipe> result = await ref
          .watch(getRecipeDetailUseCaseProvider)
          .call(id);
      return result.fold<Recipe>(
        (Failure failure) => throw failure,
        (Recipe recipe) => recipe,
      );
    });
