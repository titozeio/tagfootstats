String canonicalizeTeamReference(
  String rawReference,
  Map<String, String> teamNamesById,
) {
  final trimmed = rawReference.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  if (teamNamesById.containsKey(trimmed)) {
    return trimmed;
  }

  final normalized = trimmed.toLowerCase();
  for (final entry in teamNamesById.entries) {
    if (entry.value.trim().toLowerCase() == normalized) {
      return entry.key;
    }
  }

  return trimmed;
}

String resolveTeamName(
  String rawReference,
  Map<String, String> teamNamesById,
) {
  final canonicalReference = canonicalizeTeamReference(
    rawReference,
    teamNamesById,
  );
  return teamNamesById[canonicalReference] ?? rawReference.trim();
}

bool hasValidOpponentReference(String rawReference) {
  return rawReference.trim().isNotEmpty;
}
