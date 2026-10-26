import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/auth_controller.dart';

class VerifiedSessionGuard extends StatelessWidget {
  const VerifiedSessionGuard({
    super.key,
    required this.uid,
    required this.child,
  });

  final String uid;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.session == AuthSession.verified && auth.user?.uid == uid) {
      return child;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please sign in again to view reports.'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
