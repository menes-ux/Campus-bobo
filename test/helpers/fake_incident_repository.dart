import 'dart:async';

import 'package:campus_bobo/features/incidents/domain/incident_draft.dart';
import 'package:campus_bobo/features/incidents/domain/incident_repository.dart';

class FakeIncidentRepository implements IncidentRepository {
  int submitCalls = 0;
  IncidentDraft? savedDraft;
  String? reportedBy;
  IncidentFailure? failure;
  Completer<String>? pending;

  @override
  Future<String> submit(IncidentDraft draft, String reportedBy) async {
    submitCalls++;
    if (failure != null) throw failure!;
    savedDraft = draft;
    this.reportedBy = reportedBy;
    return pending == null ? 'incident-test-1' : await pending!.future;
  }
}
