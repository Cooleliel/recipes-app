import 'package:recipes_app/core/errors/exceptions.dart';
import 'package:recipes_app/core/errors/failures.dart';

/// Convertit une exception technique (couche Data) en [Failure] (couche Domain).
abstract final class FailureMapper {
  static Failure fromException(Exception exception) {
    return switch (exception) {
      NetworkException() => const NetworkFailure(),
      UnauthorizedException() => const AuthFailure(),
      NotFoundException() => const NotFoundFailure(),
      CacheException(:final String message) => CacheFailure(message),
      ServerException(:final String message) => ServerFailure(message),
      final Failure failure => failure,
      _ => const ServerFailure('Une erreur inattendue est survenue.'),
    };
  }
}
