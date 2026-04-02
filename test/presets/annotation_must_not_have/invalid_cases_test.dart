import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('annotationMustNotHave preset — invalid cases (NotAnnotatedWithPredicate)', () {
    final ctx = emptyCtx();

    test('fails when class has the forbidden annotation', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('UiWidget', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('injectable'));
    });

    test('fails when forbidden annotation is among multiple', () {
      final predicate = NotAnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('OldService', annotations: ['injectable', 'deprecated']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when UI class accidentally has DI annotation', () {
      final predicate = NotAnnotatedWithPredicate('singleton');
      final result = predicate.analyze(
        classSubject('LoginPage', annotations: ['singleton', 'immutable']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('BadWidget', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('BadWidget'));
    });

    test('failure message contains "NOT"', () {
      final predicate = NotAnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('Legacy', annotations: ['deprecated']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('NOT'));
    });

    test('fails when only forbidden annotation present', () {
      final predicate = NotAnnotatedWithPredicate('visibleForTesting');
      final result = predicate.analyze(
        classSubject('TestHelper', annotations: ['visibleForTesting']),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
