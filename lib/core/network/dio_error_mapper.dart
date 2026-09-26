import 'package:dio/dio.dart';
import 'package:recipes_app/core/errors/exceptions.dart';

/// Traduit les erreurs Dio (et les réponses d'erreur de Supabase) en
/// exceptions de la couche Data, avec des messages en français.
abstract final class DioErrorMapper {
  /// Codes renvoyés par Supabase Auth quand le JWT est invalide ou expiré.
  static const Set<String> _sessionErrorCodes = <String>{
    'bad_jwt',
    'session_not_found',
    'session_expired',
    'no_authorization',
  };

  static Exception map(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => _fromResponse(error.response),
      DioExceptionType.cancel => const ServerException('Requête annulée.'),
      DioExceptionType.badCertificate => const ServerException(
        'Certificat du serveur invalide.',
      ),
      DioExceptionType.unknown =>
        error.response == null
            ? const NetworkException()
            : _fromResponse(error.response),
    };
  }

  /// Vrai si la réponse signale un token absent, invalide ou expiré.
  ///
  /// PostgREST répond 401 ; Supabase Auth répond 403 avec `error_code: bad_jwt`.
  static bool isAuthError(Response<dynamic>? response) {
    final int? statusCode = response?.statusCode;
    if (statusCode == 401) return true;
    if (statusCode == 403) {
      final String? code = errorCode(response?.data);
      return code != null && _sessionErrorCodes.contains(code);
    }
    return false;
  }

  /// Code d'erreur Supabase (`error_code` pour Auth, `code` pour PostgREST).
  static String? errorCode(Object? data) {
    if (data is Map<String, dynamic>) {
      final Object? errorCode = data['error_code'];
      if (errorCode is String) return errorCode;
      final Object? code = data['code'];
      if (code is String) return code;
    }
    return null;
  }

  static Exception _fromResponse(Response<dynamic>? response) {
    if (isAuthError(response)) return const UnauthorizedException();
    final int statusCode = response?.statusCode ?? 0;
    if (statusCode == 404 || statusCode == 406) {
      return const NotFoundException();
    }
    final Object? data = response?.data;
    return ServerException(
      _messageFor(statusCode, errorCode(data), data),
      statusCode: statusCode,
    );
  }

  static String _messageFor(int statusCode, String? code, Object? data) {
    switch (code) {
      case 'invalid_credentials':
        return 'Email ou mot de passe incorrect.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Un compte existe déjà avec cet email.';
      case 'weak_password':
        return 'Mot de passe trop faible : 6 caractères minimum.';
      case 'email_address_invalid':
      case 'validation_failed':
        return 'Adresse email invalide.';
      case 'email_not_confirmed':
        return 'Email non confirmé : vérifie ta boîte mail.';
      case 'signup_disabled':
        return 'Les inscriptions sont désactivées sur ce projet.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Trop de tentatives. Réessaie dans quelques minutes.';
    }
    final String? serverMessage = _serverMessage(data);
    if (serverMessage == 'Invalid login credentials') {
      return 'Email ou mot de passe incorrect.';
    }
    if (serverMessage == 'User already registered') {
      return 'Un compte existe déjà avec cet email.';
    }
    if (statusCode == 429) {
      return 'Trop de tentatives. Réessaie dans quelques minutes.';
    }
    if (statusCode >= 500) {
      return 'Le serveur est indisponible. Réessaie plus tard.';
    }
    return 'Erreur inattendue du serveur ($statusCode).';
  }

  static String? _serverMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      for (final String key in <String>[
        'msg',
        'message',
        'error_description',
      ]) {
        final Object? value = data[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return null;
  }
}
