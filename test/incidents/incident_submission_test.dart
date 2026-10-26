import 'dart:async';

import 'package:campus_bobo/features/incidents/application/incident_submission_controller.dart';
import 'package:campus_bobo/features/incidents/domain/incident_category.dart';
import 'package:campus_bobo/features/incidents/domain/incident_draft.dart';
import 'package:campus_bobo/features/incidents/domain/incident_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_incident_repository.dart';

void main() {
  IncidentDraft validDraft() => IncidentDraft(
    title: ' Broken tap ',
    description: ' The tap is leaking near the entrance. ',
    location: ' Block A ',
    category: IncidentCategory.water,
  );

  test('Invalid report content is rejected before writing', () async {
    final repository = FakeIncidentRepository();
    final submission = IncidentSubmissionController(repository);
    addTearDown(submission.dispose);
    final draft = IncidentDraft(
      title: ' ',
      description: 'Too short',
      location: 'A',
      category: IncidentCategory.facilities,
    );
    expect(await submission.submit(draft, 'student-1'), isFalse);
    expect(repository.submitCalls, 0);
    expect(submission.error, isNotNull);
  });

  test(
    'Successful submission trims content and retains its owner and reference',
    () async {
      final repository = FakeIncidentRepository();
      final submission = IncidentSubmissionController(repository);
      addTearDown(submission.dispose);
      expect(await submission.submit(validDraft(), 'student-1'), isTrue);
      expect(repository.savedDraft!.title, 'Broken tap');
      expect(repository.savedDraft!.location, 'Block A');
      expect(repository.reportedBy, 'student-1');
      expect(submission.reportId, 'incident-test-1');
      expect(await submission.submit(validDraft(), 'student-1'), isFalse);
      expect(repository.submitCalls, 1);
    },
  );

  test('Repeated taps do not start another pending submission', () async {
    final repository = FakeIncidentRepository()..pending = Completer<String>();
    final submission = IncidentSubmissionController(repository);
    addTearDown(submission.dispose);
    final first = submission.submit(validDraft(), 'student-1');
    expect(submission.isSubmitting, isTrue);
    expect(await submission.submit(validDraft(), 'student-1'), isFalse);
    expect(repository.submitCalls, 1);
    repository.pending!.complete('incident-test-2');
    await first;
    expect(submission.isSubmitting, isFalse);
  });

  test('Failed saves release loading state and allow retry', () async {
    final repository = FakeIncidentRepository()
      ..failure = const IncidentFailure('Check your connection and try again.');
    final submission = IncidentSubmissionController(repository);
    addTearDown(submission.dispose);
    expect(await submission.submit(validDraft(), 'student-1'), isFalse);
    expect(submission.isSubmitting, isFalse);
    expect(submission.reportId, isNull);
    expect(submission.error, contains('connection'));
    repository.failure = null;
    expect(await submission.submit(validDraft(), 'student-1'), isTrue);
    expect(submission.error, isNull);
  });
}
