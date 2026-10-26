enum IncidentCategory {
  facilities('Facilities'),
  water('Water'),
  electricity('Electricity'),
  furniture('Furniture'),
  sanitation('Sanitation'),
  safety('Safety');

  const IncidentCategory(this.label);

  final String label;
}
