import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:recipes_app/core/errors/exceptions.dart';
import 'package:recipes_app/core/errors/failure_mapper.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/network/network_info.dart';
import 'package:recipes_app/features/recipes/data/datasources/recipe_local_ds.dart';
import 'package:recipes_app/features/recipes/data/datasources/recipe_remote_ds.dart';
import 'package:recipes_app/features/recipes/data/models/recipe_model.dart';
import 'package:recipes_app/features/recipes/data/models/recipe_page_model.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';
import 'package:recipes_app/features/recipes/domain/repositories/recipe_repository.dart';

/// Stratégie « Online-first » (cours Persistance Locale) :
/// 1. en ligne → API, puis mise à jour du cache ;
/// 2. hors ligne ou erreur réseau → cache local ;
/// 3. rien en cache → `NetworkFailure` avec un message clair.
class RecipeRepositoryImpl implements RecipeRepository {
  RecipeRepositoryImpl({
    required RecipeRemoteDataSource remote,
    required RecipeLocalDataSource local,
    required NetworkInfo networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  final RecipeRemoteDataSource _remote;
  final RecipeLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, RecipePage>> getRecipes({
    required int offset,
    required int limit,
  }) {
    return _onlineFirst<RecipePage>(
      remote: () async {
        final RecipePageModel page = await _remote.getRecipes(
          offset: offset,
          limit: limit,
        );
        await _local.cachePage(offset: offset, limit: limit, page: page);
        return RecipePage(
          recipes: _toEntities(page.recipes),
          hasMore: page.hasMoreAfter(offset: offset, limit: limit),
        );
      },
      cache: () {
        final RecipePageModel? cached = _local.getCachedPage(
          offset: offset,
          limit: limit,
        );
        if (cached == null) return null;
        return RecipePage(
          recipes: _toEntities(cached.recipes),
          hasMore: cached.hasMoreAfter(offset: offset, limit: limit),
          isFromCache: true,
        );
      },
    );
  }

  @override
  Future<Either<Failure, RecipePage>> searchRecipes(String query) {
    return _onlineFirst<RecipePage>(
      remote: () async {
        final List<RecipeModel> recipes = await _remote.searchRecipes(query);
        await _local.cacheRecipes(recipes);
        return RecipePage(recipes: _toEntities(recipes), hasMore: false);
      },
      // Hors ligne : recherche parmi les recettes déjà enregistrées.
      cache: () {
        final String lowerQuery = query.toLowerCase();
        final List<RecipeModel> matches = _local
            .getAllCachedRecipes()
            .where(
              (RecipeModel recipe) =>
                  recipe.name.toLowerCase().contains(lowerQuery),
            )
            .toList();
        return RecipePage(
          recipes: _toEntities(matches),
          hasMore: false,
          isFromCache: true,
        );
      },
    );
  }

  @override
  Future<Either<Failure, Recipe>> getRecipeDetail(int id) {
    return _onlineFirst<Recipe>(
      remote: () async {
        final RecipeModel recipe = await _remote.getRecipeDetail(id);
        await _local.cacheRecipes(<RecipeModel>[recipe]);
        return recipe.toEntity();
      },
      cache: () => _local.getCachedRecipe(id)?.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<String>>> getTags() {
    return _onlineFirst<List<String>>(
      remote: () async {
        final List<String> tags = await _remote.getTags();
        await _local.cacheTags(tags);
        return tags;
      },
      // Hors ligne : tags enregistrés, sinon ceux des recettes déjà vues.
      cache: () {
        final List<String>? cachedTags = _local.getCachedTags();
        if (cachedTags != null) return cachedTags;
        final List<RecipeModel> recipes = _local.getAllCachedRecipes();
        if (recipes.isEmpty) return null;
        final Set<String> tags = <String>{
          for (final RecipeModel recipe in recipes) ...recipe.tags,
        };
        return tags.toList()..sort();
      },
    );
  }

  @override
  Future<Either<Failure, RecipePage>> getRecipesByTag(String tag) {
    return _onlineFirst<RecipePage>(
      remote: () async {
        final List<RecipeModel> recipes = await _remote.getRecipesByTag(tag);
        await _local.cacheRecipesByTag(tag, recipes);
        return RecipePage(recipes: _toEntities(recipes), hasMore: false);
      },
      cache: () {
        final List<RecipeModel> recipes =
            _local.getCachedRecipesByTag(tag) ??
            _local
                .getAllCachedRecipes()
                .where((RecipeModel recipe) => recipe.tags.contains(tag))
                .toList();
        if (recipes.isEmpty) return null;
        return RecipePage(
          recipes: _toEntities(recipes),
          hasMore: false,
          isFromCache: true,
        );
      },
    );
  }

  /// Applique la stratégie Online-first à n'importe quelle donnée [T].
  Future<Either<Failure, T>> _onlineFirst<T>({
    required Future<T> Function() remote,
    required T? Function() cache,
  }) async {
    if (!await _networkInfo.isConnected) {
      return _fromCacheOr<T>(cache, const NetworkFailure());
    }
    try {
      return Right<Failure, T>(await remote());
    } on NetworkException {
      return _fromCacheOr<T>(cache, const NetworkFailure());
    } on Exception catch (error) {
      return Left<Failure, T>(FailureMapper.fromException(error));
    }
  }

  Either<Failure, T> _fromCacheOr<T>(T? Function() cache, Failure failure) {
    final T? cached = cache();
    return cached != null
        ? Right<Failure, T>(cached)
        : Left<Failure, T>(failure);
  }

  static List<Recipe> _toEntities(List<RecipeModel> models) =>
      models.map((RecipeModel model) => model.toEntity()).toList();
}
