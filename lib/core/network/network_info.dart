import 'package:connectivity_plus/connectivity_plus.dart';

/// Indique si l'appareil a une connexion réseau.
///
/// Une connexion ne garantit pas l'accès à internet : les repositories
/// retombent aussi sur le cache en cas de `NetworkException`.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;

  /// Émet l'état actuel, puis chaque changement de connectivité.
  Stream<bool> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async =>
      _hasConnection(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onStatusChange async* {
    yield await isConnected;
    yield* _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  static bool _hasConnection(List<ConnectivityResult> results) => results.any(
    (ConnectivityResult result) => result != ConnectivityResult.none,
  );
}
