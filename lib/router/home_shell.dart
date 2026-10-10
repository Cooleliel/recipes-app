import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/core/widgets/offline_banner.dart';

import '../l10n/app_localizations.dart';

/// Coque des 3 onglets : barre de navigation + bandeau « Hors ligne ».
///
/// `StatefulShellRoute` garde l'état de chaque onglet (position de scroll,
/// recherche en cours) quand on passe de l'un à l'autre.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  
  /// Clés des onglets, utilisées par les tests d'intégration.
  static const Key recipesTabKey = Key('tab_recipes');
  static const Key categoriesTabKey = Key('tab_categories');
  static const Key profileTabKey = Key('tab_profile');

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Re-toucher l'onglet actif revient à sa racine.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const OfflineBanner(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: <NavigationDestination>[
              NavigationDestination(
                key: HomeShell.recipesTabKey,
                icon: const Icon(Icons.restaurant_menu_outlined),
                selectedIcon: const Icon(Icons.restaurant_menu),
                label: l10n.tabRecipes,
              ),
              NavigationDestination(
                key: HomeShell.categoriesTabKey,
                icon: const Icon(Icons.category_outlined),
                selectedIcon: const Icon(Icons.category),
                label: l10n.tabCategories,
              ),
              NavigationDestination(
                key: HomeShell.profileTabKey,
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n.tabProfile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
