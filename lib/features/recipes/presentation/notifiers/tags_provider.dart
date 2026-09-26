import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/di/recipes_providers.dart';

/// Liste des catégories (vue `recipe_tags`).
final FutureProvider<List<String>> tagsProvider = FutureProvider<List<String>>(
  (Ref ref) async {
    final Either<Failure, List<String>> result =
        await ref.watch(getTagsUseCaseProvider).call();
    return result.fold<List<String>>(
      (Failure failure) => throw failure,
      (List<String> tags) => tags,
    );
  },
);