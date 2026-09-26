import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/di/recipes_providers.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';

/// Recettes d'une catégorie.
final FutureProviderFamily<RecipePage, String> recipesByTagProvider =
    FutureProvider.family<RecipePage, String>(
  (Ref ref, String tag) async {
    final Either<Failure, RecipePage> result =
        await ref.watch(getRecipesByTagUseCaseProvider).call(tag);
    return result.fold<RecipePage>(
      (Failure failure) => throw failure,
      (RecipePage page) => page,
    );
  },
);