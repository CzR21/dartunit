import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MinFieldsPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class has no fields but min = 1', () {
      final predicate = MinFieldsPredicate(1);
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('0'));
      expect(result.message, contains('1'));
    });

    test('fails when field count is below min', () {
      final predicate = MinFieldsPredicate(5);
      final result = predicate.analyze(
        classSubject('Sparse', fields: [finalField('a'), finalField('b')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = MinFieldsPredicate(3);
      final result = predicate.analyze(
        classSubject('TooSmall', fields: [finalField('x')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('TooSmall'));
    });

    test('failure message contains "minimum required"', () {
      final predicate = MinFieldsPredicate(2);
      final result = predicate.analyze(classSubject('Thin'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('minimum required'));
    });

    test('fails when count is exactly one below min', () {
      final predicate = MinFieldsPredicate(4);
      final result = predicate.analyze(
        classSubject('AlmostEnough', fields: List.generate(3, (i) => finalField('f$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message shows actual count and min', () {
      final predicate = MinFieldsPredicate(5);
      final result = predicate.analyze(
        classSubject('Skinny', fields: [finalField('a')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('1'));
      expect(result.message, contains('5'));
    });
  });
}
