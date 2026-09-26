import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipes_app/core/di/core_providers.dart';

/// Bandeau affiché tant que l'appareil n'a pas de connexion.
///
/// Invisible (taille nulle) quand l'appareil est en ligne.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> status = ref.watch(connectivityStatusProvider);
    final bool isOffline = status.when(
      data: (bool isConnected) => !isConnected,
      loading: () => false,
      error: (Object error, StackTrace stackTrace) => false,
    );
    if (!isOffline) return const SizedBox.shrink();

    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Material(
        color: colors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              Icon(Icons.cloud_off, size: 18, color: colors.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hors ligne : affichage des données enregistrées',
                  style: TextStyle(color: colors.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
