import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../utils/ansi_helper.dart';
import '../../utils/banner_helper.dart';
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

    BannerHelper.printBanner();

    if (!Directory(archTestDir).existsSync()) {
      stdout.writeln('  ${ANSIHelper.red('✗')} ${generateMissingArchTest(projectRoot)}');
      stdout.writeln();
      return ExitCode.error;
    }

    final fileName = '${ruleName}_arch_test.dart';
    final outputPath = p.join(archTestDir, fileName);

    stdout.writeln('  ${ANSIHelper.dim('Project')}  $projectRoot');
    stdout.writeln(ANSIHelper.dim('  ${'─' * 48}'));
    stdout.writeln();

    File(outputPath).writeAsStringSync(ruleTemplate(ruleName));
    stdout.writeln('  ${ANSIHelper.green('✓')} ${generateCreatedFile(fileName)}');

    stdout.writeln();
    _printNextSteps(generateNextSteps(fileName));

    return ExitCode.success;
  }

  void _printNextSteps(List<String> steps) {
    stdout.writeln('  ${ANSIHelper.bold('Next steps')}');
    stdout.writeln(ANSIHelper.dim('  ${'─' * 48}'));
    for (var i = 0; i < steps.length; i++) {
      stdout.writeln('  ${ANSIHelper.dim('${i + 1}.')} ${steps[i]}');
    }
    stdout.writeln();
  }
}
