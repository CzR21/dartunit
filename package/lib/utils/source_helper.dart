/// Source-text utilities used by the regex parsers.
class SourceHelper {

  SourceHelper._();

  /// Builds a list of character offsets for each line start in [content].
  ///
  /// Index 0 always holds offset 0 (beginning of file = line 1).
  /// Used by [lineAt] to convert a character offset to a 1-based line number.
  static List<int> buildLineOffsets(String content) {
    final offsets = [0];
    for (var i = 0; i < content.length; i++) {
      if (content[i] == '\n') offsets.add(i + 1);
    }
    return offsets;
  }

  /// Converts a character [position] to a 1-based line number.
  ///
  /// Uses binary search on the pre-built [offsets] list for O(log n) lookup.
  static int lineAt(List<int> offsets, int position) {
    var lo = 0;
    var hi = offsets.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (offsets[mid] <= position) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo + 1;
  }

  static final _annotationRegex = RegExp(r'@(\w+)');

  /// Extracts annotation names (without the leading `@`) from a raw
  /// annotation block string such as `@immutable @override`.
  static List<String> extractAnnotationNames(String raw) {
    return _annotationRegex
        .allMatches(raw)
        .map((m) => m.group(1)!)
        .toList();
  }

  /// Extracts the body of a class declaration starting at [classStart].
  ///
  /// Uses brace counting so nested anonymous functions and inner classes are
  /// handled correctly. Returns an empty string if no balanced body is found.
  static String extractClassBody(String content, int classStart) {
    var depth = 0;
    var bodyStart = -1;

    for (var i = classStart; i < content.length; i++) {
      if (content[i] == '{') {
        depth++;
        if (bodyStart == -1) bodyStart = i + 1;
      } else if (content[i] == '}') {
        depth--;
        if (depth == 0 && bodyStart != -1) {
          return content.substring(bodyStart, i);
        }
      }
    }
    return '';
  }
}
