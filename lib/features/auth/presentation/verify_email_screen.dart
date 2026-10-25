import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/auth_controller.dart';
import 'auth_widgets.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final auth = context.read<AuthController>();
      if (auth.session == AuthSession.unverified) auth.refreshVerification();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return AuthLayout(
      title: 'Check your inbox.',
      description:
          'Open the verification link sent to ${auth.user!.email}. '
          'Then return here to finish signing in.',
      icon: Icons.mark_email_unread_outlined,
      children: [
        AuthFeedback(auth: auth),
        AuthSubmitButton(
          label: 'I have verified my email',
          isBusy: auth.isBusy,
          onPressed: auth.refreshVerification,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: auth.isBusy || auth.resendSeconds > 0
              ? null
              : auth.resendVerification,
          child: Text(
            auth.resendSeconds > 0
                ? 'Resend in ${auth.resendSeconds}s'
                : 'Resend verification email',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'No email? Check your spam folder and make sure the address above is correct.',
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: auth.isBusy ? null : auth.signOut,
          child: const Text('Use another account'),
        ),
      ],
    );
  }
}
