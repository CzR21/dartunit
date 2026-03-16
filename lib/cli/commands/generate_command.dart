import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../helpers/ansi_helper.dart';
import '../../helpers/banner_helper.dart';
import '../../core/enums/exit_code.dart';
import '../texts/generate_text.dart';

class GenerateCommand extends Command<ExitCode> {
  @override
  final String name = 'generate';

  @override
  final String description =
      'Generate a new custom rule scaffold and update dartunit.yaml.';

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
    final dartunitDir = p.join(projectRoot, '.dartunit');
    final customRulesDir = p.join(dartunitDir, 'custom_rules');
    final configPath = p.join(dartunitDir, 'dartunit.yaml');

    BannerHelper.printBanner();

    if (!Directory(dartunitDir).existsSync()) {
      stdout.writeln('  ${ANSIHelper.red('✗')} ${generateMissingDartunit(projectRoot)}');
      stdout.writeln();
      return ExitCode.error;
    }

    final className = '${_toPascalCase(ruleName)}Rule';
    final fileName = '${ruleName}_rule.dart';
    final ruleId = 'CUSTOM_${ruleName.toUpperCase()}';
    final outputPath = p.join(customRulesDir, fileName);

    stdout.writeln('  ${ANSIHelper.dim('Rule')}     $className');
    stdout.writeln('  ${ANSIHelper.dim('ID')}       $ruleId');
    stdout.writeln('  ${ANSIHelper.dim('Project')}  $projectRoot');
    stdout.writeln(ANSIHelper.dim('  ${'─' * 48}'));
    stdout.writeln();

    Directory(customRulesDir).createSync(recursive: true);
    File(outputPath).writeAsStringSync(ruleTemplate(className, ruleName, ruleId));
    stdout.writeln('  ${ANSIHelper.green('✓')} ${generateCreatedFile(fileName)}');

    _appendToConfig(configPath, ruleId, fileName, className);
    stdout.writeln('  ${ANSIHelper.green('✓')} $generateUpdatedConfig');

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

  String _toPascalCase(String input) {
    return input
        .split(RegExp(r'[_\-\s]+'))
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join();
  }

  void _appendToConfig(String configPath, String ruleId, String fileName, String className) {
    final file = File(configPath);
    var content = file.existsSync() ? file.readAsStringSync() : '';
    if (content.trimRight().isEmpty) content = 'rules:\n';
    file.writeAsStringSync(content + yamlEntry(ruleId, fileName, className));
  }
}
