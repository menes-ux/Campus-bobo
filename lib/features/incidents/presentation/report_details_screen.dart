import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/verified_session_guard.dart';
import '../domain/incident.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_status.dart';
import 'incident_widgets.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({
    super.key,
    required this.incidentId,
    required this.viewerUid,
  });

  final String incidentId;
  final String viewerUid;

  @override
  Widget build(BuildContext context) => VerifiedSessionGuard(
    uid: viewerUid,
    child: _ReportDetails(incidentId: incidentId, viewerUid: viewerUid),
  );
}

class _ReportDetails extends StatefulWidget {
  const _ReportDetails({required this.incidentId, required this.viewerUid});

  final String incidentId;
  final String viewerUid;

  @override
  State<_ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<_ReportDetails> {
  late Stream<Incident?> _report;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      _report = context.read<IncidentRepository>().watchById(widget.incidentId);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Report details')),
    body: SafeArea(
      child: StreamBuilder<Incident?>(
        stream: _report,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return IncidentMessage(
              title: 'Report could not load',
              description: 'Check your connection and try again.',
              onRetry: () => setState(_load),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final report = snapshot.data;
          if (report == null) {
            return const IncidentMessage(
              title: 'Report unavailable',
              description: 'This report may have been removed.',
            );
          }
          return _DetailsContent(
            report: report,
            isOwner: report.reportedBy == widget.viewerUid,
          );
        },
      ),
    ),
  );
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({required this.report, required this.isOwner});

  final Incident report;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IncidentStatusBadge(status: report.status),
                Text(report.category.label, style: text.titleSmall),
                if (isOwner) const Text('Your report'),
              ],
            ),
            const SizedBox(height: 24),
            Text(report.title, style: text.headlineSmall),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(report.location, style: text.bodyLarge),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text('Description', style: text.titleMedium),
            const SizedBox(height: 8),
            SelectableText(report.description, style: text.bodyLarge),
            const SizedBox(height: 28),
            Text('Progress', style: text.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  for (final status in IncidentStatus.values)
                    ListTile(
                      leading: Icon(
                        status.index <= report.status.index
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: status == report.status
                            ? AppColors.yellow
                            : status.index < report.status.index
                            ? AppColors.ink
                            : AppColors.muted,
                      ),
                      title: Text(status.label),
                      subtitle: status == report.status
                          ? const Text('Current status')
                          : null,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Submitted', style: text.titleSmall),
            Text(formatIncidentDate(report.createdAt), style: text.bodyMedium),
            const SizedBox(height: 16),
            Text('Last updated', style: text.titleSmall),
            Text(formatIncidentDate(report.updatedAt), style: text.bodyMedium),
            const SizedBox(height: 24),
            Text('Report reference', style: text.titleSmall),
            const SizedBox(height: 8),
            SelectableText(report.id),
          ],
        ),
      ),
    );
  }
}
