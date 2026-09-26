import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/features/recipes/di/recipes_providers.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';

/// État de l'écran Liste : recettes, pagination, recherche, erreurs.
class RecipesState {
  const RecipesState({
    this.recipes = const <Recipe>[],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.isFromCache = false,
    this.query = '',
    this.failure,
    this.loadMoreFailure,
  });

  final List<Recipe> recipes;

  /// Chargement de la première page (ou d'une recherche).
  final bool isLoading;

  /// Chargement de la page suivante (bas de liste).
  final bool isLoadingMore;

  final bool hasMore;
  final bool isFromCache;
  final String query;

  /// Erreur du chargement principal.
  final Failure? failure;

  /// Erreur du chargement de la page suivante (affichée en bas de liste).
  final Failure? loadMoreFailure;

  bool get isSearching => query.isNotEmpty;

  RecipesState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isFromCache,
    String? query,
    Failure? failure,
    bool clearFailure = false,
    Failure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
  }) {
    return RecipesState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isFromCache: isFromCache ?? this.isFromCache,
      query: query ?? this.query,
      failure: clearFailure ? null : failure ?? this.failure,
      loadMoreFailure: clearLoadMoreFailure
          ? null
          : loadMoreFailure ?? this.loadMoreFailure,
    );
  }
}

final NotifierProvider<RecipesNotifier, RecipesState> recipesNotifierProvider =
    NotifierProvider<RecipesNotifier, RecipesState>(RecipesNotifier.new);

/// Gère la liste paginée (scroll infini) et la recherche.
class RecipesNotifier extends Notifier<RecipesState> {
  static const int pageSize = 10;

  /// Identifie la dernière requête : une réponse plus ancienne (ex. une
  /// recherche dépassée par la frappe suivante) est ignorée.
  int _requestId = 0;

  @override
  RecipesState build() {
    // Premier chargement juste après la construction de l'état.
    unawaited(Future<void>.microtask(loadFirstPage));
    return const RecipesState(isLoading: true);
  }

  Future<void> loadFirstPage() async {
    final int requestId = ++_requestId;
    state = state.copyWith(
      isLoading: true,
      query: '',
      clearFailure: true,
      clearLoadMoreFailure: true,
    );
    final Either<Failure, RecipePage> result = await ref
        .read(getRecipesUseCaseProvider)
        .call(offset: 0, limit: pageSize);
    if (requestId != _requestId) return;

    result.fold<void>(
      (Failure failure) {
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (RecipePage page) {
        state = RecipesState(
          recipes: page.recipes,
          hasMore: page.hasMore,
          isFromCache: page.isFromCache,
        );
      },
    );
  }

  Future<void> loadMore() async {
    final RecipesState current = state;
    if (current.isLoading ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.isSearching) {
      return;
    }
    final int requestId = _requestId;
    state = current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true);

    final Either<Failure, RecipePage> result = await ref
        .read(getRecipesUseCaseProvider)
        .call(offset: current.recipes.length, limit: pageSize);
    if (requestId != _requestId) return;

    result.fold<void>(
      (Failure failure) {
        state = state.copyWith(isLoadingMore: false, loadMoreFailure: failure);
      },
      (RecipePage page) {
        state = state.copyWith(
          recipes: <Recipe>[...state.recipes, ...page.recipes],
          isLoadingMore: false,
          hasMore: page.hasMore,
          isFromCache: state.isFromCache || page.isFromCache,
        );
      },
    );
  }

  Future<void> search(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (state.isSearching || state.failure != null) await loadFirstPage();
      return;
    }
    if (trimmed == state.query && state.failure == null) return;
    await _runSearch(trimmed);
  }

  /// Tirer pour rafraîchir : relance la recherche ou la première page.
  Future<void> refresh() =>
      state.isSearching ? _runSearch(state.query) : loadFirstPage();

  Future<void> _runSearch(String query) async {
    final int requestId = ++_requestId;
    state = state.copyWith(
      isLoading: true,
      query: query,
      clearFailure: true,
      clearLoadMoreFailure: true,
    );
    final Either<Failure, RecipePage> result = await ref
        .read(searchRecipesUseCaseProvider)
        .call(query);
    if (requestId != _requestId) return;

    result.fold<void>(
      (Failure failure) {
        state = state.copyWith(
          isLoading: false,
          recipes: const <Recipe>[],
          failure: failure,
        );
      },
      (RecipePage page) {
        state = RecipesState(
          recipes: page.recipes,
          isFromCache: page.isFromCache,
          query: query,
        );
      },
    );
  }
}
