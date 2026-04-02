import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('mustBeImmutable preset — invalid cases (HasAllFinalFieldsPredicate)', () {
    const predicate = HasAllFinalFieldsPredicate();
    final ctx = emptyCtx();

    test('fails for entity with mutable field', () {
      final result = predicate.analyze(
        classSubject('User', fields: [
          finalField('id'),
          mutableField('name'), // violation
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('name'));
    });

    test('fails for value object with mutable value', () {
      final result = predicate.analyze(
        classSubject('Counter', fields: [mutableField('count')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(
        classSubject('MutableUser', fields: [mutableField('x')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('MutableUser'));
    });

    test('failure message contains "mutable instance fields"', () {
      final result = predicate.analyze(
        classSubject('Entity', fields: [mutableField('state')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('mutable instance fields'));
    });

    test('fails when multiple mutable fields exist', () {
      final result = predicate.analyze(
        classSubject('MutableModel', fields: [
          mutableField('a'),
          mutableField('b'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('a'));
      expect(result.message, contains('b'));
    });

    test('fails when mutable field coexists with finals', () {
      final result = predicate.analyze(
        classSubject('PartialImmutable', fields: [
          finalField('id'),
          mutableField('name'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('name'));
    });
  });
}
