/// Erreurs métier renvoyées par les repositories (côté gauche d'un `Either`).
///
/// La classe est `sealed` : un `switch` sur un [Failure] doit traiter tous
/// les cas, et le compilateur le vérifie.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Message affichable tel quel à l'utilisateur.
  final String message;

  /// Message à afficher pour n'importe quelle erreur (ex. dans `AsyncValue.error`).
  static String messageOf(Object error) =>
      error is Failure ? error.message : 'Une erreur inattendue est survenue.';

  @override
  String toString() => message;
}

/// Pas de réseau et aucune donnée en cache pour répondre.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Pas de connexion internet et aucune donnée enregistrée.',
  ]);
}

/// Le serveur a refusé ou n'a pas pu traiter la requête.
final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Session absente, expirée ou révoquée.
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Session expirée : reconnecte-toi.']);
}

/// L'élément demandé n'existe pas.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Élément introuvable.']);
}

/// Les données locales sont illisibles.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erreur de lecture des données hors ligne.']);
}

/// Une règle métier n'est pas respectée (saisie invalide…).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}