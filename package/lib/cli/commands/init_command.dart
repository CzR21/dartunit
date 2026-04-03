import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../core/enums/arch_template.dart';
import '../../utils/ansi_helper.dart';
import '../../utils/banner_helper.dart';
import '../../core/enums/exit_code.dart';
import '../texts/init_text.dart';

class InitCommand extends Command<ExitCode> {
  @override
  final String name = 'init';

  @override
  final String description =
      'Initialise dartunit in the current project by creating the test_arch/ folder.';

  InitCommand() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the target project (defaults to current directory).',
        defaultsTo: '.',
      )
      ..addOption(
        'template',
        abbr: 't',
        help: 'Pre-set architecture template to scaffold rules from.',
        allowed: ArchTemplate.values.map((t) => t.name).toList(),
        allowedHelp: {
          'bloc': 'BLoC pattern (Flutter BLoC)',
          'clean': 'Clean Architecture (domain / data / presentation)',
          'mvc': 'MVC (models / views / controllers)',
          'mvvm': 'MVVM (models / views / viewmodels)',
        },
      );
  }

  @override
  Future<ExitCode> run() async {
    final projectRoot = p.normalize(p.absolute(argResults!['path'] as String));
    final archTestDir = p.join(projectRoot, 'test_arch');
    final templateName = argResults!['template'] as String?;
    final template =
        templateName != null ? ArchTemplateExtension.fromString(templateName) : null;

    BannerHelper.printBanner();

    if (Directory(archTestDir).existsSync()) {
      stdout.writeln();
      stdout.writeln('  ${ANSIHelper.cyan('◆')} $initAlreadyExists');
      stdout.writeln();
      return ExitCode.success;
    }

    stdout.writeln('  ${ANSIHelper.dim('Project')}   $projectRoot');
    if (template != null) {
      stdout.writeln('  ${ANSIHelper.dim('Template')}  ${template.label}');
    }
    stdout.writeln();

    Directory(archTestDir).createSync(recursive: true);

    if (template != null) {
      for (final file in template.ruleFiles) {
        File(p.join(archTestDir, file.fileName)).writeAsStringSync(file.content);
        _printCreated(file.fileName);
      }
      stdout.writeln();
      stdout.writeln('  ${ANSIHelper.green('✓')} ${ANSIHelper.bold(initSuccess)}');
      stdout.writeln();
      _printNextSteps(initTemplateNextSteps(template.label, template.ruleFiles.length));
    } else {
      File(p.join(archTestDir, 'example_test_arch.dart')).writeAsStringSync(exampleRule);
      _printCreated('example_test_arch.dart');
      stdout.writeln();
      stdout.writeln('  ${ANSIHelper.green('✓')} ${ANSIHelper.bold(initSuccess)}');
      stdout.writeln();
      _printNextSteps(initNextSteps);
    }

    return ExitCode.success;
  }

  void _printCreated(String relativePath) {
    stdout.writeln(
      '  ${ANSIHelper.green('✓')} ${ANSIHelper.dim('Created')}  '
      '${ANSIHelper.bold('test_arch/')}$relativePath',
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
