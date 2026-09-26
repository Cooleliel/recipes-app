/// Exceptions techniques levées par la couche Data (datasources).
///
/// Elles ne sortent jamais de la couche Data : les repositories les
/// convertissent en `Failure` grâce à `FailureMapper`.
library;

/// Le serveur a répondu par une erreur (4xx ou 5xx hors problème de session).
class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Pas de réseau, délai dépassé ou serveur injoignable.
class NetworkException implements Exception {
  const NetworkException([this.message = 'Serveur injoignable.']);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Token absent, invalide ou expiré, et renouvellement impossible.
class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Session invalide ou expirée.']);

  final String message;

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// La ressource demandée n'existe pas (404, 406 ou résultat vide).
class NotFoundException implements Exception {
  const NotFoundException([this.message = 'Ressource introuvable.']);

  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}

/// Lecture ou écriture du cache local impossible.
class CacheException implements Exception {
  const CacheException([this.message = 'Lecture du cache impossible.']);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}