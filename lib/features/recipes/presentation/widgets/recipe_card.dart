import 'package:flutter/material.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_image.dart';

/// Carte d'une recette dans une liste (image, nom, note, durée, difficulté).
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            RecipeImage(
              imageUrl: recipe.imageUrl,
              width: 110,
              height: 110,
              semanticLabel: 'Photo : ${recipe.name}',
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.cuisine,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: <Widget>[
                        _InfoLabel(
                          icon: Icons.star_rounded,
                          label: recipe.rating.toStringAsFixed(1),
                          semanticLabel: 'Note ${recipe.rating} sur 5',
                        ),
                        _InfoLabel(
                          icon: Icons.timer_outlined,
                          label: '${recipe.totalTimeMinutes} min',
                          semanticLabel: 'Durée ${recipe.totalTimeMinutes} minutes',
                        ),
                        _InfoLabel(
                          icon: Icons.signal_cellular_alt,
                          label: recipe.difficulty,
                          semanticLabel: 'Difficulté ${recipe.difficulty}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel({
    required this.icon,
    required this.label,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}