import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/incident.dart';
import '../domain/incident_category.dart';
import '../domain/incident_repository.dart';
import '../domain/incident_status.dart';

class IncidentListController extends ChangeNotifier {
  IncidentListController(this._repository, this.viewerUid) {
    retry();
  }

  final IncidentRepository _repository;
  final String viewerUid;
  StreamSubscription<List<Incident>>? _subscription;
  List<Incident> _reports = const [];
  bool _loading = true;
  bool _disposed = false;
  String? _error;
  String _query = '';
  IncidentCategory? _category;
  IncidentStatus? _status;
  bool _onlyMine = false;

  bool get isLoading => _loading;
  String? get error => _error;
  IncidentCategory? get category => _category;
  IncidentStatus? get status => _status;
  bool get onlyMine => _onlyMine;
  bool get hasFilters =>
      _query.isNotEmpty || _category != null || _status != null || _onlyMine;

  List<Incident> get visibleReports => _reports
      .where((report) {
        if (_category != null && report.category != _category) return false;
        if (_status != null && report.status != _status) return false;
        if (_onlyMine && report.reportedBy != viewerUid) return false;
        final searchable =
            '${report.title} ${report.description} ${report.location} ${report.id}'
                .toLowerCase();
        return _query.isEmpty || searchable.contains(_query);
      })
      .toList(growable: false);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void retry() {
    final previous = _subscription;
    if (previous != null) unawaited(previous.cancel());
    _loading = true;
    _error = null;
    _notify();
    _subscription = _repository.watchAll().listen(
      (reports) {
        _reports = List.unmodifiable(reports);
        _loading = false;
        _error = null;
        _notify();
      },
      onError: (Object error) {
        _reports = const [];
        _loading = false;
        _error =
            'We could not load reports. Check your connection and try again.';
        _notify();
      },
    );
  }

  void setQuery(String value) {
    _query = value.trim().toLowerCase();
    _notify();
  }

  void setCategory(IncidentCategory? value) {
    _category = value;
    _notify();
  }

  void setStatus(IncidentStatus? value) {
    _status = value;
    _notify();
  }

  void setOnlyMine(bool value) {
    _onlyMine = value;
    _notify();
  }

  void clearFilters() {
    _query = '';
    _category = null;
    _status = null;
    _onlyMine = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
