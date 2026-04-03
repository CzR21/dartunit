import 'dart:io';

import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';

void main() {
  group('FileContentMatchesPredicate — invalid cases', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dartunit_content_test_');
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

    test('fails when pattern is not found in file', () {
      final filePath = '${tempDir.path}/clean.dart';
      File(filePath).writeAsStringSync('class A {}');
      final predicate = FileContentMatchesPredicate(r'print\s*\(');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
      expect(result.message, contains('does not match pattern'));
    });

    test('fails when file is empty', () {
      final filePath = '${tempDir.path}/empty.dart';
      File(filePath).writeAsStringSync('');
      final predicate = FileContentMatchesPredicate('TODO');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
    });

    test('fails when file does not contain TODO comment', () {
      final filePath = '${tempDir.path}/notodo.dart';
      File(filePath).writeAsStringSync('// All done here\nclass B {}');
      final predicate = FileContentMatchesPredicate('TODO');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
      expect(result.message, contains('TODO'));
    });

    test('fails when file cannot be read (non-existent path)', () {
      final filePath = '${tempDir.path}/nonexistent.dart';
      final predicate = FileContentMatchesPredicate('anything');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
      expect(result.message, contains('Could not read file'));
    });

    test('fails when case-sensitive pattern does not match', () {
      final filePath = '${tempDir.path}/case.dart';
      File(filePath).writeAsStringSync('// todo: fix this');
      final predicate = FileContentMatchesPredicate('TODO'); // uppercase
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
    });

    test('failure message contains pattern when no match found', () {
      final filePath = '${tempDir.path}/nope.dart';
      File(filePath).writeAsStringSync('void main() {}');
      final predicate = FileContentMatchesPredicate(r'debugPrint\s*\(');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
      expect(result.message, contains(r'debugPrint\s*\('));
    });
  });
}
