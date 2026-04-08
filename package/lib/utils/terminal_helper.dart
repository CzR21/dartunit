import 'dart:io';

/// Detects whether the current terminal can reliably render Unicode characters
/// such as box-drawing chars and emoji.
///
/// Used to pick between rich Unicode output and safe ASCII fallback.
class TerminalHelper {
  TerminalHelper._();

  /// `true` when the terminal is expected to render Unicode correctly.
  ///
  /// Heuristic: ANSI colour support is a strong proxy — terminals that handle
  /// escape sequences almost always handle UTF-8 rendering correctly too.
  /// On Windows we additionally accept Windows Terminal (WT_SESSION env var).
  static bool get supportsUnicode {
    if (!stdout.hasTerminal) return false;
    if (stdout.supportsAnsiEscapes) return true;
    if (Platform.isWindows) {
      return Platform.environment.containsKey('WT_SESSION');
    }
    final term = Platform.environment['TERM'] ?? '';
    return term.isNotEmpty && term != 'dumb';
  }
}
