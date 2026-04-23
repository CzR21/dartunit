import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart' hide ExitCode;
import 'package:path/path.dart' as p;

import '../../engine/analysis_logger.dart';
import '../../engine/test_result_parser.dart';
import '../../reporter/html_report_writer.dart';
import '../../reporter/console_reporter.dart';
import '../../utils/banner_helper.dart';
import '../../utils/terminal_helper.dart';
import '../../core/enums/exit_code.dart';

class AnalyzeCommand extends Command<ExitCode> {
  @override
  final String name = 'analyze';

  @override
  final String description =
      'Analyze the project source code against architecture rules in test_arch/.';

  AnalyzeCommand() {
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
    const resultParser = TestResultParser();
    const htmlWriter = HtmlReportWriter();
    final archTestDir = p.join(projectRoot, 'test_arch');

    BannerHelper.printBanner(logger);

    final sep = TerminalHelper.supportsUnicode ? '─' : '-';
    logger.detail('  Project  $projectRoot');
    logger.detail('  ${sep * 64}');
    logger.info('');

    if (!Directory(archTestDir).existsSync()) {
      logger.err('test_arch/ not found in $projectRoot');
      logger.detail('  Run  dartunit init  to create the test_arch/ folder.');
      logger.info('');
      return ExitCode.error;
    }

    final ruleFiles = Directory(archTestDir)
        .listSync(recursive: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('arch_test.dart'))
        .map((f) => f.path)
        .toList()
      ..sort();

    if (ruleFiles.isEmpty) {
      logger.info('No rule files found in test_arch/');
      logger.detail('  Run  dartunit generate <name>  to scaffold a rule.');
      logger.info('');
      return ExitCode.success;
    }

    final loadProgress = logger.progress('Loading rules...');
    loadProgress.complete('Found ${ruleFiles.length} rule file(s)');

    final evalProgress = logger.progress('Analyzing rules...');

    final result = await Process.run(
      'dart',
      ['test', ...ruleFiles, '--reporter', 'json', '--no-color'],
      workingDirectory: projectRoot,
      environment: {...Platform.environment, 'DARTUNIT_PROTOCOL': '1'},
    );

    final (:violations, :parsedRules) =
        resultParser.parse(result.stderr as String);

    if (parsedRules == 0 && result.exitCode != 0) {
      evalProgress.fail('Analysis failed');
      final err = resultParser.extractRawError(result.stderr as String);
      if (err.isNotEmpty) logger.err('dart test error:\n  $err');
      logger.info('');
      return ExitCode.error;
    }

    evalProgress.complete('Rules analyzed');

    reporter.report(violations);

    final now = DateTime.now();
    AnalysisLogger(projectRoot).save(violations, rulesCount: ruleFiles.length);

    final htmlPath = htmlWriter.write(
      projectRoot: projectRoot,
      violations: violations,
      rulesCount: ruleFiles.length,
      timestamp: now,
    );

    if (htmlPath != null) {
      final fileUri = 'file:///${htmlPath.replaceAll('\\', '/')}';
      logger.detail('  Full report  $fileUri');
      logger.info('');
    }

    final hasFailures = violations.any((v) => v.severity.isFailure);
    return hasFailures ? ExitCode.violations : ExitCode.success;
  }
}
