import 'package:dio/dio.dart';
import 'package:recipes_app/core/network/api_constants.dart';
import 'package:recipes_app/core/network/dio_error_mapper.dart';
import 'package:recipes_app/core/storage/token_storage.dart';

/// Ajoute le token à chaque requête et le renouvelle quand il a expiré.
///
/// C'est un [QueuedInterceptor] : les erreurs sont traitées une par une.
/// Si dix requêtes échouent en même temps sur un token expiré, un seul
/// refresh a lieu et les neuf autres réutilisent le nouveau token.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio plainDio,
    required void Function() onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _plainDio = plainDio,
        _onSessionExpired = onSessionExpired;

  /// À mettre dans `Options.extra` pour les requêtes publiques
  /// (connexion, inscription) : pas de token ni de refresh.
  static const String skipAuth = 'skipAuth';

  /// Marque une requête déjà rejouée, pour ne jamais boucler.
  static const String _retried = 'retriedAfterRefresh';

  final TokenStorage _tokenStorage;

  /// Client SANS intercepteur, pour le refresh et le rejeu de la requête.
  final Dio _plainDio;

  final void Function() _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuth] != true) {
      final String? accessToken = await _tokenStorage.readAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;
    final bool canRefresh = DioErrorMapper.isAuthError(err.response) &&
        request.extra[skipAuth] != true &&
        request.extra[_retried] != true;
    if (!canRefresh) {
      handler.next(err);
      return;
    }

    // 1. Pendant que cette requête attendait dans la file, une autre a
    //    peut-être déjà renouvelé le token : on la rejoue directement.
    final String? currentToken = await _tokenStorage.readAccessToken();
    final String? usedToken = _bearerFrom(request.headers['Authorization']);
    if (currentToken != null && currentToken != usedToken) {
      await _retry(request, currentToken, handler);
      return;
    }

    // 2. Sinon, on échange le refresh token contre une nouvelle paire.
    final String? refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      await _expireSession();
      handler.next(err);
      return;
    }

    try {
      final Response<Map<String, dynamic>> response =
          await _plainDio.post<Map<String, dynamic>>(
        ApiConstants.token,
        queryParameters: <String, String>{'grant_type': 'refresh_token'},
        data: <String, String>{'refresh_token': refreshToken},
      );
      final Map<String, dynamic> body =
          response.data ?? <String, dynamic>{};
      final String newAccessToken = body['access_token'] as String;
      final String newRefreshToken = body['refresh_token'] as String;
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      await _retry(request, newAccessToken, handler);
    } on DioException catch (refreshError) {
      if (refreshError.response == null) {
        // Pas de réseau pendant le refresh : on garde la session et on
        // laisse remonter l'erreur réseau (le repository utilisera le cache).
        handler.next(refreshError);
      } else {
        // Refresh token refusé (révoqué ou expiré) : fin de session.
        await _expireSession();
        handler.next(err);
      }
    } catch (_) {
      await _expireSession();
      handler.next(err);
    }
  }

  /// Rejoue la requête d'origine avec le nouveau token.
  Future<void> _retry(
    RequestOptions request,
    String accessToken,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions retryOptions = request.copyWith(
      headers: <String, dynamic>{
        ...request.headers,
        'Authorization': 'Bearer $accessToken',
      },
      extra: <String, dynamic>{...request.extra, _retried: true},
    );
    try {
      final Response<dynamic> response =
          await _plainDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<void> _expireSession() async {
    await _tokenStorage.clear();
    _onSessionExpired();
  }

  static String? _bearerFrom(Object? header) {
    if (header is String && header.startsWith('Bearer ')) {
      return header.substring('Bearer '.length);
    }
    return null;
  }
}