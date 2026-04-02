import '../core/extensions/string_extensions.dart';

/// Constructs ASCII table borders and rows using box-drawing characters.
class TableHelper {

  TableHelper._();

  /// Top border:  ┌───┬───┐
  static String borderTop(List<int> cols) => '┌${cols.map((w) => '─' * w).join('┬')}┐';

  /// Middle border: ├───┼───┤
  static String borderMid(List<int> cols) => '├${cols.map((w) => '─' * w).join('┼')}┤';

  /// Bottom border: └───┴───┘
  static String borderBot(List<int> cols) => '└${cols.map((w) => '─' * w).join('┴')}┘';

  /// Builds a plain row: │cell│cell│cell│
  ///
  /// Each cell is padded / truncated to its column width using
  /// [String.padEndToWidth]. The caller is responsible for pre-formatting
  /// the cell content (leading spaces, color codes, etc.).
  static String row(List<String> cells, List<int> widths) {
    final buf = StringBuffer('│');
    for (var i = 0; i < cells.length; i++) {
      buf.write('${cells[i].padEndToWidth(widths[i])}│');
    }
    return buf.toString();
  }
}
