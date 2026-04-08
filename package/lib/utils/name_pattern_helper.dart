/// Translates user-friendly [prefix]/[suffix] into a regex pattern.
///
/// This helper provides a friendlier alternative to writing raw regex in
/// [namePattern]. The two approaches are mutually exclusive — passing
/// [namePattern] together with [prefix] or [suffix] throws an [AssertionError].
String? resolveNamePattern({
  String? namePattern,
  String? prefix,
  String? suffix,
}) {
  assert(
    namePattern == null || (prefix == null && suffix == null),
    'Use namePattern OR prefix/suffix, not both.',
  );

  if (namePattern != null) return namePattern;
  if (prefix == null && suffix == null) return null;

  final p = prefix != null ? '^${RegExp.escape(prefix)}' : '';
  final middle = '.*';
  final s = suffix != null ? '${RegExp.escape(suffix)}\$' : '';

  return '$p$middle$s';
}
