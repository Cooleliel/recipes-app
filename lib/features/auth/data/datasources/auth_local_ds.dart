import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:recipes_app/features/auth/data/models/user_model.dart';

/// Cache local du profil (affichage du profil hors ligne).
///
/// Les tokens, eux, sont dans `TokenStorage` (stockage chiffré).
abstract interface class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);

  UserModel? getCachedUser();

  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._box);

  final Box<String> _box;

  static const String _userKey = 'current_user';

  @override
  Future<void> cacheUser(UserModel user) =>
      _box.put(_userKey, jsonEncode(user.toJson()));

  @override
  UserModel? getCachedUser() {
    final String? raw = _box.get(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> clear() => _box.delete(_userKey);
}
