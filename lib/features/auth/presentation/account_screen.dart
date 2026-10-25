import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../welcome/reporting_guide_screen.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user!;
    final text = Theme.of(context).textTheme;
    return AuthLayout(
      title: 'Your campus account.',
      description: 'You are signed in with your verified ALU student email.',
      icon: Icons.verified_user_outlined,
      children: [
        AuthFeedback(auth: auth),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.displayName ?? 'ALU student', style: text.titleLarge),
              const SizedBox(height: 8),
              SelectableText(user.email),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.verified_outlined, size: 20),
                  SizedBox(width: 8),
                  Flexible(child: Text('Verified student')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ReportingGuideScreen(),
            ),
          ),
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('Reporting guide'),
        ),
        const SizedBox(height: 12),
        AuthSubmitButton(
          label: 'Sign out',
          isBusy: auth.isBusy,
          onPressed: auth.signOut,
        ),
      ],
    );
  }
}
