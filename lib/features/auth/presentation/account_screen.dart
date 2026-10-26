import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../welcome/reporting_guide_screen.dart';
import '../../profile/domain/user_profile.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.onBrowseReports,
    required this.onReportIncident,
  });

  final VoidCallback onBrowseReports;
  final VoidCallback onReportIncident;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final profile = context.watch<UserProfile>();
    final text = Theme.of(context).textTheme;
    return AuthLayout(
      title: 'Your campus account.',
      description: 'You are signed in with your verified ALU email.',
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
              Text(profile.displayName, style: text.titleLarge),
              const SizedBox(height: 8),
              SelectableText(profile.email),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 20),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Role: ${profile.role.label}')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: auth.isBusy ? null : onReportIncident,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Report an incident'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: auth.isBusy ? null : onBrowseReports,
          icon: const Icon(Icons.view_list_outlined),
          label: const Text('Browse reports'),
        ),
        const SizedBox(height: 12),
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
