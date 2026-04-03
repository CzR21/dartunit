import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../core/entities/violation.dart';
import '../../core/enums/rule_severity.dart';
import '../../engine/analysis_logger.dart';
import '../../utils/ansi_helper.dart';
import '../../utils/banner_helper.dart';
import '../../reporter/console_reporter.dart';
import '../../reporter/html_reporter.dart';
import '../animations/spinner.dart';
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
    final reporter = ConsoleReporter(useColor: useColor);
    final archTestDir = p.join(projectRoot, 'test_arch');

    BannerHelper.printBanner(useColor);

    stdout.writeln('  ${ANSIHelper.dim('Project', useColor)}  $projectRoot');
    stdout.writeln(ANSIHelper.dim('  ${'─' * 64}', useColor));
    stdout.writeln();

    if (!Directory(archTestDir).existsSync()) {
      stdout.writeln(
          '  ${ANSIHelper.red('✗', useColor)} test_arch/ not found in $projectRoot');
      stdout.writeln(ANSIHelper.dim(
          '  Run  dartunit init  to create the test_arch/ folder.', useColor));
      stdout.writeln();
      return ExitCode.error;
    }

    final ruleFiles = Directory(archTestDir)
        .listSync(recursive: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('_arch_test.dart'))
        .map((f) => f.path)
        .toList()
      ..sort();

    if (ruleFiles.isEmpty) {
      stdout.writeln(
          '  ${ANSIHelper.cyan('◆', useColor)} No rule files found in test_arch/');
      stdout.writeln(ANSIHelper.dim(
          '  Run  dartunit generate <name>  to scaffold a rule.', useColor));
      stdout.writeln();
      return ExitCode.success;
    }

    final rulesSpinner = Spinner('Loading rules...', useColor: useColor)..start();
    rulesSpinner.stop(doneMessage: 'Found ${ruleFiles.length} rule file(s)');

    final evalSpinner = Spinner('Analyzing rules...', useColor: useColor)..start();

    final result = await Process.run(
      'dart',
      ['test', ...ruleFiles, '--reporter', 'json', '--no-color'],
      workingDirectory: projectRoot,
      environment: {...Platform.environment, 'DARTUNIT_PROTOCOL': '1'},
    );

    final allViolations = <Violation>[];
    int parsedRules = 0;

    for (final line in (result.stderr as String).split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('DARTUNIT_RESULT:')) continue;
      try {
        final json = jsonDecode(trimmed.substring('DARTUNIT_RESULT:'.length))
            as Map<String, dynamic>;
        parsedRules++;
        final violations =
            (json['violations'] as List).cast<Map<String, dynamic>>();
        for (final v in violations) {
          allViolations.add(Violation(
            ruleDescription: v['ruleDescription'] as String,
            message: v['message'] as String,
            filePath: v['filePath'] as String,
            severity: RuleSeverity.fromString(v['severity'] as String),
            line: v['line'] as int?,
          ));
        }
      } catch (_) {
        // Malformed line — skip.
      }
    }

    if (parsedRules == 0 && result.exitCode != 0) {
      evalSpinner.stop(doneMessage: 'Analysis failed');
      final err = (result.stderr as String)
          .split('\n')
          .where((l) => !l.startsWith('DARTUNIT_RESULT:'))
          .join('\n')
          .trim();
      if (err.isNotEmpty) {
        stdout.writeln(
            '\n  ${ANSIHelper.red('✗', useColor)} dart test error:\n  $err');
      }
      stdout.writeln();
      return ExitCode.error;
    }

    evalSpinner.stop(doneMessage: 'Rules analyzed');

    stdout.writeln();
    reporter.report(allViolations);

    final now = DateTime.now();
    AnalysisLogger(projectRoot).save(allViolations, rulesCount: ruleFiles.length);

    final htmlPath = _saveHtmlReport(
      projectRoot: projectRoot,
      violations: allViolations,
      rulesCount: ruleFiles.length,
      timestamp: now,
    );

    if (htmlPath != null) {
      final fileUri = 'file:///${htmlPath.replaceAll('\\', '/')}';
      stdout.writeln(
        '  ${ANSIHelper.dim('Full report', useColor)}  $fileUri',
      );
      stdout.writeln();
    }

    final hasFailures = allViolations.any((v) => v.severity.isFailure);
    return hasFailures ? ExitCode.violations : ExitCode.success;
  }

  String? _saveHtmlReport({
    required String projectRoot,
    required List<Violation> violations,
    required int rulesCount,
    required DateTime timestamp,
  }) {
    try {
      final html = HtmlReporter().generate(
        violations,
        rulesCount: rulesCount,
        timestamp: timestamp,
        projectRoot: projectRoot,
      );
      final reportDir = p.join(projectRoot, '.dartunit');
      Directory(reportDir).createSync(recursive: true);
      final reportPath = p.join(reportDir, 'report.html');
      File(reportPath).writeAsStringSync(html);
      return p.normalize(p.absolute(reportPath));
    } catch (_) {
      return null;
    }
  }
}
