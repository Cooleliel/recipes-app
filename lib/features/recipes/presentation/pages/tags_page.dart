import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/widgets/empty_view.dart';
import 'package:recipes_app/core/widgets/error_view.dart';
import 'package:recipes_app/features/recipes/presentation/notifiers/tags_provider.dart';
import 'package:recipes_app/router/app_routes.dart';

/// Écran Catégories : toutes les catégories de recettes.
class TagsPage extends ConsumerWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<String>> tagsAsync = ref.watch(tagsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      body: tagsAsync.when(
        data: (List<String> tags) => tags.isEmpty
            ? const EmptyView(message: 'Aucune catégorie disponible.')
            : RefreshIndicator(
                onRefresh: () => ref.refresh(tagsProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    Text(
                      '${tags.length} catégories',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final String tag in tags)
                          ActionChip(
                            label: Text(tag),
                            onPressed: () =>
                                context.go(AppRoutes.recipesByTag(tag)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          message: Failure.messageOf(error),
          onRetry: () => ref.invalidate(tagsProvider),
        ),
      ),
    );
  }
}
