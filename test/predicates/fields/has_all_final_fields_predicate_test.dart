import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('HasAllFinalFieldsPredicate', () {
    // Valid cases

    test('passes when all instance fields are final', () {
      final result = const HasAllFinalFieldsPredicate().analyze(
        classSubject('User', fields: [
          finalField('id'),
          finalField('name'),
          finalField('email'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when all fields are const', () {
      final result = const HasAllFinalFieldsPredicate().analyze(
        classSubject('Config', fields: [
          const AnalyzedField(name: 'maxRetries', type: 'int', isConst: true),
          const AnalyzedField(name: 'timeout', type: 'int', isConst: true),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when mutable fields are static (ignored)', () {
      final result = const HasAllFinalFieldsPredicate().analyze(
        classSubject('Singleton', fields: [
          staticField('_instance'),
          finalField('id'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for a class with no fields', () {
      final result = const HasAllFinalFieldsPredicate().analyze(
        classSubject('EmptyClass'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when there is a mutable instance field', () {
      final result = const HasAllFinalFieldsPredicate().analyze(
        classSubject('Counter', fields: [mutableField('count', type: 'int')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message lists the mutable field name', () {
      final result = const HasAllFinalFieldsPredicate().analyze(
        classSubject('Cart', fields: [
          finalField('id'),
          mutableField('total'),
        ]),
        emptyCtx(),
      );
      expect(result.message, contains('total'));
    });

    test('fails when multiple mutable fields exist', () {
      final result = const HasAllFinalFieldsPredicate().analyze(
        classSubject('State', fields: [
          mutableField('loading'),
          mutableField('error'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('loading'));
      expect(result.message, contains('error'));
    });
  });
}
