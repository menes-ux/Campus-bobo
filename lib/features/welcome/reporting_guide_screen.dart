import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ReportingGuideScreen extends StatelessWidget {
  const ReportingGuideScreen({super.key});

  static const _categories = [
    (Icons.construction_outlined, 'Facilities'),
    (Icons.water_drop_outlined, 'Water'),
    (Icons.bolt_outlined, 'Electricity'),
    (Icons.chair_outlined, 'Furniture'),
    (Icons.cleaning_services_outlined, 'Sanitation'),
    (Icons.shield_outlined, 'Safety'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reporting guide')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'A good report\ngoes a long way.',
                  style: text.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Help campus staff understand what happened and where to find it.',
                  style: text.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                const _GuideStep(
                  number: '01',
                  title: 'Describe what you noticed',
                  description:
                      'Choose a category and explain the issue. Include useful details, '
                      'such as when it started and who it affects.',
                ),
                const SizedBox(height: 16),
                const _GuideStep(
                  number: '02',
                  title: 'Point to the right place',
                  description:
                      'Include the building, floor, or room. An optional photo can '
                      'help staff understand the problem. Avoid including people or private information.',
                ),
                const SizedBox(height: 16),
                const _GuideStep(
                  number: '03',
                  title: 'Follow up on your report',
                  description: 'Check the report status to see progress from submission to resolution.',
                ),
                const SizedBox(height: 32),
                Text('What can you report?', style: text.titleLarge),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth < 340
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final category in _categories)
                          Container(
                            width: width,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Icon(category.$1, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    category.$2,
                                    style: text.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.paleYellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'For immediate danger, contact campus security or local emergency '
                          'services directly. An incident report is not an emergency call.',
                          style: text.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: text.headlineSmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Text(title, style: text.titleMedium),
          const SizedBox(height: 8),
          Text(
            description,
            style: text.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
