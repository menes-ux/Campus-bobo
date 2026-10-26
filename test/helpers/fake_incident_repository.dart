import 'dart:async';

import 'package:campus_bobo/features/incidents/domain/incident.dart';
import 'package:campus_bobo/features/incidents/domain/incident_draft.dart';
import 'package:campus_bobo/features/incidents/domain/incident_repository.dart';
import 'package:campus_bobo/features/incidents/domain/incident_status.dart';

class FakeIncidentRepository implements IncidentRepository {
  int submitCalls = 0;
  IncidentDraft? savedDraft;
  int updateCalls = 0;
  int deleteCalls = 0;
  int statusCalls = 0;
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

  @override
  Future<void> update(String id, IncidentDraft draft) async {
    updateCalls++;
    if (failure != null) throw failure!;
    savedDraft = draft;
    emitReports(
      reports.map((report) {
        if (report.id != id) return report;
        return Incident(
          id: report.id,
          reportedBy: report.reportedBy,
          title: draft.title,
          description: draft.description,
          location: draft.location,
          category: draft.category,
          status: report.status,
          createdAt: report.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList(),
    );
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    if (failure != null) throw failure!;
    emitReports(reports.where((report) => report.id != id).toList());
  }

  @override
  Future<void> updateStatus(String id, IncidentStatus status) async {
    statusCalls++;
    if (failure != null) throw failure!;
    emitReports(
      reports.map((report) {
        if (report.id != id) return report;
        return Incident(
          id: report.id,
          reportedBy: report.reportedBy,
          title: report.title,
          description: report.description,
          location: report.location,
          category: report.category,
          status: status,
          createdAt: report.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList(),
    );
  }

}
