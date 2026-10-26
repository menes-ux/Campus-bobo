import 'incident_category.dart';
import 'incident_validators.dart';

class IncidentDraft {
  IncidentDraft({
    required String title,
    required String description,
    required String location,
    required this.category,
  }) : title = title.trim(),
       description = description.trim(),
       location = location.trim();

  final String title;
  final String description;
  final String location;
  final IncidentCategory category;

  String? get validationError =>
      IncidentValidators.title(title) ??
      IncidentValidators.description(description) ??
      IncidentValidators.location(location);
}
