import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/incident.dart';
import '../domain/incident_category.dart';
import '../domain/incident_draft.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_status.dart';

class FirestoreIncidentRepository implements IncidentRepository {
  FirestoreIncidentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Incident? _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return null;
    return Incident(
      id: snapshot.id,
      reportedBy: data['reportedBy'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      location: data['location'] as String,
      category: IncidentCategory.values.byName(data['category'] as String),
      status: IncidentStatus.values.firstWhere(
        (status) => status.value == data['status'],
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<Incident>> watchAll() => _firestore
      .collection('incidents')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((document) => _fromSnapshot(document)!)
            .toList(growable: false),
      );

  @override
  Stream<Incident?> watchById(String id) =>
      _firestore.collection('incidents').doc(id).snapshots().map(_fromSnapshot);

  @override
  Future<String> submit(IncidentDraft draft, String reportedBy) async {
    final validation = draft.validationError;
    if (validation != null) throw IncidentFailure(validation);
    final reference = _firestore.collection('incidents').doc();
    try {
      await reference.set({
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
      throw _failure(error);
    }
  }

  Map<String, Object> _editableFields(IncidentDraft draft) => {
    'title': draft.title,
    'description': draft.description,
    'location': draft.location,
    'category': draft.category.name,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  @override
  Future<void> update(String id, IncidentDraft draft) async {
    if (draft.validationError != null) {
      throw IncidentFailure(draft.validationError!);
    }
    try {
      await _firestore
          .collection('incidents')
          .doc(id)
          .update(_editableFields(draft));
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> updateStatus(String id, IncidentStatus status) async {
    try {
      await _firestore.collection('incidents').doc(id).update({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  @override
  Future<void> delete(String id) async {
    final reference = _firestore.collection('incidents').doc(id);
    try {
      await reference.delete();
    } on FirebaseException catch (error) {
      throw _failure(error);
    }
  }

  IncidentFailure _failure(FirebaseException error) => IncidentFailure(
    switch (error.code) {
      'permission-denied' || 'unauthenticated' =>
        'You do not have permission for this action. '
            'The report may have changed; reopen it and try again.',
      'unavailable' || 'deadline-exceeded' =>
        'Check your connection and try again.',
      'not-found' => 'This report is no longer available.',
      _ => 'We could not save this change. Please try again.',
    },
  );
}
