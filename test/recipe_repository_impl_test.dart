import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:mocktail/mocktail.dart';
import 'package:recipes_app/core/errors/exceptions.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/network/network_info.dart';
import 'package:recipes_app/features/recipes/data/datasources/recipe_local_ds.dart';
import 'package:recipes_app/features/recipes/data/datasources/recipe_remote_ds.dart';
import 'package:recipes_app/features/recipes/data/models/recipe_model.dart';
import 'package:recipes_app/features/recipes/data/models/recipe_page_model.dart';
import 'package:recipes_app/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';

class MockRecipeRemoteDataSource extends Mock
    implements RecipeRemoteDataSource {}

class MockRecipeLocalDataSource extends Mock implements RecipeLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRecipeRemoteDataSource remote;
  late MockRecipeLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late RecipeRepositoryImpl repository;

  const RecipeModel pizza = RecipeModel(
    id: 1,
    name: 'Classic Margherita Pizza',
    ingredients: <String>['Pizza dough', 'Tomato sauce'],
    instructions: <String>['Preheat the oven', 'Bake'],
    prepTimeMinutes: 20,
    cookTimeMinutes: 15,
    servings: 4,
    difficulty: 'Easy',
    cuisine: 'Italian',
    caloriesPerServing: 300,
    tags: <String>['Pizza', 'Italian'],
    mealTypes: <String>['Dinner'],
    imageUrl: 'https://cdn.dummyjson.com/recipe-images/1.webp',
    rating: 4.6,
    reviewCount: 98,
  );
  const RecipePageModel firstPage = RecipePageModel(
    recipes: <RecipeModel>[pizza],
    total: 50,
  );

  setUpAll(() {
    registerFallbackValue(firstPage);
  });

  setUp(() {
    remote = MockRecipeRemoteDataSource();
    local = MockRecipeLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = RecipeRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: networkInfo,
    );
  });

  void givenOnline(bool isOnline) {
    when(
      () => networkInfo.isConnected,
    ).thenAnswer((Invocation invocation) async => isOnline);
  }

  group('getRecipes', () {
    test(
      'en ligne : renvoie les recettes du serveur et les met en cache',
      () async {
        givenOnline(true);
        when(
          () => remote.getRecipes(offset: 0, limit: 10),
        ).thenAnswer((Invocation invocation) async => firstPage);
        when(
          () => local.cachePage(offset: 0, limit: 10, page: firstPage),
        ).thenAnswer((Invocation invocation) async {});

        final Either<Failure, RecipePage> result = await repository.getRecipes(
          offset: 0,
          limit: 10,
        );

        final RecipePage page = result.fold(
          (Failure failure) => fail('Échec inattendu : $failure'),
          (RecipePage value) => value,
        );
        expect(page.recipes.single.name, 'Classic Margherita Pizza');
        expect(page.hasMore, isTrue);
        expect(page.isFromCache, isFalse);
        verify(
          () => local.cachePage(offset: 0, limit: 10, page: firstPage),
        ).called(1);
      },
    );

    test('hors ligne : renvoie le cache sans appeler le serveur', () async {
      givenOnline(false);
      when(
        () => local.getCachedPage(offset: 0, limit: 10),
      ).thenReturn(firstPage);

      final Either<Failure, RecipePage> result = await repository.getRecipes(
        offset: 0,
        limit: 10,
      );

      final RecipePage page = result.fold(
        (Failure failure) => fail('Échec inattendu : $failure'),
        (RecipePage value) => value,
      );
      expect(page.isFromCache, isTrue);
      expect(page.recipes.single.id, 1);
      verifyNever(
        () => remote.getRecipes(
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('erreur réseau en ligne : bascule sur le cache', () async {
      givenOnline(true);
      when(
        () => remote.getRecipes(offset: 0, limit: 10),
      ).thenThrow(const NetworkException());
      when(
        () => local.getCachedPage(offset: 0, limit: 10),
      ).thenReturn(firstPage);

      final Either<Failure, RecipePage> result = await repository.getRecipes(
        offset: 0,
        limit: 10,
      );

      final RecipePage page = result.fold(
        (Failure failure) => fail('Échec inattendu : $failure'),
        (RecipePage value) => value,
      );
      expect(page.isFromCache, isTrue);
    });

    test('hors ligne sans cache : renvoie une NetworkFailure', () async {
      givenOnline(false);
      when(() => local.getCachedPage(offset: 0, limit: 10)).thenReturn(null);

      final Either<Failure, RecipePage> result = await repository.getRecipes(
        offset: 0,
        limit: 10,
      );

      result.fold<void>(
        (Failure failure) => expect(failure, isA<NetworkFailure>()),
        (RecipePage page) => fail('Une erreur était attendue'),
      );
    });

    test('session expirée : renvoie une AuthFailure', () async {
      givenOnline(true);
      when(
        () => remote.getRecipes(offset: 0, limit: 10),
      ).thenThrow(const UnauthorizedException());

      final Either<Failure, RecipePage> result = await repository.getRecipes(
        offset: 0,
        limit: 10,
      );

      result.fold<void>(
        (Failure failure) => expect(failure, isA<AuthFailure>()),
        (RecipePage page) => fail('Une erreur était attendue'),
      );
    });
  });

  group('getRecipeDetail', () {
    test('recette inexistante : renvoie une NotFoundFailure', () async {
      givenOnline(true);
      when(
        () => remote.getRecipeDetail(999),
      ).thenThrow(const NotFoundException());

      final Either<Failure, Recipe> result = await repository.getRecipeDetail(
        999,
      );

      result.fold<void>(
        (Failure failure) => expect(failure, isA<NotFoundFailure>()),
        (Recipe recipe) => fail('Une erreur était attendue'),
      );
    });

    test('hors ligne : renvoie la recette enregistrée', () async {
      givenOnline(false);
      when(() => local.getCachedRecipe(1)).thenReturn(pizza);

      final Either<Failure, Recipe> result = await repository.getRecipeDetail(
        1,
      );

      final Recipe recipe = result.fold(
        (Failure failure) => fail('Échec inattendu : $failure'),
        (Recipe value) => value,
      );
      expect(recipe.name, 'Classic Margherita Pizza');
    });
  });
}
