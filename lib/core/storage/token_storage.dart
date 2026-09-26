import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage chiffré des tokens JWT (Keychain iOS, Keystore Android).
///
/// L'access token est aussi gardé en mémoire pour éviter une lecture
/// chiffrée à chaque requête.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  String? _cachedAccessToken;

  Future<String?> readAccessToken() async {
    _cachedAccessToken ??= await _storage.read(key: _accessTokenKey);
    return _cachedAccessToken;
  }

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  /// Enregistre la nouvelle paire de tokens. Le refresh token Supabase est à
  /// usage unique : il faut toujours garder le dernier reçu.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    _cachedAccessToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Une session existe tant qu'un refresh token est enregistré.
  Future<bool> hasSession() async => await readRefreshToken() != null;
}