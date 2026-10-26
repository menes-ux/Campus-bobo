import 'incident.dart';
import 'incident_draft.dart';
import 'incident_status.dart';

abstract interface class IncidentRepository {
  Future<String> submit(IncidentDraft draft, String reportedBy);
  Future<void> update(String id, IncidentDraft draft);
  Future<void> delete(String id);
  Future<void> updateStatus(String id, IncidentStatus status);
  Stream<List<Incident>> watchAll();
  Stream<Incident?> watchById(String id);
}

class IncidentFailure implements Exception {
  const IncidentFailure(this.message);

  final String message;
}
