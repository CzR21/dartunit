import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart' hide ExitCode;
import 'package:path/path.dart' as p;

import '../../engine/analysis_logger.dart';
import '../../utils/banner_helper.dart';
import '../../utils/terminal_helper.dart';
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
    final logger = Logger();
    final reporter = ConsoleReporter(logger: logger, useColor: useColor);

    BannerHelper.printBanner(logger);

    final sep = TerminalHelper.supportsUnicode ? '─' : '-';
    logger.detail('  Project  $projectRoot');
    logger.detail('  ${sep * 64}');
    logger.info('');

    final entries = AnalysisLogger(projectRoot).load();

    if (entries.isEmpty) {
      logger.info(logNoHistory);
      logger.info('');
      return ExitCode.success;
    }

    logger.info(white.wrap(logHeader(entries.length)) ?? logHeader(entries.length));
    logger.info('');

    for (var i = entries.length; i >= 1; i--) {
      final entry = entries[i - 1];
      stdout.writeln(runHeader(i, entry.timestamp, entry.rulesCount));
      reporter.report(entry.violations);
      logger.info('');
    }

    return ExitCode.success;
  }
}
