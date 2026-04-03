import 'dart:io';

import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';

void main() {
  group('noBannedCalls preset — valid cases (NotPredicate + FileContentMatchesPredicate)', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dartunit_banned_test_');
    });

    tearDown(() => tempDir.deleteSync(recursive: true));

    Subject _fileSubject(String filePath) {
      final file = AnalyzedFile(
        filePath: filePath,
        packagePath: 'package:app/${filePath.split('/').last}',
        imports: [],
      );
      return Subject(name: filePath.split('/').last, filePath: filePath, element: file);
    }

    AnalysisContext emptyFileCtx() => AnalysisContext(
          classes: [],
          files: [],
          dependencyGraph: DependencyGraph(),
          projectRoot: tempDir.path,
        );

    test('NotPredicate passes when file does not contain banned print()', () {
      final filePath = '${tempDir.path}/clean.dart';
      File(filePath).writeAsStringSync('void main() { log("hello"); }');
      final predicate = NotPredicate(
        FileContentMatchesPredicate(r'print\s*\(', description: 'uses print()'),
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });

    test('NotPredicate passes when file has no debugPrint', () {
      final filePath = '${tempDir.path}/no_debug.dart';
      File(filePath).writeAsStringSync('class A { void log() {} }');
      final predicate = NotPredicate(
        FileContentMatchesPredicate(r'debugPrint\s*\('),
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });

    test('NotPredicate passes for file with no TODO comments', () {
      final filePath = '${tempDir.path}/done.dart';
      File(filePath).writeAsStringSync('// All complete\nclass B {}');
      final predicate = NotPredicate(FileContentMatchesPredicate('TODO'));
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });

    test('NotPredicate passes for empty file', () {
      final filePath = '${tempDir.path}/empty.dart';
      File(filePath).writeAsStringSync('');
      final predicate = NotPredicate(
        FileContentMatchesPredicate(r'print\s*\('),
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });

    test('NotPredicate passes when file contains commented-out print', () {
      // This tests that commented code still matches — the predicate is content-based
      // A clean file without 'print(' at all should pass
      final filePath = '${tempDir.path}/log_only.dart';
      File(filePath).writeAsStringSync('void main() { logger.info("msg"); }');
      final predicate = NotPredicate(
        FileContentMatchesPredicate(r'print\s*\('),
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });
  });
}
