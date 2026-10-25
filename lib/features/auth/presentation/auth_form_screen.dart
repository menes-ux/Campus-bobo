import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../application/auth_controller.dart';
import '../domain/auth_validators.dart';
import 'auth_widgets.dart';

enum _AuthMode { signIn, register }

class AuthFormScreen extends StatefulWidget {
  const AuthFormScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends State<AuthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  _AuthMode _mode = _AuthMode.signIn;

  void _changeMode(_AuthMode mode) {
    context.read<AuthController>().clearFeedback();
    setState(() {
      final email = _email.text;
      final name = _name.text;
      _mode = mode;
      _formKey.currentState?.reset();
      _email.text = email;
      _name.text = name;
      _password.clear();
      _confirmation.clear();
    });
  }

  void _goBack() {
    final auth = context.read<AuthController>();
    if (auth.isBusy) return;
    if (_mode == _AuthMode.signIn) {
      auth.clearFeedback();
      widget.onBack();
    } else {
      _changeMode(_AuthMode.signIn);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthController>();
    final success = await switch (_mode) {
      _AuthMode.signIn => auth.signIn(_email.text, _password.text),
      _AuthMode.register => auth.register(
        _name.text,
        _email.text,
        _password.text,
      ),
    };
    if (success) {
      TextInput.finishAutofillContext();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isRegister = _mode == _AuthMode.register;
    final title = switch (_mode) {
      _AuthMode.signIn => 'Welcome back.',
      _AuthMode.register => 'A better campus\nstarts with you.',
    };

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: AuthLayout(
        title: title,
        description: isRegister
            ? 'Create an account with your ALU student email. We will ask you to verify it.'
            : 'Sign in with your ALU student email to stay connected to your campus.',
        onBack: _goBack,
        children: [
          AuthFeedback(auth: auth),
          AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isRegister) ...[
                    TextFormField(
                      key: const ValueKey('auth-name'),
                      controller: _name,
                      enabled: !auth.isBusy,
                      validator: AuthValidators.displayName,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  TextFormField(
                    key: const ValueKey('auth-email'),
                    controller: _email,
                    enabled: !auth.isBusy,
                    validator: AuthValidators.studentEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Student email',
                      hintText: 'you@alustudent.com',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  ...[
                    const SizedBox(height: 18),
                    PasswordField(
                      key: const ValueKey('auth-password'),
                      controller: _password,
                      enabled: !auth.isBusy,
                      label: 'Password',
                      isNewPassword: isRegister,
                      validator: isRegister
                          ? AuthValidators.newPassword
                          : AuthValidators.loginPassword,
                      onSubmitted: isRegister ? null : (_) => _submit(),
                    ),
                  ],
                  if (isRegister) ...[
                    const SizedBox(height: 18),
                    PasswordField(
                      key: const ValueKey('auth-confirm-password'),
                      controller: _confirmation,
                      enabled: !auth.isBusy,
                      label: 'Confirm password',
                      isNewPassword: true,
                      validator: (value) =>
                          AuthValidators.confirmPassword(value, _password.text),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Use at least 8 characters. Choose a password you do not use elsewhere.',
                    ),
                  ],
                  const SizedBox(height: 24),
                  AuthSubmitButton(
                    key: const ValueKey('auth-submit'),
                    label: isRegister ? 'Create account' : 'Sign in',
                    isBusy: auth.isBusy,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: auth.isBusy
                ? null
                : () => _changeMode(
                    isRegister ? _AuthMode.signIn : _AuthMode.register,
                  ),
            child: Text(
              isRegister ? 'Back to sign in' : 'New here? Create an account',
            ),
          ),
        ],
      ),
    );
  }
}
