import 'dart:io';
import '../core/entities/violation.dart';
import '../core/extensions/violation_list_extension.dart';
import '../utils/ansi_helper.dart';
import '../core/extensions/string_extensions.dart';
import '../utils/table_helper.dart';
import '../core/enums/report_column.dart';
import 'violation_summary.dart';

/// Writes the violations report to stdout as an ASCII table.
class ConsoleReporter {

  final bool useColor;

  ConsoleReporter({this.useColor = true});

  void report(List<Violation> violations) {
    stdout.writeln();

    if (violations.isEmpty) {
      _write('  ✓ No architecture violations found.', ANSIHelper.kGreen);
      stdout.writeln();
      return;
    }

    _renderTable(violations.sortedBySeverity());
    _renderSummary(ViolationSummary.from(violations));
  }

  void _renderTable(List<Violation> violations) {
    final widths = ReportColumn.widths;
    stdout.writeln('  ${TableHelper.borderTop(widths)}');
    stdout.writeln('  ${TableHelper.row(ReportColumn.headers, widths)}');
    stdout.writeln('  ${TableHelper.borderMid(widths)}');
    for (final v in violations) {
      stdout.writeln('  ${_dataRow(v)}');
    }
    stdout.writeln('  ${TableHelper.borderBot(widths)}');
  }

  String _dataRow(Violation v) {
    final sevPlain = ' ${v.severity.label}'
        .padEndToWidth(ReportColumn.severity.width);
    final sevCell = useColor
        ? '${v.severity.ansiColor}$sevPlain${ANSIHelper.reset}'
        : sevPlain;
    final descPlain = ' ${v.ruleDescription.truncate(ReportColumn.description.width - 2)}'
        .padEndToWidth(ReportColumn.description.width);
    final filePlain = ' ${v.filePath.shortenProjectPath(ReportColumn.file.width - 2)}'
        .padEndToWidth(ReportColumn.file.width);
    final linePlain = ' ${v.line ?? '─'}'
        .padEndToWidth(ReportColumn.line.width);
    final msgPlain = ' ${v.message.truncate(ReportColumn.message.width - 2)}'
        .padEndToWidth(ReportColumn.message.width);

    return '│$sevCell│$descPlain│$filePlain│$linePlain│$msgPlain│';
  }

  void _renderSummary(ViolationSummary summary) {
    _write('  ${summary.line}', summary.hasFailures ? ANSIHelper.kRed : ANSIHelper.kYellow,);
    stdout.writeln();
  }

  void _write(String text, [String color = '']) {
    if (color.isNotEmpty && useColor) {
      stdout.writeln('$color$text${ANSIHelper.reset}');
    } else {
      stdout.writeln(text);
    }
  }
}
