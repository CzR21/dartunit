import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartunit/cli/dartunit_cli.dart';
import 'package:dartunit/engine/analysis_logger.dart';
import 'package:dartunit/core/entities/violation.dart';
import 'package:dartunit/core/enums/rule_severity.dart';

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('dartunit_cli_log_'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  group('log — no history', () {
    test('returns 0 when no log file exists', () async {
      final code = await DartunitCli().run(['log', '--path', tempDir.path]);
      expect(code, equals(0));
    });
  });

  group('log — with history', () {
    void writeLog(List<Map<String, dynamic>> entries) {
      final dir = Directory(p.join(tempDir.path, '.dartunit'))
        ..createSync(recursive: true);
      File(p.join(dir.path, 'analysis_log.json'))
          .writeAsStringSync(jsonEncode(entries));
    }

    test('returns 0 when log has entries', () async {
      writeLog([
        {
          'timestamp': DateTime.now().toIso8601String(),
          'rulesCount': 3,
          'violations': [],
        }
      ]);
      final code = await DartunitCli().run(['log', '--path', tempDir.path]);
      expect(code, equals(0));
    });

    test('handles log with violations', () async {
      writeLog([
        {
          'timestamp': DateTime.now().toIso8601String(),
          'rulesCount': 6,
          'violations': [
            {
              'ruleDescription': 'Domain must not depend on data',
              'message': 'Bad imports lib/data',
              'filePath': 'lib/domain/bad.dart',
              'severity': 'error',
            }
          ],
        }
      ]);
      final code = await DartunitCli().run(['log', '--path', tempDir.path]);
      expect(code, equals(0));
    });
  });

  group('AnalysisLogger — save and load', () {
    test('saves and loads an empty-violation entry', () {
      final logger = AnalysisLogger(tempDir.path);
      logger.save([], rulesCount: 4);
      final entries = logger.load();
      expect(entries.length, equals(1));
      expect(entries.first.passed, isTrue);
      expect(entries.first.rulesCount, equals(4));
    });

    test('saves and loads violations', () {
      final logger = AnalysisLogger(tempDir.path);
      logger.save([
        Violation(
          ruleDescription: 'Test rule',
          message: 'Bad import',
          filePath: 'lib/domain/bad.dart',
          severity: RuleSeverity.error,
        ),
      ]);
      final entries = logger.load();
      expect(entries.first.violations.length, equals(1));
      expect(entries.first.failureCount, equals(1));
      expect(entries.first.passed, isFalse);
    });

    test('keeps at most ${AnalysisLogger.maxEntries} entries', () {
      final logger = AnalysisLogger(tempDir.path);
      for (var i = 0; i < AnalysisLogger.maxEntries + 2; i++) {
        logger.save([]);
      }
      expect(logger.load().length, equals(AnalysisLogger.maxEntries));
    });

    test('returns empty list when log file is missing', () {
      expect(AnalysisLogger(tempDir.path).load(), isEmpty);
    });
  });
}
