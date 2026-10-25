import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../welcome/welcome_screen.dart';
import '../application/auth_controller.dart';
import 'account_screen.dart';
import 'auth_form_screen.dart';
import 'auth_widgets.dart';
import 'verify_email_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSignIn = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return switch (auth.session) {
      AuthSession.loading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthSession.signedOut =>
        _showSignIn || auth.error != null
            ? AuthFormScreen(onBack: () => setState(() => _showSignIn = false))
            : WelcomeScreen(
                onGetStarted: () => setState(() => _showSignIn = true),
              ),
      AuthSession.unverified => const VerifyEmailScreen(),
      AuthSession.verified => const AccountScreen(),
      AuthSession.unsupportedEmail => AuthLayout(
        title: 'Use your student account.',
        description:
            '${auth.user!.email} is not an @alustudent.com address. '
            'Please sign in with your ALU student account.',
        children: [
          AuthFeedback(auth: auth),
          AuthSubmitButton(
            label: 'Sign out',
            isBusy: auth.isBusy,
            onPressed: auth.signOut,
          ),
        ],
      ),
    };
  }
}
