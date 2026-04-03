import 'dart:io';

import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';

void main() {
  group('noBannedCalls preset — invalid cases (NotPredicate + FileContentMatchesPredicate)', () {
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

    test('NotPredicate fails when file contains banned print()', () {
      final filePath = '${tempDir.path}/dirty.dart';
      File(filePath).writeAsStringSync('void main() { print("debug"); }');
      final predicate = NotPredicate(
        FileContentMatchesPredicate(r'print\s*\(', description: 'uses print()'),
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
    });

    test('NotPredicate fails when file contains debugPrint', () {
      final filePath = '${tempDir.path}/debug.dart';
      File(filePath).writeAsStringSync('void f() { debugPrint("value"); }');
      final predicate = NotPredicate(
        FileContentMatchesPredicate(r'debugPrint\s*\('),
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
    });

    test('failure message contains file information', () {
      final filePath = '${tempDir.path}/bad.dart';
      File(filePath).writeAsStringSync('// TODO: remove this');
      final predicate = NotPredicate(FileContentMatchesPredicate('TODO'));
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
      expect(result.message, isNotEmpty);
    });

    test('NotPredicate fails when file contains print anywhere', () {
      final filePath = '${tempDir.path}/multiline.dart';
      File(filePath).writeAsStringSync('''
class A {
  void doSomething() {
    print("something");
  }
}
''');
      final predicate = NotPredicate(
        FileContentMatchesPredicate(r'print\s*\('),
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
    });

    test('NotPredicate fails for file with multiple banned patterns found by one check', () {
      final filePath = '${tempDir.path}/bad2.dart';
      File(filePath).writeAsStringSync('print("a");\ndebugPrint("b");');
      final predicate = NotPredicate(
        FileContentMatchesPredicate(r'print\s*\('),
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isFalse);
    });
  });
}
