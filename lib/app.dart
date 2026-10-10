import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/core/theme/app_theme.dart';
import 'package:recipes_app/l10n/app_localizations.dart';
import 'package:recipes_app/router/app_router.dart';

/// Racine de l'application : thème clair/sombre, routeur et langues FR / EN.
class RecipesApp extends ConsumerWidget {
  const RecipesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    return MaterialApp.router(
      // Le titre dépend de la langue : il est lu une fois les traductions chargées.
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      // Sans ces deux lignes, AppLocalizations.of(context) renvoie null.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}