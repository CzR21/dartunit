import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('MaxFieldsPredicate', () {
    // Valid cases

    test('passes when field count is below the limit', () {
      final result = MaxFieldsPredicate(5).analyze(
        classSubject('User', fields: [finalField('id'), finalField('name')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when field count equals the limit exactly', () {
      final result = MaxFieldsPredicate(3).analyze(
        classSubject('Coords', fields: [
          finalField('x'),
          finalField('y'),
          finalField('z'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for a class with no fields', () {
      final result = MaxFieldsPredicate(10).analyze(
        classSubject('EmptyClass'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when field count exceeds the limit', () {
      final result = MaxFieldsPredicate(2).analyze(
        classSubject('BigClass', fields: [
          finalField('a'),
          finalField('b'),
          finalField('c'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message includes actual count and limit', () {
      final result = MaxFieldsPredicate(1).analyze(
        classSubject('Cls', fields: [finalField('x'), finalField('y')]),
        emptyCtx(),
      );
      expect(result.message, contains('2'));
      expect(result.message, contains('1'));
    });

    test('fails with limit of 0 when any field exists', () {
      final result = MaxFieldsPredicate(0).analyze(
        classSubject('Cls', fields: [finalField('id')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });
  });
}
