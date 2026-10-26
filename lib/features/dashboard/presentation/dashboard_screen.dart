import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../incidents/domain/incident_repository.dart';
import '../../incidents/domain/incident_status.dart';
import '../../incidents/presentation/incident_card.dart';
import '../../incidents/presentation/incident_widgets.dart';
import '../../incidents/presentation/report_details_screen.dart';
import '../../profile/domain/user_profile.dart';
import '../application/dashboard_controller.dart';
import 'dashboard_stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.profile,
    required this.onReport,
    required this.onProfile,
    required this.onBrowse,
    required this.onMyReports,
  });

  final UserProfile profile;
  final VoidCallback onReport;
  final VoidCallback onProfile;
  final VoidCallback onBrowse;
  final ValueChanged<IncidentStatus?> onMyReports;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) =>
        DashboardController(context.read<IncidentRepository>(), profile.uid),
    child: _DashboardContent(
      profile: profile,
      onReport: onReport,
      onProfile: onProfile,
      onBrowse: onBrowse,
      onMyReports: onMyReports,
    ),
  );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.profile,
    required this.onReport,
    required this.onProfile,
    required this.onBrowse,
    required this.onMyReports,
  });

  final UserProfile profile;
  final VoidCallback onReport;
  final VoidCallback onProfile;
  final VoidCallback onBrowse;
  final ValueChanged<IncidentStatus?> onMyReports;

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardController>();
    final text = Theme.of(context).textTheme;
    final firstName = profile.displayName.trim().split(RegExp(r'\s+')).first;
    final ready = !dashboard.isLoading && dashboard.error == null;
    String number(int value) => ready ? '$value' : '—';

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              key: const PageStorageKey('dashboard-scroll'),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CAMPUS BOBO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hello, ${firstName.isEmpty ? 'there' : firstName}.',
                            style: text.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Help make our campus better.',
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: onProfile,
                      tooltip: 'Open profile',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.person_outline_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.yellow, Color(0xFFFFDC70)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -24,
                        top: -16,
                        child: ExcludeSemantics(
                          child: Icon(
                            Icons.apartment_rounded,
                            size: 180,
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'See an issue\non campus?',
                              style: text.headlineSmall?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Text(
                                'Report it and help improve the spaces we share.',
                                style: text.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: onReport,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.ink,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Report an incident'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text('Your report summary', style: text.titleLarge),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 600 ? 4 : 2;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: width,
                          child: DashboardStatCard(
                            key: const ValueKey('dashboard-total'),
                            label: 'My reports',
                            value: number(dashboard.myReportCount),
                            icon: Icons.description_outlined,
                            background: AppColors.paleYellow,
                            accent: AppColors.ink,
                            onTap: ready ? () => onMyReports(null) : null,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: DashboardStatCard(
                            key: const ValueKey('dashboard-submitted'),
                            label: 'Submitted',
                            value: number(
                              dashboard.count(IncidentStatus.submitted),
                            ),
                            icon: Icons.inbox_outlined,
                            background: AppColors.paleOrange,
                            accent: AppColors.orange,
                            onTap: ready
                                ? () => onMyReports(IncidentStatus.submitted)
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: DashboardStatCard(
                            key: const ValueKey('dashboard-progress'),
                            label: 'In progress',
                            value: number(
                              dashboard.count(IncidentStatus.inProgress),
                            ),
                            icon: Icons.schedule_outlined,
                            background: AppColors.paleBlue,
                            accent: AppColors.blue,
                            onTap: ready
                                ? () => onMyReports(IncidentStatus.inProgress)
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: DashboardStatCard(
                            key: const ValueKey('dashboard-resolved'),
                            label: 'Resolved',
                            value: number(
                              dashboard.count(IncidentStatus.resolved),
                            ),
                            icon: Icons.check_circle_outline_rounded,
                            background: AppColors.paleGreen,
                            accent: AppColors.green,
                            onTap: ready
                                ? () => onMyReports(IncidentStatus.resolved)
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent campus reports',
                        style: text.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: onBrowse,
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (dashboard.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (dashboard.error != null)
                  SizedBox(
                    height: 240,
                    child: IncidentMessage(
                      title: 'Summary unavailable',
                      description: dashboard.error!,
                      onRetry: dashboard.retry,
                    ),
                  )
                else if (dashboard.recentReports.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'No campus reports yet. You can be the first to report an issue.',
                    ),
                  )
                else
                  for (final report in dashboard.recentReports) ...[
                    IncidentCard(
                      report: report,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReportDetailsScreen(
                            incidentId: report.id,
                            viewerUid: profile.uid,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
