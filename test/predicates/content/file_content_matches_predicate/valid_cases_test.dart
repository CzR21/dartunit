import 'dart:io';

import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';

void main() {
  group('FileContentMatchesPredicate — valid cases', () {
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

    test('passes when file content matches simple pattern', () {
      final filePath = '${tempDir.path}/test.dart';
      File(filePath).writeAsStringSync('print("hello");');
      final predicate = FileContentMatchesPredicate(r'print\s*\(');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });

    test('passes when file contains matching multiline content', () {
      final filePath = '${tempDir.path}/service.dart';
      File(filePath).writeAsStringSync('''
class UserService {
  void fetchUser() {}
}
''');
      final predicate = FileContentMatchesPredicate(r'class\s+\w+Service');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });

    test('passes with description — message uses description', () {
      final filePath = '${tempDir.path}/log.dart';
      File(filePath).writeAsStringSync('debugPrint("value");');
      final predicate = FileContentMatchesPredicate(
        r'debugPrint\s*\(',
        description: 'uses debugPrint()',
      );
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
      expect(result.message, contains('uses debugPrint()'));
    });

    test('passes for file containing exact literal match', () {
      final filePath = '${tempDir.path}/todo.dart';
      File(filePath).writeAsStringSync('// TODO: fix this');
      final predicate = FileContentMatchesPredicate('TODO');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });

    test('passes when pattern matches at end of file', () {
      final filePath = '${tempDir.path}/end.dart';
      File(filePath).writeAsStringSync('class A {}\n// GENERATED');
      final predicate = FileContentMatchesPredicate('GENERATED');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
    });

    test('pass message uses file name when description is empty', () {
      final filePath = '${tempDir.path}/match.dart';
      File(filePath).writeAsStringSync('import "dart:io";');
      final predicate = FileContentMatchesPredicate(r'import');
      final result = predicate.analyze(_fileSubject(filePath), emptyFileCtx());
      expect(result.passed, isTrue);
      expect(result.message, contains('import'));
    });
  });
}
