import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import '../core/entities/violation.dart';
import '../core/extensions/violation_list_extension.dart';
import '../utils/ansi_formatter.dart';
import '../core/extensions/string_extensions.dart';
import '../utils/table_helper.dart';
import '../core/enums/report_column.dart';
import 'violation_summary.dart';

/// Writes the violations report to stdout as an ASCII table.
class ConsoleReporter {

  final Logger _logger;
  final bool useColor;

  ConsoleReporter({required Logger logger, this.useColor = true})
      : _logger = logger;

  void report(List<Violation> violations) {
    stdout.writeln();

    if (violations.isEmpty) {
      _logger.success('No architecture violations found.');
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
        ? '${v.severity.ansiColor}$sevPlain${ANSIFormatter.reset}'
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
    if (summary.hasFailures) {
      _logger.err(summary.line);
    } else {
      _logger.warn(summary.line);
    }
    stdout.writeln();
  }
}
