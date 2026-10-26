import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/verified_session_guard.dart';
import '../../profile/domain/user_profile.dart';
import '../domain/incident.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_status.dart';
import 'incident_widgets.dart';
import 'report_incident_screen.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({
    super.key,
    required this.incidentId,
    required this.viewer,
  });

  final String incidentId;
  final UserProfile viewer;

  @override
  Widget build(BuildContext context) => VerifiedSessionGuard(
    uid: viewer.uid,
    child: _ReportDetails(incidentId: incidentId, viewer: viewer),
  );
}

class _ReportDetails extends StatefulWidget {
  const _ReportDetails({required this.incidentId, required this.viewer});

  final String incidentId;
  final UserProfile viewer;

  @override
  State<_ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<_ReportDetails> {
  late Stream<Incident?> _report;
  bool _busy = false;

  Future<void> _delete(Incident report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text(
          'This report will be permanently removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => context.read<IncidentRepository>().delete(report.id),
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report deleted.')),
        );
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _run(
    Future<void> Function() action, {
    VoidCallback? onSuccess,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) onSuccess?.call();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is IncidentFailure
                  ? error.message
                  : 'The change could not be saved. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      _report = context.read<IncidentRepository>().watchById(widget.incidentId);

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !_busy,
    child: Scaffold(
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
              isOwner: report.reportedBy == widget.viewer.uid,
              isStaff: widget.viewer.role == UserRole.staff,
              busy: _busy,
              onDelete: () => _delete(report),
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ReportIncidentScreen(
                    reporter: widget.viewer,
                    existing: report,
                  ),
                ),
              ),
              onStatus: (status) => _run(
                () => context.read<IncidentRepository>().updateStatus(
                  report.id,
                  status,
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.report,
    required this.isOwner,
    required this.isStaff,
    required this.busy,
    required this.onDelete,
    required this.onEdit,
    required this.onStatus,
  });

  final Incident report;
  final bool isOwner;
  final bool isStaff;
  final bool busy;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ValueChanged<IncidentStatus> onStatus;

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
            if (isOwner && report.status == IncidentStatus.submitted) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: busy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit report'),
              ),
              TextButton.icon(
                onPressed: busy ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete report'),
              ),
            ],
            if (isStaff) ...[
              const SizedBox(height: 24),
              Text('Staff review', style: text.titleMedium),
              const SizedBox(height: 12),
              if (report.status != IncidentStatus.resolved)
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => onStatus(
                          report.status == IncidentStatus.submitted
                              ? IncidentStatus.inProgress
                              : IncidentStatus.resolved,
                        ),
                  icon: const Icon(Icons.task_alt_rounded),
                  label: Text(
                    report.status == IncidentStatus.submitted
                        ? 'Mark in progress'
                        : 'Mark resolved',
                  ),
                )
              else
                const Text('This report has been resolved.'),
            ],
            if (busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
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
