import 'incident.dart';
import 'incident_draft.dart';

abstract interface class IncidentRepository {
  Future<String> submit(IncidentDraft draft, String reportedBy);
  Stream<List<Incident>> watchAll();
  Stream<Incident?> watchById(String id);
}

class IncidentFailure implements Exception {
  const IncidentFailure(this.message);

  final String message;
}
