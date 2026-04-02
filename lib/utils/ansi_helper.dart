/// ANSI escape code helpers.
///
/// All methods accept an optional [useColor] flag (default `true`).
/// When `false`, the string is returned unchanged — useful for `--no-color`.
class ANSIHelper {

  ANSIHelper._();

  static const String reset = '\x1B[0m';
  static const String kGreen = '\x1B[32m';
  static const String kRed = '\x1B[31m';
  static const String kYellow = '\x1B[33m';

  static String cyan(String s, [bool useColor = true]) => useColor ? '\x1B[36m$s\x1B[0m' : s;
  static String green(String s, [bool useColor = true]) => useColor ? '\x1B[32m$s\x1B[0m' : s;
  static String red(String s, [bool useColor = true]) => useColor ? '\x1B[31m$s\x1B[0m' : s;
  static String yellow(String s, [bool useColor = true]) => useColor ? '\x1B[33m$s\x1B[0m' : s;
  static String magenta(String s, [bool useColor = true]) => useColor ? '\x1B[35m$s\x1B[0m' : s;
  static String bold(String s, [bool useColor = true]) => useColor ? '\x1B[1m$s\x1B[0m'  : s;
  static String dim(String s, [bool useColor = true]) => useColor ? '\x1B[2m$s\x1B[0m'  : s;
}
