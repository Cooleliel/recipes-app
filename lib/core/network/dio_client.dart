import 'package:dio/dio.dart';
import 'package:recipes_app/core/network/api_constants.dart';

/// Fabrique les clients Dio configurés pour Supabase.
abstract final class DioClient {
  /// URL de base, clé publique (`apikey`), délais et JSON par défaut.
  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.supabaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: <String, dynamic>{'apikey': ApiConstants.supabaseKey},
      ),
    );
  }
}
