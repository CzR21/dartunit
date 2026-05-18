import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart' hide ExitCode;
import 'package:path/path.dart' as p;

import '../../ai/ai_file_generator.dart';
import '../../core/enums/ai_provider.dart';
import '../../core/extensions/ai_provider_extension.dart';
import '../../config/dartunit_config.dart';
import '../../core/enums/exit_code.dart';
import '../../utils/banner_helper.dart';
import '../../utils/terminal_helper.dart';
import '../texts/ai_text.dart';

class AiCommand extends Command<ExitCode> {

  @override
  final String name = 'ai';

  @override
  final String description =
      'Configure an AI tool to assist with architecture rule generation.';

  AiCommand() {
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
    final logger = Logger();

    BannerHelper.printBanner(logger);

    final config = DartunitConfig.read(projectRoot);

    logger.info('');
    final providers = _chooseProviders(logger, current: config.aiProviders);
    if (providers.isEmpty) {
      logger.info('');
      logger.info(aiSkipped);
      logger.info('');
      return ExitCode.success;
    }

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
    logger.success(aiConfigured);
    logger.info('');
    _printNextSteps(logger, aiNextSteps(providers));

    return ExitCode.success;
  }

  List<AiProvider> _chooseProviders(Logger logger, {required List<AiProvider> current}) {
    final options = AiProvider.values.map((p) => p.displayName).toList();
    final defaults = current.map((p) => p.displayName).toList();

    final choices = logger.chooseAny(
      aiChooseProviders,
      choices: options,
      defaultValues: defaults,
    );

    return AiProvider.values
        .where((p) => choices.contains(p.displayName))
        .toList();
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
