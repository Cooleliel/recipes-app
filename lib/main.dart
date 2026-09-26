import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:recipes_app/app.dart';
import 'package:recipes_app/core/network/api_constants.dart';
import 'package:recipes_app/core/storage/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!ApiConstants.isConfigured) {
    runApp(const MissingConfigApp());
    return;
  }

  // Cache hors ligne : ouverture des boîtes Hive avant le premier écran.
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.recipes);
  await Hive.openBox<String>(HiveBoxes.auth);

  runApp(
    ProviderScope(
      // Riverpod 3 relance automatiquement un provider en erreur. On le
      // désactive : l'utilisateur voit l'erreur et choisit de réessayer.
      retry: (int retryCount, Object error) => null,
      child: const RecipesApp(),
    ),
  );
}

/// Affichée si l'app est lancée sans `--dart-define-from-file=config/env.json`.
class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Configuration manquante.\n\n'
              'Lance l’app avec :\n'
              'flutter run --dart-define-from-file=config/env.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
