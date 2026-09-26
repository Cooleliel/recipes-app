/// Règles de validation des identifiants.
///
/// Partagées par les use cases (domaine) et les formulaires (présentation) :
/// une seule source de vérité. Chaque méthode renvoie un message d'erreur,
/// ou `null` si la valeur est valide (signature d'un `FormFieldValidator`).
abstract final class CredentialsValidator {
  /// Minimum imposé par défaut par Supabase Auth.
  static const int minPasswordLength = 6;
  static const int maxDisplayNameLength = 50;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return 'L’email est obligatoire.';
    if (!_emailPattern.hasMatch(email)) return 'Adresse email invalide.';
    return null;
  }

  static String? password(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) return 'Le mot de passe est obligatoire.';
    if (password.length < minPasswordLength) {
      return 'Au moins $minPasswordLength caractères.';
    }
    return null;
  }

  static String? displayName(String? value) {
    final String name = value?.trim() ?? '';
    if (name.length > maxDisplayNameLength) {
      return '$maxDisplayNameLength caractères maximum.';
    }
    return null;
  }
}
