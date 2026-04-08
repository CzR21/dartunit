import 'package:mason_logger/mason_logger.dart' hide ExitCode;

const String logNoHistory =
    'No analysis runs recorded yet. Run  dartunit analyze  first.';

String logHeader(int count) =>
    'Last $count analysis run${count == 1 ? '' : 's'}';

String runHeader(int index, DateTime timestamp, int rulesCount) {
  final ts = _formatTimestamp(timestamp);
  final rules = '$rulesCount rule${rulesCount == 1 ? '' : 's'}';
  return darkGray.wrap('  ── ${white.wrap('Run #$index')}  ·  $ts  ·  $rules ────') ?? '';
}

String _formatTimestamp(DateTime dt) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final d = dt.day.toString().padLeft(2, '0');
  final m = months[dt.month - 1];
  final y = dt.year;
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$d $m $y  $h:$min';
}
