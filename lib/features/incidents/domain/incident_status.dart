enum IncidentStatus {
  submitted('submitted', 'Submitted'),
  inProgress('in_progress', 'In progress'),
  resolved('resolved', 'Resolved');

  const IncidentStatus(this.value, this.label);

  final String value;
  final String label;
}
