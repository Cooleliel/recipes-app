import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipes_app/core/errors/failures.dart';
import 'package:recipes_app/core/widgets/app_toast.dart';
import 'package:recipes_app/features/auth/domain/validators/credentials_validator.dart';
import 'package:recipes_app/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:recipes_app/features/auth/presentation/widgets/password_field.dart';
import 'package:recipes_app/router/app_routes.dart';

/// Écran d'inscription (pseudo, email, mot de passe, confirmation).
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) return 'Confirme le mot de passe.';
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final Failure? failure = await ref
        .read(authNotifierProvider.notifier)
        .register(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
        );

    // En cas de succès, le routeur quitte déjà cet écran.
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (failure != null) {
      AppToast.show(context, failure.message, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          tooltip: 'Retour à la connexion',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Rejoins Recipes App pour accéder à toutes les recettes.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.nickname],
                        validator: CredentialsValidator.displayName,
                        decoration: const InputDecoration(
                          labelText: 'Pseudo (facultatif)',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                        validator: CredentialsValidator.email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[
                          AutofillHints.newPassword,
                        ],
                        validator: CredentialsValidator.password,
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: _confirmController,
                        label: 'Confirmer le mot de passe',
                        autofillHints: const <String>[
                          AutofillHints.newPassword,
                        ],
                        validator: _validateConfirmation,
                        onFieldSubmitted: (String value) => _submit(),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Créer mon compte'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => context.go(AppRoutes.login),
                        child: const Text('Déjà un compte ? Se connecter'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
