import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasAllFinalFieldsPredicate — invalid cases', () {
    const predicate = HasAllFinalFieldsPredicate();
    final ctx = emptyCtx();

    test('fails when class has a mutable instance field', () {
      final result = predicate.analyze(
        classSubject('MutableModel', fields: [mutableField('name')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('name'));
    });

    test('fails when one of multiple fields is mutable', () {
      final result = predicate.analyze(
        classSubject('PartiallyFinal', fields: [
          finalField('id'),
          mutableField('name'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('name'));
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(
        classSubject('BadModel', fields: [mutableField('data')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('BadModel'));
    });

    test('failure message contains "mutable instance fields"', () {
      final result = predicate.analyze(
        classSubject('Mutable', fields: [mutableField('x')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('mutable instance fields'));
    });

    test('fails when multiple mutable fields exist', () {
      final result = predicate.analyze(
        classSubject('FullyMutable', fields: [
          mutableField('a'),
          mutableField('b'),
          mutableField('c'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('a'));
      expect(result.message, contains('b'));
    });

    test('fails when mutable field coexists with final and static', () {
      final result = predicate.analyze(
        classSubject('Mixed', fields: [
          finalField('id'),
          staticField('count'),
          mutableField('name'), // this is the problem
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('name'));
    });
  });
}
