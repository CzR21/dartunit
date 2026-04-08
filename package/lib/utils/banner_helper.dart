import 'package:mason_logger/mason_logger.dart';

import '../cli/texts/banner_text.dart';
import 'terminal_helper.dart';

/// Prints the dartunit ASCII banner via [logger].
///
/// All three CLI commands share this header, so it lives here
/// instead of being duplicated inside each Command class.
class BannerHelper {
  static void printBanner(Logger logger) {
    logger.info(lightCyan.wrap(kBanner) ?? kBanner);
    logger.info(
      '  $kSubtitle  '
      '${darkGray.wrap('·')}  '
      '${darkGray.wrap(kVersion)}',
    );
    final sep = TerminalHelper.supportsUnicode ? '─' : '-';
    logger.info(darkGray.wrap('  ${sep * 64}') ?? '');
    logger.info('');
  }
}
