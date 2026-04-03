import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MaxMethodsPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when method count exceeds max', () {
      final predicate = MaxMethodsPredicate(2);
      final result = predicate.analyze(
        classSubject('God', methods: [method('a'), method('b'), method('c')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('3'));
      expect(result.message, contains('2'));
    });

    test('fails when count is exactly one over max', () {
      final predicate = MaxMethodsPredicate(3);
      final result = predicate.analyze(
        classSubject('Over', methods: List.generate(4, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = MaxMethodsPredicate(1);
      final result = predicate.analyze(
        classSubject('GodClass', methods: [method('a'), method('b')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('GodClass'));
    });

    test('failure message contains "maximum allowed"', () {
      final predicate = MaxMethodsPredicate(3);
      final result = predicate.analyze(
        classSubject('Bloat', methods: List.generate(6, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('maximum allowed'));
    });

    test('fails when max is 0 and class has methods', () {
      final predicate = MaxMethodsPredicate(0);
      final result = predicate.analyze(
        classSubject('HasMethod', methods: [method('run')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message shows actual count and max', () {
      final predicate = MaxMethodsPredicate(5);
      final result = predicate.analyze(
        classSubject('Verbose', methods: List.generate(9, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('9'));
      expect(result.message, contains('5'));
    });
  });
}
