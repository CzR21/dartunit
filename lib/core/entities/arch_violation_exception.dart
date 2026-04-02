/// Thrown by [ArchMatcher] when violations are found.
/// Caught by [testArch] so that [fail] is called outside of [expect],
/// preventing the default Expected/Actual/Which block from appearing.
class ArchViolationException implements Exception {
  const ArchViolationException();
}
