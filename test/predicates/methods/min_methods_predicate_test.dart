import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('MinMethodsPredicate', () {
    // Valid cases

    test('passes when method count exceeds the minimum', () {
      final result = MinMethodsPredicate(2).analyze(
        classSubject('Service', methods: [
          method('a'),
          method('b'),
          method('c'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when method count equals the minimum exactly', () {
      final result = MinMethodsPredicate(2).analyze(
        classSubject('Contract', methods: [method('open'), method('close')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes with minimum of 0 and no methods', () {
      final result = MinMethodsPredicate(0).analyze(
        classSubject('Empty'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when method count is below the minimum', () {
      final result = MinMethodsPredicate(3).analyze(
        classSubject('Sparse', methods: [method('only')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails for a class with no methods when minimum is 1', () {
      final result = MinMethodsPredicate(1).analyze(
        classSubject('Empty'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message includes actual count and minimum required', () {
      final result = MinMethodsPredicate(5).analyze(
        classSubject('Cls', methods: [method('run')]),
        emptyCtx(),
      );
      expect(result.message, contains('1'));
      expect(result.message, contains('5'));
    });
  });
}
