/// Table formatting and path display extensions on [String].
extension StringTableFormat on String {

  /// Truncates the string to [maxLen] visible characters, appending [ellipsis]
  /// if the string is longer. Returns the string unchanged if within limit.
  String truncate(int maxLen, {String ellipsis = '…'}) {
    if (length <= maxLen) return this;
    return '${substring(0, maxLen - ellipsis.length)}$ellipsis';
  }

  /// Pads the string to exactly [width] characters using [padRight], or
  /// hard-truncates it if already longer. Suitable for fixed-width table cells.
  String padEndToWidth(int width) => length >= width ? substring(0, width) : padRight(width);

  /// Shortens a file path for display inside a report column of [maxLen] chars.
  ///
  /// Strategy:
  ///   1. If the path contains `lib/`, show from `lib/` onward.
  ///   2. Otherwise show the last two path segments.
  ///   3. Always truncates to [maxLen] if still too long.
  String shortenProjectPath(int maxLen) {
    final norm = replaceAll('\\', '/');
    final libIdx = norm.indexOf('lib/');
    if (libIdx >= 0) return norm.substring(libIdx).truncate(maxLen);
    final parts = norm.split('/');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}/${parts.last}'.truncate(maxLen);
    }
    return norm.truncate(maxLen);
  }
}
