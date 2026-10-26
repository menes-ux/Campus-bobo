import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/domain/user_profile.dart';
import '../application/incident_submission_controller.dart';
import '../domain/incident_category.dart';
import '../domain/incident_draft.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_status.dart';
import '../domain/incident_validators.dart';

class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key, required this.reporter});

  final UserProfile reporter;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          IncidentSubmissionController(context.read<IncidentRepository>()),
      child: _IncidentForm(reporter: reporter),
    );
  }
}

class _IncidentForm extends StatefulWidget {
  const _IncidentForm({required this.reporter});

  final UserProfile reporter;

  @override
  State<_IncidentForm> createState() => _IncidentFormState();
}

class _IncidentFormState extends State<_IncidentForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _formScroll = ScrollController();
  IncidentCategory? _category;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showFeedback();
      return;
    }
    FocusScope.of(context).unfocus();
    final saved = await context.read<IncidentSubmissionController>().submit(
      IncidentDraft(
        title: _title.text,
        description: _description.text,
        location: _location.text,
        category: _category!,
      ),
      widget.reporter.uid,
    );
    if (mounted && !saved) _showFeedback();
  }

  void _showFeedback() {
    if (_formScroll.hasClients) {
      _formScroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _formScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submission = context.watch<IncidentSubmissionController>();
    final auth = context.watch<AuthController>();
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final signedIn =
        auth.session == AuthSession.verified &&
        auth.user?.uid == widget.reporter.uid;

    return PopScope<Object?>(
      canPop: !submission.isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report an incident'),
          automaticallyImplyLeading: !submission.isSubmitting,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: !signedIn
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Please sign in again before submitting a report.',
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () =>
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst),
                            child: const Text('Back to sign in'),
                          ),
                        ],
                      ),
                    )
                  : submission.reportId != null
                  ? _SubmissionSuccess(reportId: submission.reportId!)
                  : ListView(
                      controller: _formScroll,
                      padding: const EdgeInsets.all(24),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        Text(
                          'What needs\nattention?',
                          style: text.headlineLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Share the details so campus staff can understand the issue and find it.',
                          style: text.bodyLarge?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (submission.error != null) ...[
                          Semantics(
                            liveRegion: true,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.errorContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                submission.error!,
                                style: TextStyle(
                                  color: colors.onErrorContainer,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<IncidentCategory>(
                                key: const ValueKey('incident-category'),
                                initialValue: _category,
                                isExpanded: true,
                                validator: (value) => value == null
                                    ? 'Choose an incident category.'
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(Icons.category_outlined),
                                ),
                                items: [
                                  for (final category
                                      in IncidentCategory.values)
                                    DropdownMenuItem(
                                      value: category,
                                      child: Text(category.label),
                                    ),
                                ],
                                onChanged: submission.isSubmitting
                                    ? null
                                    : (value) =>
                                          setState(() => _category = value),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                key: const ValueKey('incident-title'),
                                controller: _title,
                                enabled: !submission.isSubmitting,
                                validator: IncidentValidators.title,
                                maxLength: 100,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  hintText: 'e.g. Broken tap in Block A',
                                  prefixIcon: Icon(Icons.edit_note_rounded),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('incident-location'),
                                controller: _location,
                                enabled: !submission.isSubmitting,
                                validator: IncidentValidators.location,
                                maxLength: 120,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Location',
                                  hintText: 'Building, floor, or room',
                                  prefixIcon: Icon(Icons.place_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('incident-description'),
                                controller: _description,
                                enabled: !submission.isSubmitting,
                                validator: IncidentValidators.description,
                                maxLength: 2000,
                                minLines: 4,
                                maxLines: 6,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  alignLabelWithHint: true,
                                  hintText: 'What happened? When did you notice it? Who is affected?',
                                ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                key: const ValueKey('incident-submit'),
                                onPressed: submission.isSubmitting
                                    ? null
                                    : _submit,
                                icon: submission.isSubmitting
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward_rounded),
                                label: Text(
                                  submission.isSubmitting
                                      ? 'Submitting...'
                                      : 'Submit report',
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
      ),
    );
  }
}

class _SubmissionSuccess extends StatelessWidget {
  const _SubmissionSuccess({required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.check_rounded, size: 40),
          ),
        ),
        const SizedBox(height: 28),
        Text('Report submitted.', style: text.headlineLarge),
        const SizedBox(height: 12),
        Text(
          'Your report has been saved for campus staff to review.',
          style: text.bodyLarge,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${IncidentStatus.submitted.label}',
                style: text.titleMedium,
              ),
              const SizedBox(height: 16),
              Text('Report reference', style: text.titleSmall),
              const SizedBox(height: 8),
              SelectableText(reportId),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to account'),
        ),
      ],
    );
  }
}
