import 'package:dio/dio.dart';
import 'package:recipes_app/core/errors/exceptions.dart';
import 'package:recipes_app/core/network/api_constants.dart';
import 'package:recipes_app/core/network/auth_interceptor.dart';
import 'package:recipes_app/core/network/dio_error_mapper.dart';
import 'package:recipes_app/features/auth/data/models/auth_session_model.dart';
import 'package:recipes_app/features/auth/data/models/user_model.dart';

/// Appels REST à Supabase Auth.
abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  /// `null` si le projet exige une confirmation par email avant connexion.
  Future<AuthSessionModel?> register({
    required String email,
    required String password,
    String? displayName,
  });

  Future<UserModel> getCurrentUser();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Requêtes publiques : l'intercepteur n'ajoute pas de token.
  Options get _publicOptions =>
      Options(extra: <String, dynamic>{AuthInterceptor.skipAuth: true});

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .post<Map<String, dynamic>>(
            ApiConstants.token,
            queryParameters: <String, String>{'grant_type': 'password'},
            data: <String, String>{'email': email, 'password': password},
            options: _publicOptions,
          );
      return AuthSessionModel.fromJson(_requireBody(response));
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<AuthSessionModel?> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .post<Map<String, dynamic>>(
            ApiConstants.signup,
            data: <String, dynamic>{
              'email': email,
              'password': password,
              if (displayName != null)
                'data': <String, String>{'display_name': displayName},
            },
            options: _publicOptions,
          );
      final Map<String, dynamic> body = _requireBody(response);
      if (body['access_token'] is! String) return null;
      return AuthSessionModel.fromJson(body);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final Response<Map<String, dynamic>> response = await _dio
          .get<Map<String, dynamic>>(ApiConstants.user);
      return UserModel.fromJson(_requireBody(response));
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<dynamic>(ApiConstants.logout);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    }
  }

  static Map<String, dynamic> _requireBody(
    Response<Map<String, dynamic>> response,
  ) {
    final Map<String, dynamic>? body = response.data;
    if (body == null) throw const ServerException('Réponse vide du serveur.');
    return body;
  }
}
