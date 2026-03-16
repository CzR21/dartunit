import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../helpers/ansi_helper.dart';
import '../../helpers/banner_helper.dart';
import '../../core/enums/exit_code.dart';
import '../texts/init_text.dart';

class InitCommand extends Command<ExitCode> {
  @override
  final String name = 'init';

  @override
  final String description =
      'Initialise dartunit in the current project by creating the .dartunit/ folder.';

  InitCommand() {
    argParser.addOption(
      'path',
      abbr: 'p',
      help: 'Path to the target project (defaults to current directory).',
      defaultsTo: '.',
    );
  }

  @override
  Future<ExitCode> run() async {
    final projectRoot = p.normalize(p.absolute(argResults!['path'] as String));
    final dartunitDir = p.join(projectRoot, '.dartunit');
    final customRulesDir = p.join(dartunitDir, 'custom_rules');

    BannerHelper.printBanner();

    if (Directory(dartunitDir).existsSync()) {
      stdout.writeln();
      stdout.writeln('  ${ANSIHelper.cyan('◆')} $initAlreadyExists');
      stdout.writeln();
      return ExitCode.success;
    }

    stdout.writeln('  ${ANSIHelper.dim('Project')}  $projectRoot');
    stdout.writeln();

    Directory(customRulesDir).createSync(recursive: true);

    File(p.join(dartunitDir, 'dartunit.yaml')).writeAsStringSync(defaultConfig);
    _printCreated('dartunit.yaml');

    File(p.join(dartunitDir, 'README.md')).writeAsStringSync(readmeContent);
    _printCreated('README.md');

    File(p.join(customRulesDir, 'example_rule.dart')).writeAsStringSync(exampleRule);
    _printCreated('custom_rules/example_rule.dart');

    stdout.writeln();
    stdout.writeln('  ${ANSIHelper.green('✓')} ${ANSIHelper.bold(initSuccess)}');
    stdout.writeln();
    _printNextSteps(initNextSteps);

    return ExitCode.success;
  }

  void _printCreated(String relativePath) {
    stdout.writeln(
      '  ${ANSIHelper.green('✓')} ${ANSIHelper.dim('Created')}  '
      '${ANSIHelper.bold('.dartunit/')}$relativePath',
    );
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
