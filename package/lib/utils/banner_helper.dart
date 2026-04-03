import 'dart:io';
import '../cli/texts/banner_text.dart';
import 'ansi_helper.dart';

/// Prints the dartunit ASCII banner to stdout.
///
/// All three CLI commands share this header, so it lives here
/// instead of being duplicated inside each Command class.
class BannerHelper{

  static void printBanner([bool useColor = true]) {
    stdout.writeln(ANSIHelper.cyan(kBanner, useColor));
    stdout.writeln(
      '  $kSubtitle  '
      '${ANSIHelper.dim('·', useColor)}  '
      '${ANSIHelper.dim(kVersion, useColor)}',
    );
    stdout.writeln(ANSIHelper.dim('  ${'─' * 64}', useColor));
    stdout.writeln();
  }

}
