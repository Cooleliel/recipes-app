import 'package:dio/dio.dart';
import 'package:recipes_app/core/errors/exceptions.dart';
import 'package:recipes_app/core/network/api_constants.dart';
import 'package:recipes_app/core/network/dio_error_mapper.dart';
import 'package:recipes_app/features/recipes/data/models/recipe_model.dart';
import 'package:recipes_app/features/recipes/data/models/recipe_page_model.dart';

/// Appels REST à PostgREST (table `recipes`, vue `recipe_tags`).
///
/// Le token est ajouté par l'intercepteur : sans lui, la RLS renverrait `[]`.
abstract interface class RecipeRemoteDataSource {
  Future<RecipePageModel> getRecipes({required int offset, required int limit});

  Future<List<RecipeModel>> searchRecipes(String query);

  Future<RecipeModel> getRecipeDetail(int id);

  Future<List<String>> getTags();

  Future<List<RecipeModel>> getRecipesByTag(String tag);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  RecipeRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const int _maxResults = 50;

  @override
  Future<RecipePageModel> getRecipes({
    required int offset,
    required int limit,
  }) async {
    try {
      final Response<List<dynamic>> response = await _dio.get<List<dynamic>>(
        ApiConstants.recipes,
        queryParameters: <String, dynamic>{
          'select': '*',
          'order': 'id.asc',
          'limit': limit,
          'offset': offset,
        },
        // Demande le total dans l'en-tête Content-Range (ex. "0-9/50").
        options: Options(headers: <String, dynamic>{'Prefer': 'count=exact'}),
      );
      return RecipePageModel(
        recipes: _parseRecipes(response.data),
        total: _totalFrom(response.headers.value('content-range')),
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query) async {
    // Retire les caractères qui ont un sens dans la syntaxe PostgREST.
    final String safeQuery = query.replaceAll(RegExp(r'[*%,()]'), ' ').trim();
    return _getRecipeList(<String, dynamic>{
      'select': '*',
      'name': 'ilike.*$safeQuery*',
      'order': 'name.asc',
      'limit': _maxResults,
    });
  }

  @override
  Future<RecipeModel> getRecipeDetail(int id) async {
    final List<RecipeModel> recipes = await _getRecipeList(<String, dynamic>{
      'select': '*',
      'id': 'eq.$id',
      'limit': 1,
    });
    if (recipes.isEmpty) throw const NotFoundException('Recette introuvable.');
    return recipes.first;
  }

  @override
  Future<List<String>> getTags() async {
    try {
      final Response<List<dynamic>> response = await _dio.get<List<dynamic>>(
        ApiConstants.recipeTags,
        queryParameters: <String, dynamic>{'select': 'tag', 'order': 'tag.asc'},
      );
      return (response.data ?? <dynamic>[])
          .map((dynamic row) => (row as Map<String, dynamic>)['tag'] as String)
          .toList();
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByTag(String tag) async {
    // Guillemets obligatoires pour les tags avec espace ("Main course").
    final String escapedTag = tag.replaceAll('"', r'\"');
    return _getRecipeList(<String, dynamic>{
      'select': '*',
      'tags': 'cs.{"$escapedTag"}',
      'order': 'name.asc',
      'limit': _maxResults,
    });
  }

  Future<List<RecipeModel>> _getRecipeList(
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      final Response<List<dynamic>> response = await _dio.get<List<dynamic>>(
        ApiConstants.recipes,
        queryParameters: queryParameters,
      );
      return _parseRecipes(response.data);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  static List<RecipeModel> _parseRecipes(List<dynamic>? data) {
    return (data ?? <dynamic>[])
        .map(
          (dynamic json) => RecipeModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// "0-9/50" → 50 ; "*/0" → 0 ; absent → total inconnu.
  static int _totalFrom(String? contentRange) {
    if (contentRange == null) return RecipePageModel.unknownTotal;
    final int slash = contentRange.lastIndexOf('/');
    if (slash == -1) return RecipePageModel.unknownTotal;
    return int.tryParse(contentRange.substring(slash + 1)) ??
        RecipePageModel.unknownTotal;
  }
}