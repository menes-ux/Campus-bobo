import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/incident_status.dart';

String formatIncidentDate(DateTime? value) {
  if (value == null) return 'Just submitted';
  final date = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
}

class IncidentStatusBadge extends StatelessWidget {
  const IncidentStatusBadge({super.key, required this.status});

  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final background = switch (status) {
      IncidentStatus.submitted => AppColors.paleOrange,
      IncidentStatus.inProgress => AppColors.paleBlue,
      IncidentStatus.resolved => AppColors.paleGreen,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: switch (status) {
            IncidentStatus.submitted => AppColors.orange,
            IncidentStatus.inProgress => AppColors.blue,
            IncidentStatus.resolved => AppColors.green,
          },
        ),
      ),
    );
  }
}

class IncidentMessage extends StatelessWidget {
  const IncidentMessage({
    super.key,
    required this.title,
    required this.description,
    this.onRetry,
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined, size: 40),
            const SizedBox(height: 16),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
