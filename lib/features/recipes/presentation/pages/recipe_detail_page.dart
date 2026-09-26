import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/widgets/error_view.dart';
import 'package:recipes_app/core/widgets/offline_banner.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/presentation/notifiers/recipe_detail_provider.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_image.dart';
import 'package:recipes_app/router/app_routes.dart';

/// Écran Détail : image, informations, ingrédients et étapes.
class RecipeDetailPage extends ConsumerWidget {
  const RecipeDetailPage({super.key, required this.recipeId});

  final int recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Recipe> recipeAsync = ref.watch(
      recipeDetailProvider(recipeId),
    );
    return recipeAsync.when(
      data: (Recipe recipe) => Scaffold(
        body: _RecipeDetailContent(recipe: recipe),
        bottomNavigationBar: const OfflineBanner(),
      ),
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stackTrace) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: Failure.messageOf(error),
          onRetry: () => ref.invalidate(recipeDetailProvider(recipeId)),
        ),
      ),
    );
  }
}

class _RecipeDetailContent extends StatelessWidget {
  const _RecipeDetailContent({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 260,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              recipe.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            background: RecipeImage(
              imageUrl: recipe.imageUrl,
              width: screenWidth,
              height: 260,
              semanticLabel: 'Photo : ${recipe.name}',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              _InfoChips(recipe: recipe),
              const SizedBox(height: 16),
              _TagChips(tags: recipe.tags),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Ingrédients'),
              for (final String ingredient in recipe.ingredients)
                _IngredientTile(ingredient: ingredient),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Préparation'),
              for (int i = 0; i < recipe.instructions.length; i++)
                _StepTile(number: i + 1, instruction: recipe.instructions[i]),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _InfoChips extends StatelessWidget {
  const _InfoChips({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        Chip(
          avatar: const Icon(Icons.star_rounded, size: 18),
          label: Text(
            '${recipe.rating.toStringAsFixed(1)} (${recipe.reviewCount} avis)',
          ),
        ),
        Chip(
          avatar: const Icon(Icons.timer_outlined, size: 18),
          label: Text(
            'Préparation ${recipe.prepTimeMinutes} min · Cuisson ${recipe.cookTimeMinutes} min',
          ),
        ),
        Chip(
          avatar: const Icon(Icons.people_outline, size: 18),
          label: Text('${recipe.servings} portions'),
        ),
        Chip(
          avatar: const Icon(Icons.local_fire_department_outlined, size: 18),
          label: Text('${recipe.caloriesPerServing} kcal / portion'),
        ),
        Chip(
          avatar: const Icon(Icons.signal_cellular_alt, size: 18),
          label: Text(recipe.difficulty),
        ),
        Chip(
          avatar: const Icon(Icons.public, size: 18),
          label: Text(recipe.cuisine),
        ),
      ],
    );
  }
}

/// Tags cliquables : ouvrent la liste des recettes de la catégorie.
class _TagChips extends StatelessWidget {
  const _TagChips({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final String tag in tags)
          ActionChip(
            label: Text('#$tag'),
            onPressed: () => context.go(AppRoutes.recipesByTag(tag)),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.ingredient});

  final String ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.circle,
            size: 8,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(ingredient)),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.number, required this.instruction});

  final int number;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.primaryContainer,
            child: Text(
              '$number',
              style: TextStyle(color: colors.onPrimaryContainer, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(instruction)),
        ],
      ),
    );
  }
}
