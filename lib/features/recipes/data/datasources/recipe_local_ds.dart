import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:recipes_app/features/recipes/data/models/recipe_model.dart';
import 'package:recipes_app/features/recipes/data/models/recipe_page_model.dart';

/// Cache Hive des recettes, pour le mode hors ligne.
///
/// Tout est stocké en JSON (String) : pas d'adapter à générer.
abstract interface class RecipeLocalDataSource {
  /// Enregistre une page, et chaque recette individuellement (détail hors ligne).
  Future<void> cachePage({
    required int offset,
    required int limit,
    required RecipePageModel page,
  });

  RecipePageModel? getCachedPage({required int offset, required int limit});

  Future<void> cacheRecipes(List<RecipeModel> recipes);

  RecipeModel? getCachedRecipe(int id);

  /// Toutes les recettes déjà vues (recherche et catégories hors ligne).
  List<RecipeModel> getAllCachedRecipes();

  Future<void> cacheTags(List<String> tags);

  List<String>? getCachedTags();

  Future<void> cacheRecipesByTag(String tag, List<RecipeModel> recipes);

  List<RecipeModel>? getCachedRecipesByTag(String tag);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  RecipeLocalDataSourceImpl(this._box);

  final Box<String> _box;

  static const String _recipePrefix = 'recipe_';
  static const String _tagsKey = 'tags';

  static String _pageKey(int offset, int limit) => 'page_${offset}_$limit';
  static String _recipeKey(int id) => '$_recipePrefix$id';
  static String _tagKey(String tag) => 'tag_$tag';

  @override
  Future<void> cachePage({
    required int offset,
    required int limit,
    required RecipePageModel page,
  }) async {
    await _box.put(_pageKey(offset, limit), jsonEncode(page.toJson()));
    await cacheRecipes(page.recipes);
  }

  @override
  RecipePageModel? getCachedPage({required int offset, required int limit}) {
    final Map<String, dynamic>? json = _readMap(_pageKey(offset, limit));
    return json == null ? null : RecipePageModel.fromJson(json);
  }

  @override
  Future<void> cacheRecipes(List<RecipeModel> recipes) {
    return _box.putAll(<String, String>{
      for (final RecipeModel recipe in recipes)
        _recipeKey(recipe.id): jsonEncode(recipe.toJson()),
    });
  }

  @override
  RecipeModel? getCachedRecipe(int id) {
    final Map<String, dynamic>? json = _readMap(_recipeKey(id));
    return json == null ? null : RecipeModel.fromJson(json);
  }

  @override
  List<RecipeModel> getAllCachedRecipes() {
    final List<RecipeModel> recipes = <RecipeModel>[];
    for (final dynamic key in _box.keys) {
      if (key is String && key.startsWith(_recipePrefix)) {
        final Map<String, dynamic>? json = _readMap(key);
        if (json != null) recipes.add(RecipeModel.fromJson(json));
      }
    }
    recipes.sort((RecipeModel a, RecipeModel b) => a.name.compareTo(b.name));
    return recipes;
  }

  @override
  Future<void> cacheTags(List<String> tags) =>
      _box.put(_tagsKey, jsonEncode(tags));

  @override
  List<String>? getCachedTags() {
    final Object? decoded = _decode(_tagsKey);
    return decoded is List<dynamic>
        ? decoded.map((dynamic tag) => tag.toString()).toList()
        : null;
  }

  @override
  Future<void> cacheRecipesByTag(String tag, List<RecipeModel> recipes) async {
    final List<int> ids =
        recipes.map((RecipeModel recipe) => recipe.id).toList();
    await _box.put(_tagKey(tag), jsonEncode(ids));
    await cacheRecipes(recipes);
  }

  @override
  List<RecipeModel>? getCachedRecipesByTag(String tag) {
    final Object? decoded = _decode(_tagKey(tag));
    if (decoded is! List<dynamic>) return null;
    final List<RecipeModel> recipes = <RecipeModel>[];
    for (final dynamic id in decoded) {
      if (id is int) {
        final RecipeModel? recipe = getCachedRecipe(id);
        if (recipe != null) recipes.add(recipe);
      }
    }
    return recipes;
  }

  Map<String, dynamic>? _readMap(String key) {
    final Object? decoded = _decode(key);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  /// JSON illisible → considéré comme absent du cache.
  Object? _decode(String key) {
    final String? raw = _box.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}