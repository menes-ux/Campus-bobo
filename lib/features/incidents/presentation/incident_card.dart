import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/incident.dart';
import 'incident_widgets.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.report, required this.onTap});

  final Incident report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: AppColors.canvas,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report.category.label,
                      style: text.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(report.location, style: text.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IncidentStatusBadge(status: report.status),
                  Text(
                    formatIncidentDate(report.createdAt),
                    style: text.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
