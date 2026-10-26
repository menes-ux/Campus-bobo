import 'package:campus_bobo/features/incidents/domain/incident.dart';
import 'package:campus_bobo/features/incidents/domain/incident_category.dart';
import 'package:campus_bobo/features/incidents/domain/incident_status.dart';

List<Incident> incidentFixtures() => [
  Incident(
    id: 'water-1',
    reportedBy: 'student-1',
    title: 'Leaking tap',
    description: 'The tap beside the entrance keeps leaking.',
    location: 'Block A',
    category: IncidentCategory.water,
    status: IncidentStatus.submitted,
    createdAt: DateTime(2026, 10, 26),
    updatedAt: DateTime(2026, 10, 26),
  ),
  Incident(
    id: 'chair-1',
    reportedBy: 'student-2',
    title: 'Broken chair',
    description: 'A chair leg is loose and unsafe to sit on.',
    location: 'Room 204',
    category: IncidentCategory.furniture,
    status: IncidentStatus.inProgress,
    createdAt: DateTime(2026, 10, 25),
    updatedAt: DateTime(2026, 10, 26),
  ),
  Incident(
    id: 'water-2',
    reportedBy: 'student-1',
    title: 'Water shortage',
    description: 'No water in the washroom this morning.',
    location: 'Block B',
    category: IncidentCategory.water,
    status: IncidentStatus.resolved,
    createdAt: DateTime(2026, 10, 24),
    updatedAt: DateTime(2026, 10, 25),
  ),
];
