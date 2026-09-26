import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recipes_app/core/network/auth_interceptor.dart';
import 'package:recipes_app/core/network/dio_client.dart';
import 'package:recipes_app/core/network/network_info.dart';
import 'package:recipes_app/core/network/session_events.dart';
import 'package:recipes_app/core/storage/token_storage.dart';

// Injection des dépendances partagées (core), avec Riverpod.
//
// Chaque provider est typé avec l'abstraction quand elle existe
// (ex. NetworkInfo) : on peut le remplacer par un mock dans les tests.

final Provider<FlutterSecureStorage> secureStorageProvider =
    Provider<FlutterSecureStorage>(
  (Ref ref) => const FlutterSecureStorage(),
);

final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (Ref ref) => TokenStorage(ref.watch(secureStorageProvider)),
);

final Provider<SessionEvents> sessionEventsProvider = Provider<SessionEvents>(
  (Ref ref) {
    final SessionEvents events = SessionEvents();
    ref.onDispose(events.dispose);
    return events;
  },
);

final Provider<NetworkInfo> networkInfoProvider = Provider<NetworkInfo>(
  (Ref ref) => NetworkInfoImpl(Connectivity()),
);

/// État de la connexion en temps réel (bandeau « Hors ligne »).
final StreamProvider<bool> connectivityStatusProvider = StreamProvider<bool>(
  (Ref ref) => ref.watch(networkInfoProvider).onStatusChange,
);

/// Client HTTP de l'app : Dio + intercepteur d'authentification.
final Provider<Dio> dioProvider = Provider<Dio>(
  (Ref ref) {
    final Dio dio = DioClient.create();
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: ref.watch(tokenStorageProvider),
        plainDio: DioClient.create(),
        onSessionExpired: ref.watch(sessionEventsProvider).notifySessionExpired,
      ),
    );
    ref.onDispose(dio.close);
    return dio;
  },
);