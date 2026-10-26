abstract final class IncidentValidators {
  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 3) return 'Add a short title of at least 3 characters.';
    if (text.length > 100) return 'Keep the title within 100 characters.';
    return null;
  }

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 10) {
      return 'Describe the issue in at least 10 characters.';
    }
    if (text.length > 2000) {
      return 'Keep the description within 2,000 characters.';
    }
    return null;
  }

  static String? location(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 3) return 'Add a building, room, or campus location.';
    if (text.length > 120) return 'Keep the location within 120 characters.';
    return null;
  }
}
