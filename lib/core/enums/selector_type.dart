/// YAML selector types supported by dartunit.
enum SelectorType {
  classSelector('class'),
  file('file'),
  layer('layer');

  const SelectorType(this.yamlKey);

  /// The string value used in `dartunit.yaml`.
  final String yamlKey;

  /// Returns the matching [SelectorType] for [value], or `null` if unknown.
  static SelectorType? fromString(String? value) {
    if (value == null) return null;
    final matches = SelectorType.values.where((e) => e.yamlKey == value);
    return matches.isEmpty ? null : matches.first;
  }
}


