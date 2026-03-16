import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('MinFieldsPredicate', () {
    // Valid cases

    test('passes when field count exceeds the minimum', () {
      final result = MinFieldsPredicate(2).evaluate(
        classSubject('User', fields: [
          finalField('id'),
          finalField('name'),
          finalField('email'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when field count equals the minimum exactly', () {
      final result = MinFieldsPredicate(2).evaluate(
        classSubject('Point', fields: [finalField('x'), finalField('y')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes with minimum of zero and no fields', () {
      final result = MinFieldsPredicate(0).evaluate(
        classSubject('Empty'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when field count is below the minimum', () {
      final result = MinFieldsPredicate(3).evaluate(
        classSubject('Sparse', fields: [finalField('id')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails for a class with no fields when minimum is 1', () {
      final result = MinFieldsPredicate(1).evaluate(
        classSubject('Empty'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message includes actual count and minimum required', () {
      final result = MinFieldsPredicate(5).evaluate(
        classSubject('Cls', fields: [finalField('a')]),
        emptyCtx(),
      );
      expect(result.message, contains('1'));
      expect(result.message, contains('5'));
    });
  });
}
