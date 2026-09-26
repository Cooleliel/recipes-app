import 'dart:async';

/// Canal d'événements de session entre la couche réseau (core) et la
/// feature auth : le core ne dépend ainsi d'aucune feature.
///
/// L'intercepteur signale une session expirée (refresh impossible) ;
/// `AuthNotifier` écoute et renvoie l'utilisateur vers la connexion.
class SessionEvents {
  final StreamController<void> _expiredController =
      StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _expiredController.stream;

  void notifySessionExpired() {
    if (!_expiredController.isClosed) _expiredController.add(null);
  }

  Future<void> dispose() => _expiredController.close();
}
