import 'dart:async';

import 'package:campus_bobo/features/incidents/domain/incident.dart';
import 'package:campus_bobo/features/incidents/domain/incident_draft.dart';
import 'package:campus_bobo/features/incidents/domain/incident_repository.dart';

class FakeIncidentRepository implements IncidentRepository {
  int submitCalls = 0;
  IncidentDraft? savedDraft;
  String? reportedBy;
  IncidentFailure? failure;
  Completer<String>? pending;
  List<Incident> reports = [];
  final _changes = StreamController<List<Incident>>.broadcast(sync: true);

  void emitReports(List<Incident> reports) {
    this.reports = reports;
    _changes.add(List.unmodifiable(reports));
  }

  void emitError() => _changes.addError(StateError('Reports unavailable.'));

  Incident? _find(String id) {
    for (final report in reports) {
      if (report.id == id) return report;
    }
    return null;
  }

  @override
  Stream<List<Incident>> watchAll() async* {
    yield List.unmodifiable(reports);
    yield* _changes.stream;
  }

  @override
  Stream<Incident?> watchById(String id) async* {
    yield _find(id);
    yield* _changes.stream.map((reports) => _find(id));
  }

  Future<void> close() => _changes.close();

  @override
  Future<String> submit(IncidentDraft draft, String reportedBy) async {
    submitCalls++;
    if (failure != null) throw failure!;
    savedDraft = draft;
    this.reportedBy = reportedBy;
    return pending == null ? 'incident-test-1' : await pending!.future;
  }
}
