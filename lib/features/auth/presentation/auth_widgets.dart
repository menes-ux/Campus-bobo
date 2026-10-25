import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand_mark.dart';
import '../application/auth_controller.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.description,
    required this.children,
    this.onBack,
    this.icon = Icons.lock_outline_rounded,
  });

  final String title;
  final String description;
  final List<Widget> children;
  final VoidCallback? onBack;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: onBack == null
          ? null
          : AppBar(leading: BackButton(onPressed: onBack)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              children: [
                const BrandMark(),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(icon, size: 30),
                  ),
                ),
                const SizedBox(height: 24),
                Text(title, style: text.headlineLarge),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: text.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthFeedback extends StatelessWidget {
  const AuthFeedback({super.key, required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    final message = auth.error ?? auth.message;
    if (message == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final isError = auth.error != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Semantics(
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isError ? colors.errorContainer : AppColors.paleYellow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isError ? colors.onErrorContainer : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isBusy,
    required this.onPressed,
  });

  final String label;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isBusy ? null : onPressed,
      child: isBusy
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    required this.enabled,
    this.isNewPassword = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final bool isNewPassword;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      validator: widget.validator,
      obscureText: _obscure,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: [
        widget.isNewPassword
            ? AutofillHints.newPassword
            : AutofillHints.password,
      ],
      textInputAction: widget.onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: widget.enabled
              ? () => setState(() => _obscure = !_obscure)
              : null,
          tooltip: _obscure ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
