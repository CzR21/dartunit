import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MinMethodsPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class has no methods but min = 1', () {
      final predicate = MinMethodsPredicate(1);
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('0'));
      expect(result.message, contains('1'));
    });

    test('fails when method count is below min', () {
      final predicate = MinMethodsPredicate(5);
      final result = predicate.analyze(
        classSubject('Sparse', methods: [method('a'), method('b')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = MinMethodsPredicate(3);
      final result = predicate.analyze(
        classSubject('TooSmall', methods: [method('x')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('TooSmall'));
    });

    test('failure message contains "minimum required"', () {
      final predicate = MinMethodsPredicate(2);
      final result = predicate.analyze(classSubject('Bare'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('minimum required'));
    });

    test('fails when count is exactly one below min', () {
      final predicate = MinMethodsPredicate(4);
      final result = predicate.analyze(
        classSubject('Almost', methods: List.generate(3, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message shows actual count and min', () {
      final predicate = MinMethodsPredicate(5);
      final result = predicate.analyze(
        classSubject('Slim', methods: [method('a')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('1'));
      expect(result.message, contains('5'));
    });
  });
}
