import '../core/extensions/string_extensions.dart';
import 'terminal_helper.dart';

/// Constructs table borders and rows, using Unicode box-drawing characters
/// on capable terminals and plain ASCII on others.
class TableHelper {
  TableHelper._();

  static bool get _unicode => TerminalHelper.supportsUnicode;

  /// Top border:  ┌───┬───┐  or  +---+---+
  static String borderTop(List<int> cols) => _unicode
      ? '┌${cols.map((w) => '─' * w).join('┬')}┐'
      : '+${cols.map((w) => '-' * w).join('+')}+';

  /// Middle border: ├───┼───┤  or  +---+---+
  static String borderMid(List<int> cols) => _unicode
      ? '├${cols.map((w) => '─' * w).join('┼')}┤'
      : '+${cols.map((w) => '-' * w).join('+')}+';

  /// Bottom border: └───┴───┘  or  +---+---+
  static String borderBot(List<int> cols) => _unicode
      ? '└${cols.map((w) => '─' * w).join('┴')}┘'
      : '+${cols.map((w) => '-' * w).join('+')}+';

  /// Builds a row: │cell│cell│  or  |cell|cell|
  ///
  /// Each cell is padded / truncated to its column width using
  /// [String.padEndToWidth]. The caller is responsible for pre-formatting
  /// cell content (leading spaces, color codes, etc.).
  static String row(List<String> cells, List<int> widths) {
    final sep = _unicode ? '│' : '|';
    final buf = StringBuffer(sep);
    for (var i = 0; i < cells.length; i++) {
      buf.write('${cells[i].padEndToWidth(widths[i])}$sep');
    }
    return buf.toString();
  }
}
