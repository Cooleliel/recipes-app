import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes_app/features/recipes/domain/entities/recipe.dart';
import 'package:recipes_app/features/recipes/presentation/widgets/recipe_card.dart';

void main() {
  // imageUrl vide : la carte affiche l'icône de remplacement, sans appel réseau.
  const Recipe pizza = Recipe(
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
    imageUrl: '',
    rating: 4.6,
    reviewCount: 98,
  );

  Future<void> pumpCard(WidgetTester tester, {VoidCallback? onTap}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecipeCard(recipe: pizza, onTap: onTap ?? () {}),
        ),
      ),
    );
  }

  group('RecipeCard', () {
    testWidgets('affiche le nom, la cuisine, la note, la durée et la difficulté', (
      WidgetTester tester,
    ) async {
      await pumpCard(tester);

      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('4.6'), findsOneWidget);
      expect(find.text('35 min'), findsOneWidget); // 20 + 15 minutes
      expect(find.text('Easy'), findsOneWidget);
      // Sans URL d'image : l'icône de remplacement est affichée.
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('appelle onTap quand on touche la carte', (
      WidgetTester tester,
    ) async {
      int tapCount = 0;
      await pumpCard(
        tester,
        onTap: () {
          tapCount++;
        },
      );

      await tester.tap(find.byType(RecipeCard));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('fournit des libellés accessibles aux lecteurs d’écran', (
      WidgetTester tester,
    ) async {
      await pumpCard(tester);

      final Iterable<String?> labels = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(RecipeCard),
              matching: find.byType(Semantics),
            ),
          )
          .map((Semantics semantics) => semantics.properties.label);

      expect(
        labels,
        containsAll(<String>[
          'Note 4.6 sur 5',
          'Durée 35 minutes',
          'Difficulté Easy',
        ]),
      );
    });
  });
}