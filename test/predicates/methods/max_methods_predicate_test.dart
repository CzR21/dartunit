import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('MaxMethodsPredicate', () {
    // Valid cases

    test('passes when method count is below the limit', () {
      final result = MaxMethodsPredicate(5).analyze(
        classSubject('Service', methods: [method('a'), method('b')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when method count equals the limit exactly', () {
      final result = MaxMethodsPredicate(3).analyze(
        classSubject('TriMethod', methods: [
          method('a'),
          method('b'),
          method('c'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for a class with no methods', () {
      final result = MaxMethodsPredicate(10).analyze(
        classSubject('DataHolder'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when method count exceeds the limit', () {
      final result = MaxMethodsPredicate(2).analyze(
        classSubject('BigClass', methods: [
          method('a'),
          method('b'),
          method('c'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message includes actual count and limit', () {
      final result = MaxMethodsPredicate(1).analyze(
        classSubject('Cls', methods: [
          method('a'),
          method('b'),
          method('c'),
        ]),
        emptyCtx(),
      );
      expect(result.message, contains('3'));
      expect(result.message, contains('1'));
    });

    test('fails with limit of 0 when any method exists', () {
      final result = MaxMethodsPredicate(0).analyze(
        classSubject('Cls', methods: [method('run')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });
  });
}
