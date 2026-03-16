import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../analyzer/project_analyzer.dart';
import '../../engine/rule_engine.dart';
import '../../engine/custom_rule_loader.dart';
import '../../helpers/ansi_helper.dart';
import '../../helpers/banner_helper.dart';
import '../../reporter/console_reporter.dart';
import '../../yaml/yaml_rule_parser.dart';
import '../animations/spinner.dart';
import '../../core/enums/exit_code.dart';

class AnalyzeCommand extends Command<ExitCode> {
  @override
  final String name = 'analyze';

  @override
  final String description =
      'Analyze the project source code against architecture rules.';

  AnalyzeCommand() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the target project (defaults to current directory).',
        defaultsTo: '.',
      )
      ..addOption(
        'config',
        abbr: 'c',
        help: 'Path to dartunit.yaml (defaults to .dartunit/dartunit.yaml).',
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

    final configPath = argResults!['config'] as String? ??
        p.join(projectRoot, '.dartunit', 'dartunit.yaml');

    BannerHelper.printBanner(useColor);

    stdout.writeln('  ${ANSIHelper.dim('Project', useColor)}  $projectRoot');
    stdout.writeln(ANSIHelper.dim('  ${'─' * 64}', useColor));
    stdout.writeln();

    if (!File(configPath).existsSync()) {
      stdout.writeln('  ${ANSIHelper.red('✗', useColor)} Config not found: $configPath');
      stdout.writeln(ANSIHelper.dim(
          '  Run  dartunit init  to create the configuration.', useColor));
      stdout.writeln();
      return ExitCode.error;
    }

    final rulesSpinner = Spinner('Loading rules...', useColor: useColor)..start();
    final rules = YamlRuleParser().parse(configPath);
    rulesSpinner.stop(doneMessage: 'Loaded ${rules.length} rule(s)');

    final customRulesDir = p.join(projectRoot, '.dartunit', 'custom_rules');
    final customFiles = CustomRuleLoader(customRulesDir).discoverRuleFiles();
    if (customFiles.isNotEmpty) {
      stdout.writeln(
          '  ${ANSIHelper.green('✓', useColor)} Found ${customFiles.length} custom rule file(s)');
    }

    final analyzeSpinner = Spinner('Analyzing source code...', useColor: useColor)..start();
    final context = await ProjectAnalyzer(projectRoot).analyze();
    analyzeSpinner.stop(
      doneMessage: 'Found ${context.classes.length} class(es) '
          'in ${context.files.length} file(s)',
    );

    final evalSpinner = Spinner('Evaluating rules...', useColor: useColor)..start();
    final engine = RuleEngine(rules);
    final violations = engine.evaluate(context);
    evalSpinner.stop(doneMessage: 'Rules evaluated');

    stdout.writeln();
    reporter.report(violations);

    return engine.hasFailures(violations) ? ExitCode.violations : ExitCode.success;
  }
}
