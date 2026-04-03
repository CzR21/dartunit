import 'package:args/command_runner.dart';

import 'commands/analyze_command.dart';
import 'commands/generate_command.dart';
import 'commands/init_command.dart';
import 'commands/log_command.dart';
import '../core/enums/exit_code.dart';

/// The root command runner for the dartunit CLI.
class DartunitCli {
  late final CommandRunner<ExitCode> _runner;

  DartunitCli() {
    _runner = CommandRunner<ExitCode>(
      'dartunit',
      'Architecture testing tool for Dart and Flutter projects.\n'
      'Inspired by ArchUnit / ArchUnitNET.\n',
    )
      ..addCommand(InitCommand())
      ..addCommand(AnalyzeCommand())
      ..addCommand(GenerateCommand())
      ..addCommand(LogCommand());
  }

  /// Runs the CLI with the given [arguments].
  ///
  /// Returns the numeric exit code from [ExitCode]:
  ///   [ExitCode.success]    (0) — no violations found
  ///   [ExitCode.violations] (1) — one or more violations found
  ///   [ExitCode.error]      (2) — bad arguments or unexpected failure
  Future<int> run(List<String> arguments) async {
    try {
      final result = await _runner.run(arguments);
      return (result ?? ExitCode.success).code;
    } on UsageException catch (e) {
      print(e);
      return ExitCode.error.code;
    } catch (e, st) {
      print('Unexpected error: $e');
      print(st);
      return ExitCode.error.code;
    }
  }
}
