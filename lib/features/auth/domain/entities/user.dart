/// Utilisateur connecté (entité métier, Dart pur).
class User {
  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
    this.lastSignInAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  /// Nom à afficher : le pseudo s'il existe, sinon le début de l'email.
  String get label {
    final String? name = displayName;
    if (name != null && name.isNotEmpty) return name;
    return email.split('@').first;
  }
}
