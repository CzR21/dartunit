import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('mustBeImmutable preset — valid cases (HasAllFinalFieldsPredicate)', () {
    const predicate = HasAllFinalFieldsPredicate();
    final ctx = emptyCtx();

    test('passes for entity with all final fields', () {
      final result = predicate.analyze(
        classSubject('User', fields: [
          finalField('id'),
          finalField('name'),
          finalField('email'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for value object with single final field', () {
      final result = predicate.analyze(
        classSubject('UserId', fields: [finalField('value')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for entity with no instance fields', () {
      final result = predicate.analyze(classSubject('MarkerEntity'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when only static fields (excluded from check)', () {
      final result = predicate.analyze(
        classSubject('Config', fields: [staticField('instance')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for domain event with all final fields', () {
      final result = predicate.analyze(
        classSubject('UserCreatedEvent', fields: [
          finalField('userId'),
          finalField('timestamp'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with mix of final instance and static fields', () {
      final result = predicate.analyze(
        classSubject('Entity', fields: [
          finalField('id'),
          staticField('tableName'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
