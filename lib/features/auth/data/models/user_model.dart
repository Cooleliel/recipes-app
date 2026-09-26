import 'package:recipes_app/features/auth/domain/entities/user.dart';

/// Modèle de la couche Data : l'entité [User] + la conversion JSON.
///
/// Format Supabase Auth : `id`, `email`, `created_at`, `last_sign_in_at`,
/// et le pseudo dans `user_metadata.display_name`.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.createdAt,
    super.lastSignInAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Object? metadata = json['user_metadata'];
    final String? displayName = metadata is Map<String, dynamic>
        ? metadata['display_name'] as String?
        : null;
    return UserModel(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      displayName: displayName,
      createdAt: _parseDate(json['created_at']),
      lastSignInAt: _parseDate(json['last_sign_in_at']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'user_metadata': <String, dynamic>{'display_name': displayName},
        'created_at': createdAt?.toIso8601String(),
        'last_sign_in_at': lastSignInAt?.toIso8601String(),
      };

  /// La couche Data renvoie toujours une entité, jamais un modèle.
  User toEntity() => User(
        id: id,
        email: email,
        displayName: displayName,
        createdAt: createdAt,
        lastSignInAt: lastSignInAt,
      );

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}