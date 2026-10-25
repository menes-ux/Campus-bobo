import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/icon_tile.dart';
import 'reporting_guide_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const BrandMark(),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconTile(
                        icon: Icons.school_outlined,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Your campus.\nA little better.',
                        style: text.headlineLarge,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'A broken tap. A dark hallway. A chair that needs fixing. '
                        'Every report is a step towards a better campus.',
                        style: text.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Notice it. Report it. Track it.',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Small actions. Real change.', style: text.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'One place to raise campus issues and follow their progress.',
                  style: text.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                const _Feature(
                  icon: Icons.edit_note_rounded,
                  title: 'Make it clear',
                  description: 'Describe the issue, choose a category, and add its location.',
                ),
                const SizedBox(height: 20),
                const _Feature(
                  icon: Icons.route_outlined,
                  title: 'Follow the progress',
                  description:
                      'Keep up with updates as campus staff work on the issue.',
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReportingGuideScreen(),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Text('How reporting works')),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Made for the ALU community.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon: icon),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleSmall),
              const SizedBox(height: 4),
              Text(
                description,
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
