import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart' hide ExitCode;
import 'package:path/path.dart' as p;

import '../../ai/ai_file_generator.dart';
import '../../config/dartunit_config.dart';
import '../../core/enums/ai_provider.dart';
import '../../core/enums/arch_template.dart';
import '../../core/extensions/ai_provider_extension.dart';
import '../../core/extensions/arch_template_extension.dart';
import '../../utils/banner_helper.dart';
import '../../utils/terminal_helper.dart';
import '../../core/enums/exit_code.dart';
import '../texts/ai_text.dart';
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
    final logger = Logger();

    BannerHelper.printBanner(logger);

    if (Directory(archTestDir).existsSync()) {
      logger.info('');
      logger.info(initAlreadyExists);
      logger.info('');
      return ExitCode.success;
    }

    logger.detail('  Project   $projectRoot');
    if (template != null) {
      logger.detail('  Template  ${template.label}');
    }
    logger.info('');

    Directory(archTestDir).createSync(recursive: true);

    if (template != null) {
      for (final file in template.ruleFiles) {
        File(p.join(archTestDir, file.fileName)).writeAsStringSync(file.content);
        _printCreated(logger, file.fileName);
      }
    } else {
      File(p.join(archTestDir, 'example_arch_test.dart')).writeAsStringSync(exampleRule);
      _printCreated(logger, 'example_arch_test.dart');
    }

    logger.info('');

    final aiProviders = await _setupAi(logger, projectRoot);

    logger.success(initSuccess);
    logger.info('');

    if (aiProviders.isNotEmpty) {
      _printNextSteps(logger, aiNextSteps(aiProviders));
    } else if (template != null) {
      _printNextSteps(logger, initTemplateNextSteps(template.label, template.ruleFiles.length));
    } else {
      _printNextSteps(logger, initNextSteps);
    }

    return ExitCode.success;
  }

  Future<List<AiProvider>> _setupAi(Logger logger, String projectRoot) async {
    final configure = logger.confirm(aiPrompt, defaultValue: true);
    if (!configure) return const [];

    final options = AiProvider.values.map((p) => p.displayName).toList();
    final choices = logger.chooseAny(
      aiChooseProviders,
      choices: options,
    );

    final providers = AiProvider.values
        .where((p) => choices.contains(p.displayName))
        .toList();

    if (providers.isEmpty) return const [];

    logger.info('');
    for (final provider in providers) {
      final created = AiFileGenerator.writeAll(provider, projectRoot);
      for (final path in created) {
        logger.success(aiCreatedFile(path));
      }
    }
    DartunitConfig(aiProviders: providers).write(projectRoot);
    logger.success(aiCreatedFile(DartunitConfig.fileName));
    logger.info('');

    return providers;
  }

  void _printCreated(Logger logger, String relativePath) {
    logger.success('${darkGray.wrap('Created')}  test_arch/$relativePath');
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
