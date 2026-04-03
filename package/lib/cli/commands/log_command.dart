import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../engine/analysis_logger.dart';
import '../../utils/ansi_helper.dart';
import '../../utils/banner_helper.dart';
import '../../reporter/console_reporter.dart';
import '../../core/enums/exit_code.dart';
import '../texts/log_text.dart';

class LogCommand extends Command<ExitCode> {
  @override
  final String name = 'log';

  @override
  final String description =
      'Show the last ${AnalysisLogger.maxEntries} analysis run results.';

  LogCommand() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the target project (defaults to current directory).',
        defaultsTo: '.',
      )
      ..addFlag(
        'no-color',
        help: 'Disable colored output.',
        defaultsTo: false,
      );
  }

  @override
  Future<ExitCode> run() async {
    final projectRoot = p.normalize(p.absolute(argResults!['path'] as String));
    final useColor = !(argResults!['no-color'] as bool);
    final reporter = ConsoleReporter(useColor: useColor);

    BannerHelper.printBanner(useColor);

    stdout.writeln('  ${ANSIHelper.dim('Project', useColor)}  $projectRoot');
    stdout.writeln(ANSIHelper.dim('  ${'─' * 64}', useColor));
    stdout.writeln();

    final entries = AnalysisLogger(projectRoot).load();

    if (entries.isEmpty) {
      stdout.writeln('  ${ANSIHelper.cyan('◆', useColor)} $logNoHistory');
      stdout.writeln();
      return ExitCode.success;
    }

    stdout.writeln(
        '  ${ANSIHelper.bold(logHeader(entries.length), useColor)}');
    stdout.writeln();

    for (var i = entries.length; i >= 1; i--) {
      final entry = entries[i - 1];
      stdout.writeln(
          runHeader(i, entry.timestamp, entry.rulesCount, useColor));
      reporter.report(entry.violations);
      stdout.writeln();
    }

    return ExitCode.success;
  }
}
