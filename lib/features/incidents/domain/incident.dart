import 'incident_category.dart';
import 'incident_status.dart';

class Incident {
  const Incident({
    required this.id,
    required this.reportedBy,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String reportedBy;
  final String title;
  final String description;
  final String location;
  final IncidentCategory category;
  final IncidentStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
