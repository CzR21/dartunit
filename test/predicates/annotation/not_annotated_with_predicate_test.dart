import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('NotAnnotatedWithPredicate', () {

    // Valid cases

    test('passes when class does NOT carry the annotation', () {
      final result = NotAnnotatedWithPredicate('deprecated').evaluate(
        classSubject('ActiveService', annotations: []),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when class has other annotations but not the forbidden one', () {
      final result = NotAnnotatedWithPredicate('deprecated').evaluate(
        classSubject('Service', annotations: ['injectable', 'singleton']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when class has no annotations at all', () {
      final result = NotAnnotatedWithPredicate('internal').evaluate(
        classSubject('PublicClass'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when class carries the forbidden annotation', () {
      final result = NotAnnotatedWithPredicate('deprecated').evaluate(
        classSubject('OldService', annotations: ['deprecated']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when forbidden annotation is among multiple', () {
      final result = NotAnnotatedWithPredicate('internal').evaluate(
        classSubject('Cls', annotations: ['injectable', 'internal']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains class name and annotation', () {
      final result = NotAnnotatedWithPredicate('deprecated').evaluate(
        classSubject('LegacyClass', annotations: ['deprecated']),
        emptyCtx(),
      );
      expect(result.message, contains('deprecated'));
      expect(result.message, contains('LegacyClass'));
    });
  });
}
