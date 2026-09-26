import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/widgets/empty_view.dart';
import 'package:recipes_app/core/widgets/error_view.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe_page.dart';
import 'package:recipes_app/features/recipes/presentation/notifiers/recipes_by_tag_provider.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:recipes_app/router/app_routes.dart';

/// Écran des recettes d'une catégorie.
class RecipesByTagPage extends ConsumerWidget {
  const RecipesByTagPage({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RecipePage> pageAsync = ref.watch(recipesByTagProvider(tag));
    return Scaffold(
      appBar: AppBar(title: Text(tag)),
      body: pageAsync.when(
        data: (RecipePage page) => page.recipes.isEmpty
            ? const EmptyView(message: 'Aucune recette dans cette catégorie.')
            : RefreshIndicator(
                onRefresh: () => ref.refresh(recipesByTagProvider(tag).future),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: page.recipes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Recipe recipe = page.recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () =>
                          context.push(AppRoutes.recipeDetail(recipe.id)),
                    );
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          message: Failure.messageOf(error),
          onRetry: () => ref.invalidate(recipesByTagProvider(tag)),
        ),
      ),
    );
  }
}