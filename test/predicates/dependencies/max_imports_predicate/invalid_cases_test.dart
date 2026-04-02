import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MaxImportsPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when import count exceeds max', () {
      final predicate = MaxImportsPredicate(2);
      final result = predicate.analyze(
        classSubject('BigClass', imports: ['a.dart', 'b.dart', 'c.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('3'));
      expect(result.message, contains('2'));
    });

    test('fails when import count is exactly one over max', () {
      final predicate = MaxImportsPredicate(3);
      final result = predicate.analyze(
        classSubject('MyClass', imports: ['a.dart', 'b.dart', 'c.dart', 'd.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = MaxImportsPredicate(1);
      final result = predicate.analyze(
        classSubject('GodClass', imports: ['a.dart', 'b.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('GodClass'));
    });

    test('failure message contains actual count and max', () {
      final predicate = MaxImportsPredicate(5);
      final result = predicate.analyze(
        classSubject('MyClass', imports: List.generate(8, (i) => '$i.dart')),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('8'));
      expect(result.message, contains('5'));
    });

    test('fails when max is 0 and class has imports', () {
      final predicate = MaxImportsPredicate(0);
      final result = predicate.analyze(
        classSubject('NoImports', imports: ['dart:core']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains "maximum allowed"', () {
      final predicate = MaxImportsPredicate(3);
      final result = predicate.analyze(
        classSubject('BloatedClass', imports: ['a.dart', 'b.dart', 'c.dart', 'd.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('maximum allowed'));
    });
  });
}
