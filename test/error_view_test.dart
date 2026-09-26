import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes_app/core/widgets/error_view.dart';

void main() {
  group('ErrorView', () {
    testWidgets('affiche le message et relance au clic sur « Réessayer »', (
      WidgetTester tester,
    ) async {
      // Arrange
      int retryCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Connexion internet indisponible.',
              onRetry: () {
                retryCount++;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Réessayer'));
      await tester.pump();

      // Assert
      expect(find.text('Connexion internet indisponible.'), findsOneWidget);
      expect(retryCount, 1);
    });

    testWidgets('masque le bouton quand aucune action n’est possible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorView(message: 'Recette introuvable.')),
        ),
      );

      expect(find.text('Recette introuvable.'), findsOneWidget);
      expect(find.text('Réessayer'), findsNothing);
    });
  });
}