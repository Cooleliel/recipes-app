import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:recipes_app/core/di/core_providers.dart';
import 'package:recipes_app/core/storage/hive_boxes.dart';
import 'package:recipes_app/features/recipes/data/datasources/recipe_local_ds.dart';
import 'package:recipes_app/features/recipes/data/datasources/recipe_remote_ds.dart';
import 'package:recipes_app/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:recipes_app/features/recipes/domain/usecases/get_recipe_detail_use_case.dart';
import 'package:recipes_app/features/recipes/domain/usecases/get_recipes_by_tag_use_case.dart';
import 'package:recipes_app/features/recipes/domain/usecases/get_recipes_use_case.dart';
import 'package:recipes_app/features/recipes/domain/usecases/get_tags_use_case.dart';
import 'package:recipes_app/features/recipes/domain/usecases/search_recipes_use_case.dart';

// Injection des dépendances de la feature recipes.

final Provider<RecipeRemoteDataSource> recipeRemoteDataSourceProvider =
    Provider<RecipeRemoteDataSource>(
      (Ref ref) => RecipeRemoteDataSourceImpl(ref.watch(dioProvider)),
    );

final Provider<RecipeLocalDataSource> recipeLocalDataSourceProvider =
    Provider<RecipeLocalDataSource>(
      (Ref ref) =>
          RecipeLocalDataSourceImpl(Hive.box<String>(HiveBoxes.recipes)),
    );

final Provider<RecipeRepository> recipeRepositoryProvider =
    Provider<RecipeRepository>(
      (Ref ref) => RecipeRepositoryImpl(
        remote: ref.watch(recipeRemoteDataSourceProvider),
        local: ref.watch(recipeLocalDataSourceProvider),
        networkInfo: ref.watch(networkInfoProvider),
      ),
    );

final Provider<GetRecipesUseCase> getRecipesUseCaseProvider =
    Provider<GetRecipesUseCase>(
      (Ref ref) => GetRecipesUseCase(ref.watch(recipeRepositoryProvider)),
    );

final Provider<SearchRecipesUseCase> searchRecipesUseCaseProvider =
    Provider<SearchRecipesUseCase>(
      (Ref ref) => SearchRecipesUseCase(ref.watch(recipeRepositoryProvider)),
    );

final Provider<GetRecipeDetailUseCase> getRecipeDetailUseCaseProvider =
    Provider<GetRecipeDetailUseCase>(
      (Ref ref) => GetRecipeDetailUseCase(ref.watch(recipeRepositoryProvider)),
    );

final Provider<GetTagsUseCase> getTagsUseCaseProvider =
    Provider<GetTagsUseCase>(
      (Ref ref) => GetTagsUseCase(ref.watch(recipeRepositoryProvider)),
    );

final Provider<GetRecipesByTagUseCase> getRecipesByTagUseCaseProvider =
    Provider<GetRecipesByTagUseCase>(
      (Ref ref) => GetRecipesByTagUseCase(ref.watch(recipeRepositoryProvider)),
    );
