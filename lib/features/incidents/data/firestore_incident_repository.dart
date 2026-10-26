import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/incident_draft.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_status.dart';

class FirestoreIncidentRepository implements IncidentRepository {
  FirestoreIncidentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<String> submit(IncidentDraft draft, String reportedBy) async {
    final validation = draft.validationError;
    if (validation != null) throw IncidentFailure(validation);
    try {
      final reference = await _firestore.collection('incidents').add({
        'reportedBy': reportedBy,
        'title': draft.title,
        'description': draft.description,
        'location': draft.location,
        'category': draft.category.name,
        'status': IncidentStatus.submitted.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return reference.id;
    } on FirebaseException catch (error) {
      throw IncidentFailure(switch (error.code) {
        'permission-denied' || 'unauthenticated' => 'Your account could not submit this report. Please sign out and sign in again.',
        'unavailable' ||
        'deadline-exceeded' => 'Check your connection and try again.',
        _ => 'We could not save your report. Please try again.',
      });
    }
  }
}
