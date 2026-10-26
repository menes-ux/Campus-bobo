import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../incidents/domain/incident.dart';
import '../../incidents/domain/incident_repository.dart';
import '../../incidents/domain/incident_status.dart';

class DashboardController extends ChangeNotifier {
  DashboardController(this._repository, this.viewerUid) {
    retry();
  }

  final IncidentRepository _repository;
  final String viewerUid;
  StreamSubscription<List<Incident>>? _subscription;
  List<Incident> _reports = const [];
  bool _loading = true;
  bool _disposed = false;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;
  int get myReportCount =>
      _reports.where((report) => report.reportedBy == viewerUid).length;
  int count(IncidentStatus status) => _reports
      .where(
        (report) => report.reportedBy == viewerUid && report.status == status,
      )
      .length;
  List<Incident> get recentReports => _reports.take(3).toList(growable: false);

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
        _error = 'We could not load your report summary. Check your connection and try again.';
        _notify();
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
