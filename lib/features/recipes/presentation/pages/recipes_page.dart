import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/widgets/app_toast.dart';
import 'package:recipes_app/core/widgets/empty_view.dart';
import 'package:recipes_app/core/widgets/error_view.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/presentation/notifiers/recipes_notifier.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:recipes_app/router/app_routes.dart';

/// Écran Liste : recherche + scroll infini + tirer pour rafraîchir.
class RecipesPage extends ConsumerStatefulWidget {
  const RecipesPage({super.key});

  @override
  ConsumerState<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends ConsumerState<RecipesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Charge la page suivante à 300 px du bas de la liste.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 300) return;
    final RecipesState current = ref.read(recipesNotifierProvider);
    if (current.loadMoreFailure == null) {
      unawaited(ref.read(recipesNotifierProvider.notifier).loadMore());
    }
  }

  /// Recherche lancée 400 ms après la dernière frappe (debounce).
  void _onSearchChanged(String value) {
    setState(() {}); // Affiche ou masque le bouton « Effacer ».
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(ref.read(recipesNotifierProvider.notifier).search(value));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final RecipesState state = ref.watch(recipesNotifierProvider);

    // Erreur alors que des recettes sont déjà affichées : simple toast.
    ref.listen<RecipesState>(
      recipesNotifierProvider,
      (RecipesState? previous, RecipesState next) {
        final Failure? failure = next.failure;
        if (failure != null &&
            next.recipes.isNotEmpty &&
            failure != previous?.failure) {
          AppToast.show(context, failure.message, type: ToastType.error);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recettes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Rechercher une recette…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Effacer la recherche',
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (state.isLoading && state.recipes.isNotEmpty)
            const LinearProgressIndicator(),
          if (state.isFromCache) const _CacheNotice(),
          Expanded(
            child: _RecipesBody(
              state: state,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipesBody extends ConsumerWidget {
  const _RecipesBody({required this.state, required this.scrollController});

  final RecipesState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RecipesNotifier notifier = ref.read(recipesNotifierProvider.notifier);
    final Failure? failure = state.failure;

    if (state.isLoading && state.recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (failure != null && state.recipes.isEmpty) {
      return failure is ValidationFailure
          ? EmptyView(message: failure.message, icon: Icons.keyboard_outlined)
          : ErrorView(message: failure.message, onRetry: notifier.refresh);
    }
    if (state.recipes.isEmpty) {
      return EmptyView(
        message: state.isSearching
            ? 'Aucune recette pour « ${state.query} ».'
            : 'Aucune recette disponible.',
        icon: Icons.search_off,
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.recipes.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == state.recipes.length) {
            return _ListFooter(state: state, onRetry: notifier.loadMore);
          }
          final Recipe recipe = state.recipes[index];
          return RecipeCard(
            recipe: recipe,
            onTap: () => context.push(AppRoutes.recipeDetail(recipe.id)),
          );
        },
      ),
    );
  }
}

/// Bas de liste : chargement, erreur de pagination ou fin de liste.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state, required this.onRetry});

  final RecipesState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final Failure? loadMoreFailure = state.loadMoreFailure;
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (loadMoreFailure != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text(loadMoreFailure.message, textAlign: TextAlign.center),
            TextButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      );
    }
    if (!state.hasMore && !state.isSearching) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Toutes les recettes sont affichées.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return const SizedBox(height: 16);
  }
}

/// Indique que la liste vient du cache (serveur injoignable).
class _CacheNotice extends StatelessWidget {
  const _CacheNotice();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colors.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        'Données enregistrées : tire vers le bas pour actualiser.',
        style: TextStyle(color: colors.onTertiaryContainer),
      ),
    );
  }
}