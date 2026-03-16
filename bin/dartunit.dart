import 'dart:io';
import 'package:dartunit/dartunit.dart';

/// Bootstraps the CLI and exits with the returned code.
///
/// Exit codes:
///   0 — all rules passed (or no violations found)
///   1 — one or more error/critical violations
///   2 — usage error or unexpected exception
Future<void> main(List<String> arguments) async {
  final cli = DartunitCli();
  final exitCode = await cli.run(arguments);
  exit(exitCode);
}
