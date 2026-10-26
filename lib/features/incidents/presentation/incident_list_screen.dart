import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/verified_session_guard.dart';
import '../../profile/domain/user_profile.dart';
import '../application/incident_list_controller.dart';
import '../domain/incident_category.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_status.dart';
import 'incident_card.dart';
import 'incident_widgets.dart';
import 'report_details_screen.dart';
import 'report_incident_screen.dart';

class IncidentListScreen extends StatelessWidget {
  const IncidentListScreen({
    super.key,
    required this.viewer,
    this.initiallyOnlyMine = false,
    this.initialStatus,
  });

  final UserProfile viewer;
  final bool initiallyOnlyMine;
  final IncidentStatus? initialStatus;

  @override
  Widget build(BuildContext context) {
    return VerifiedSessionGuard(
      uid: viewer.uid,
      child: ChangeNotifierProvider(
        create: (_) =>
            IncidentListController(
                context.read<IncidentRepository>(),
                viewer.uid,
              )
              ..setOnlyMine(initiallyOnlyMine)
              ..setStatus(initialStatus),
        child: _ReportBrowser(viewer: viewer),
      ),
    );
  }
}

class _ReportBrowser extends StatefulWidget {
  const _ReportBrowser({required this.viewer});

  final UserProfile viewer;

  @override
  State<_ReportBrowser> createState() => _ReportBrowserState();
}

class _ReportBrowserState extends State<_ReportBrowser> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<IncidentListController>();
    final reports = list.visibleReports;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Campus reports')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.ink,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ReportIncidentScreen(reporter: widget.viewer),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New report'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Campus, in focus.', style: text.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          'Reports from your campus community.',
                          style: text.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          key: const ValueKey('report-search'),
                          controller: _search,
                          onChanged: list.setQuery,
                          decoration: InputDecoration(
                            labelText: 'Search reports',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () {
                                      _search.clear();
                                      list.setQuery('');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: const ValueKey('report-category-filter'),
                                initialValue: list.category?.name ?? 'all',
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  contentPadding: EdgeInsets.all(14),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'All categories',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  for (final category
                                      in IncidentCategory.values)
                                    DropdownMenuItem(
                                      value: category.name,
                                      child: Text(
                                        category.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                                onChanged: (value) => list.setCategory(
                                  value == null || value == 'all'
                                      ? null
                                      : IncidentCategory.values.byName(value),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: const ValueKey('report-status-filter'),
                                initialValue: list.status?.value ?? 'all',
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  contentPadding: EdgeInsets.all(14),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'All statuses',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  for (final status in IncidentStatus.values)
                                    DropdownMenuItem(
                                      value: status.value,
                                      child: Text(
                                        status.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                                onChanged: (value) => list.setStatus(
                                  value == null || value == 'all'
                                      ? null
                                      : IncidentStatus.values.firstWhere(
                                          (status) => status.value == value,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FilterChip(
                              label: const Text('My reports'),
                              selected: list.onlyMine,
                              selectedColor: AppColors.paleYellow,
                              onSelected: list.setOnlyMine,
                            ),
                            if (list.hasFilters)
                              TextButton(
                                onPressed: () {
                                  _search.clear();
                                  list.clearFilters();
                                },
                                child: const Text('Reset filters'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          list.isLoading
                              ? 'Loading reports...'
                              : '${reports.length} ${reports.length == 1 ? 'report' : 'reports'}',
                          style: text.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (list.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (list.error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: IncidentMessage(
                      title: 'Reports could not load',
                      description: list.error!,
                      onRetry: list.retry,
                    ),
                  )
                else if (reports.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: IncidentMessage(
                      title: list.hasFilters
                          ? 'No matching reports'
                          : 'No reports yet',
                      description: list.hasFilters
                          ? 'Try another search or reset the filters.'
                          : 'Submitted campus reports will appear here.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    sliver: SliverList.separated(
                      itemCount: reports.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) => IncidentCard(
                        report: reports[index],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ReportDetailsScreen(
                              incidentId: reports[index].id,
                              viewer: widget.viewer,
                            ),
                          ),
                        ),
                      ),
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
