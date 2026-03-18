import 'package:dartunit/core/entities/subject.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';

Subject _fileSubject(String filePath) {
  final file = AnalyzedFile(
    filePath: filePath,
    packagePath: 'package:app/lib/file.dart',
    imports: [],
  );
  return Subject(name: p.basename(filePath), filePath: filePath, element: file);
}

AnalysisContext _ctx() => AnalysisContext(
      classes: [],
      files: [],
      dependencyGraph: DependencyGraph(),
      projectRoot: '/project',
    );

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('dartunit_content_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('FileContentMatchesPredicate', () {
    // Valid cases

    test('passes when file content matches the pattern', () {
      final file = File(p.join(tempDir.path, 'a.dart'))
        ..writeAsStringSync('void main() { print("hello"); }');
      final result = FileContentMatchesPredicate(r'print\s*\(')
          .evaluate(_fileSubject(file.path), _ctx());
      expect(result.passed, isTrue);
    });

    test('passes when multi-line pattern matches file content', () {
      final file = File(p.join(tempDir.path, 'b.dart'))
        ..writeAsStringSync('class Foo {\n  void bar() {}\n}');
      final result = FileContentMatchesPredicate(r'class Foo')
          .evaluate(_fileSubject(file.path), _ctx());
      expect(result.passed, isTrue);
    });

    test('passes and message uses description when provided', () {
      final file = File(p.join(tempDir.path, 'c.dart'))
        ..writeAsStringSync('debugPrint("debug");');
      final result = FileContentMatchesPredicate(
        r'debugPrint\s*\(',
        description: 'uses debugPrint()',
      ).evaluate(_fileSubject(file.path), _ctx());
      expect(result.passed, isTrue);
      expect(result.message, contains('uses debugPrint()'));
    });

    // Fail cases

    test('fails when file content does not match the pattern', () {
      final file = File(p.join(tempDir.path, 'd.dart'))
        ..writeAsStringSync('class Clean {}');
      final result = FileContentMatchesPredicate(r'print\s*\(')
          .evaluate(_fileSubject(file.path), _ctx());
      expect(result.passed, isFalse);
    });

    test('fails when the file cannot be read', () {
      final result = FileContentMatchesPredicate(r'anything')
          .evaluate(_fileSubject('/nonexistent/path/file.dart'), _ctx());
      expect(result.passed, isFalse);
      expect(result.message, contains('Could not read file'));
    });

    test('fail message includes the pattern', () {
      final file = File(p.join(tempDir.path, 'e.dart'))
        ..writeAsStringSync('class Good {}');
      final result = FileContentMatchesPredicate(r'TODO:')
          .evaluate(_fileSubject(file.path), _ctx());
      expect(result.message, contains('TODO:'));
    });
  });
}
