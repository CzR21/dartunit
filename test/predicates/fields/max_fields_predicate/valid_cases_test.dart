import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MaxFieldsPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class has no fields (0 <= max)', () {
      final predicate = MaxFieldsPredicate(5);
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when field count equals max', () {
      final predicate = MaxFieldsPredicate(3);
      final result = predicate.analyze(
        classSubject('Model', fields: [
          finalField('a'),
          finalField('b'),
          finalField('c'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when field count is below max', () {
      final predicate = MaxFieldsPredicate(10);
      final result = predicate.analyze(
        classSubject('Small', fields: [finalField('x'), finalField('y')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with max = 0 and no fields', () {
      final predicate = MaxFieldsPredicate(0);
      final result = predicate.analyze(classSubject('ZeroFields'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with single field and max = 1', () {
      final predicate = MaxFieldsPredicate(1);
      final result = predicate.analyze(
        classSubject('Single', fields: [finalField('value')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with large max and many fields', () {
      final fields = List.generate(15, (i) => finalField('field_$i'));
      final predicate = MaxFieldsPredicate(100);
      final result = predicate.analyze(
        classSubject('BigClass', fields: fields),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
