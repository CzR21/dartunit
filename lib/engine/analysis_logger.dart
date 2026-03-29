import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/entities/analysis_log.dart';
import '../core/entities/violation.dart';

/// Persists analysis run history to `.dartunit/analysis_log.json`.
///
/// Keeps at most [maxEntries] entries, discarding the oldest on overflow.
class AnalysisLogger {
  static const int maxEntries = 5;
  static const String _logFileName = 'analysis_log.json';
  static const String _logDirName = '.dartunit';

  final String projectRoot;

  AnalysisLogger(this.projectRoot);

  String get _logFilePath => p.join(projectRoot, _logDirName, _logFileName);

  /// Appends a new entry for [violations] and trims to [maxEntries].
  void save(List<Violation> violations, {int rulesCount = 0}) {
    final entries = load();
    entries.add(AnalysisLog(
      timestamp: DateTime.now(),
      rulesCount: rulesCount,
      violations: violations,
    ));

    final trimmed = entries.length > maxEntries
        ? entries.sublist(entries.length - maxEntries)
        : entries;

    final logDir = Directory(p.join(projectRoot, _logDirName));
    if (!logDir.existsSync()) logDir.createSync(recursive: true);

    File(_logFilePath).writeAsStringSync(
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  /// Returns all stored entries, oldest first. Returns [] if no log exists.
  List<AnalysisLog> load() {
    final file = File(_logFilePath);
    if (!file.existsSync()) return [];

    try {
      final list = jsonDecode(file.readAsStringSync()) as List;
      return list
          .cast<Map<String, dynamic>>()
          .map(AnalysisLog.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
