import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipes_app/core/di/core_providers.dart';
import 'package:recipes_app/core/network/network_info.dart';
import 'package:recipes_app/core/widgets/offline_banner.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  const String offlineMessage =
      'Hors ligne : affichage des données enregistrées';

  late MockNetworkInfo networkInfo;

  setUp(() {
    networkInfo = MockNetworkInfo();
  });

  /// Affiche le bandeau avec un état réseau simulé.
  Future<void> pumpBanner(WidgetTester tester, {required bool isOnline}) async {
    when(
      () => networkInfo.onStatusChange,
    ).thenAnswer((Invocation invocation) => Stream<bool>.value(isOnline));

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          networkInfoProvider.overrideWithValue(networkInfo),
        ],
        child: const MaterialApp(home: Scaffold(body: OfflineBanner())),
      ),
    );
    // Laisse le Stream émettre sa valeur, puis redessine l'écran.
    await tester.pumpAndSettle();
  }

  group('OfflineBanner', () {
    testWidgets('s’affiche quand l’appareil est hors ligne', (
      WidgetTester tester,
    ) async {
      await pumpBanner(tester, isOnline: false);

      expect(find.text(offlineMessage), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('reste invisible quand l’appareil est en ligne', (
      WidgetTester tester,
    ) async {
      await pumpBanner(tester, isOnline: true);

      expect(find.text(offlineMessage), findsNothing);
      expect(find.byIcon(Icons.cloud_off), findsNothing);
    });
  });
}