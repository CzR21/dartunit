import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MinFieldsPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when field count equals min', () {
      final predicate = MinFieldsPredicate(2);
      final result = predicate.analyze(
        classSubject('Entity', fields: [finalField('a'), finalField('b')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when field count exceeds min', () {
      final predicate = MinFieldsPredicate(2);
      final result = predicate.analyze(
        classSubject('Rich', fields: [finalField('a'), finalField('b'), finalField('c')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with min = 0 and no fields', () {
      final predicate = MinFieldsPredicate(0);
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with min = 0 and several fields', () {
      final predicate = MinFieldsPredicate(0);
      final result = predicate.analyze(
        classSubject('Any', fields: [finalField('x'), finalField('y')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with min = 1 and one field', () {
      final predicate = MinFieldsPredicate(1);
      final result = predicate.analyze(
        classSubject('Single', fields: [finalField('value')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with large min satisfied by many fields', () {
      final fields = List.generate(10, (i) => finalField('f$i'));
      final predicate = MinFieldsPredicate(5);
      final result = predicate.analyze(
        classSubject('LargeModel', fields: fields),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
