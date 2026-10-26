import 'incident_draft.dart';

abstract interface class IncidentRepository {
  Future<String> submit(IncidentDraft draft, String reportedBy);
}

class IncidentFailure implements Exception {
  const IncidentFailure(this.message);

  final String message;
}
