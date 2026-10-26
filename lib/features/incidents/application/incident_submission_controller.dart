import 'package:flutter/foundation.dart';

import '../domain/incident_draft.dart';
import '../domain/incident_repository.dart';

class IncidentSubmissionController extends ChangeNotifier {
  IncidentSubmissionController(this._repository);

  final IncidentRepository _repository;
  bool _submitting = false;
  bool _disposed = false;
  String? _error;
  String? _reportId;

  bool get isSubmitting => _submitting;
  String? get error => _error;
  String? get reportId => _reportId;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> submit(
    IncidentDraft draft,
    String reportedBy, {
    String? editingId,
  }) async {
    if (_submitting || _reportId != null || _disposed) return false;
    _error = draft.validationError;
    if (_error != null) {
      _notify();
      return false;
    }
    _submitting = true;
    _notify();
    try {
      if (editingId == null) {
        _reportId = await _repository.submit(draft, reportedBy);
      } else {
        await _repository.update(editingId, draft);
        _reportId = editingId;
      }
      return true;
    } on IncidentFailure catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'We could not save your report. Please try again.';
      return false;
    } finally {
      _submitting = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
