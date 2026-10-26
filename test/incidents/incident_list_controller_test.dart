import 'package:campus_bobo/features/incidents/application/incident_list_controller.dart';
import 'package:campus_bobo/features/incidents/domain/incident_category.dart';
import 'package:campus_bobo/features/incidents/domain/incident_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_incident_repository.dart';
import '../helpers/incident_fixtures.dart';

void main() {
  late FakeIncidentRepository repository;
  late IncidentListController list;

  setUp(() async {
    repository = FakeIncidentRepository()..reports = incidentFixtures();
    list = IncidentListController(repository, 'student-1');
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    list.dispose();
    await repository.close();
  });

  test('Search, category, status, and owner filters combine and reset', () {
    expect(list.visibleReports.length, 3);
    list.setCategory(IncidentCategory.water);
    expect(list.visibleReports.length, 2);
    list.setStatus(IncidentStatus.submitted);
    list.setQuery(' ENTRANCE ');
    list.setOnlyMine(true);
    expect(list.visibleReports.single.id, 'water-1');
    list.setStatus(IncidentStatus.inProgress);
    expect(list.visibleReports, isEmpty);
    list.clearFilters();
    expect(list.visibleReports.length, 3);
    expect(list.hasFilters, isFalse);
  });

  test('A new snapshot updates the currently filtered results', () async {
    list.setOnlyMine(true);
    expect(list.visibleReports.length, 2);
    repository.emitReports([incidentFixtures()[1]]);
    await Future<void>.delayed(Duration.zero);
    expect(list.visibleReports, isEmpty);
    list.setOnlyMine(false);
    expect(list.visibleReports.single.id, 'chair-1');
  });

  test(
    'Stream errors clear reports and retry restores the current data',
    () async {
      repository.emitError();
      await Future<void>.delayed(Duration.zero);
      expect(list.visibleReports, isEmpty);
      expect(list.error, contains('connection'));
      list.retry();
      await Future<void>.delayed(Duration.zero);
      expect(list.error, isNull);
      expect(list.visibleReports.length, 3);
    },
  );
}
