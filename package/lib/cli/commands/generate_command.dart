import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart' hide ExitCode;
import 'package:path/path.dart' as p;

import '../../utils/banner_helper.dart';
import '../../utils/terminal_helper.dart';
import '../../core/enums/exit_code.dart';
import '../texts/generate_text.dart';

class GenerateCommand extends Command<ExitCode> {
  @override
  final String name = 'generate';

  @override
  final String description =
      'Generate a new architecture rule scaffold in test_arch/.';

  @override
  String get invocation => 'dartunit generate <rule_name>';

  GenerateCommand() {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the target project (defaults to current directory).',
      defaultsTo: '.',
    );
  }

  @override
  Future<ExitCode> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
        'Please provide a rule name.\n'
        'Example: dartunit generate no_repository_in_ui',
      );
    }

    final ruleName = rest.first;
    final projectRoot = p.normalize(p.absolute(argResults!['path'] as String));
    final archTestDir = p.join(projectRoot, 'test_arch');
    final logger = Logger();

    BannerHelper.printBanner(logger);

    if (!Directory(archTestDir).existsSync()) {
      logger.err(generateMissingArchTest(projectRoot));
      logger.info('');
      return ExitCode.error;
    }

    final fileName = '${ruleName}_arch_test.dart';
    final outputPath = p.join(archTestDir, fileName);

    final sep = TerminalHelper.supportsUnicode ? '─' : '-';
    logger.detail('  Project  $projectRoot');
    logger.detail('  ${sep * 48}');
    logger.info('');

    File(outputPath).writeAsStringSync(ruleTemplate(ruleName));
    logger.success(generateCreatedFile(fileName));

    logger.info('');
    _printNextSteps(logger, generateNextSteps(fileName));

    return ExitCode.success;
  }

  void _printNextSteps(Logger logger, List<String> steps) {
    final sep = TerminalHelper.supportsUnicode ? '─' : '-';
    logger.info(white.wrap('Next steps') ?? 'Next steps');
    logger.detail('  ${sep * 48}');
    for (var i = 0; i < steps.length; i++) {
      logger.info('  ${darkGray.wrap('${i + 1}.')} ${steps[i]}');
    }
    logger.info('');
  }
}
