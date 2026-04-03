import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasAllFinalFieldsPredicate — valid cases', () {
    const predicate = HasAllFinalFieldsPredicate();
    final ctx = emptyCtx();

    test('passes when class has no fields', () {
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when all fields are final', () {
      final result = predicate.analyze(
        classSubject('User', fields: [
          finalField('name'),
          finalField('email'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when only static fields are present (non-instance)', () {
      final result = predicate.analyze(
        classSubject('Config', fields: [staticField('instance')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when mix of final and static fields (no mutable instance fields)', () {
      final result = predicate.analyze(
        classSubject('Model', fields: [
          finalField('id'),
          staticField('count'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when const fields are present (treated as non-mutable)', () {
      final constField = AnalyzedField(name: 'PI', type: 'double', isConst: true);
      final result = predicate.analyze(
        classSubject('MathConst', fields: [constField]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with single final field', () {
      final result = predicate.analyze(
        classSubject('Point', fields: [finalField('x')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
