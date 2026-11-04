import 'package:campus_bobo/features/dashboard/application/dashboard_controller.dart';
import 'package:campus_bobo/features/incidents/domain/incident_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_incident_repository.dart';
import '../helpers/incident_fixtures.dart';

void main() {
  late FakeIncidentRepository repository;
  late DashboardController dashboard;

  setUp(() async {
    repository = FakeIncidentRepository()..reports = incidentFixtures();
    dashboard = DashboardController(repository, 'student-1');
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    dashboard.dispose();
    await repository.close();
  });

  test('Personal counts exclude other users while recent activity includes campus reports', () {
    expect(dashboard.reportCount, 2);
    expect(dashboard.count(IncidentStatus.submitted), 1);
    expect(dashboard.count(IncidentStatus.inProgress), 0);
    expect(dashboard.count(IncidentStatus.resolved), 1);
    expect(dashboard.recentReports.length, 3);
  });

  test('Summary counts update from the live report stream', () async {
    repository.emitReports([incidentFixtures()[0]]);
    await Future<void>.delayed(Duration.zero);
    expect(dashboard.reportCount, 1);
    expect(dashboard.count(IncidentStatus.resolved), 0);
    expect(dashboard.recentReports.single.id, 'water-1');
  });

  test('Errors mark the summary unavailable and retry restores it', () async {
    repository.emitError();
    await Future<void>.delayed(Duration.zero);
    expect(dashboard.error, isNotNull);
    expect(dashboard.recentReports, isEmpty);
    dashboard.retry();
    await Future<void>.delayed(Duration.zero);
    expect(dashboard.error, isNull);
    expect(dashboard.reportCount, 2);
  });

  test('Staff summary includes every reporter and review excludes resolved reports', () async {
    final staff = DashboardController(repository, 'staff-1', campusWide: true);
    addTearDown(staff.dispose);
    await Future<void>.delayed(Duration.zero);
    expect(staff.reportCount, 3);
    expect(staff.count(IncidentStatus.submitted), 1);
    expect(staff.count(IncidentStatus.inProgress), 1);
    expect(staff.count(IncidentStatus.resolved), 1);
    expect(staff.reportsToReview.map((report) => report.id), [
      'water-1',
      'chair-1',
    ]);

    await repository.updateStatus('water-1', IncidentStatus.resolved);
    await Future<void>.delayed(Duration.zero);
    expect(staff.count(IncidentStatus.resolved), 2);
    expect(staff.reportsToReview.single.id, 'chair-1');
  });
}
