import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/core/widgets/offline_banner.dart';

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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const OfflineBanner(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                key: HomeShell.recipesTabKey,
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: 'Recettes',
              ),
              NavigationDestination(
                key: HomeShell.categoriesTabKey,
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: 'Catégories',
              ),
              NavigationDestination(
                key: HomeShell.profileTabKey,
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
