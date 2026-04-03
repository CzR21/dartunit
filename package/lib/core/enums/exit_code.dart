/// Exit codes returned by the dartunit CLI.
enum ExitCode {
  /// Analysis completed with no violations.
  success(0),

  /// Analysis completed and one or more violations were found.
  violations(1),

  /// An error occurred (bad arguments, missing config, unexpected failure).
  error(2);

  /// The numeric exit code passed to the OS process.
  final int code;

  const ExitCode(this.code);
}
