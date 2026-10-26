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
    expect(dashboard.myReportCount, 2);
    expect(dashboard.count(IncidentStatus.submitted), 1);
    expect(dashboard.count(IncidentStatus.inProgress), 0);
    expect(dashboard.count(IncidentStatus.resolved), 1);
    expect(dashboard.recentReports.length, 3);
  });

  test('Summary counts update from the live report stream', () async {
    repository.emitReports([incidentFixtures()[0]]);
    await Future<void>.delayed(Duration.zero);
    expect(dashboard.myReportCount, 1);
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
    expect(dashboard.myReportCount, 2);
  });
}
