import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MaxFieldsPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when field count exceeds max', () {
      final predicate = MaxFieldsPredicate(2);
      final result = predicate.analyze(
        classSubject('Big', fields: [finalField('a'), finalField('b'), finalField('c')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('3'));
      expect(result.message, contains('2'));
    });

    test('fails when field count is exactly one over max', () {
      final predicate = MaxFieldsPredicate(3);
      final result = predicate.analyze(
        classSubject('Over', fields: List.generate(4, (i) => finalField('f$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = MaxFieldsPredicate(1);
      final result = predicate.analyze(
        classSubject('GodClass', fields: [finalField('a'), finalField('b')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('GodClass'));
    });

    test('failure message contains "maximum allowed"', () {
      final predicate = MaxFieldsPredicate(3);
      final result = predicate.analyze(
        classSubject('TooBig', fields: List.generate(6, (i) => finalField('f$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('maximum allowed'));
    });

    test('fails when max is 0 and class has one field', () {
      final predicate = MaxFieldsPredicate(0);
      final result = predicate.analyze(
        classSubject('NotEmpty', fields: [finalField('x')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message shows actual count and max', () {
      final predicate = MaxFieldsPredicate(5);
      final result = predicate.analyze(
        classSubject('Bloated', fields: List.generate(9, (i) => finalField('f$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('9'));
      expect(result.message, contains('5'));
    });
  });
}
