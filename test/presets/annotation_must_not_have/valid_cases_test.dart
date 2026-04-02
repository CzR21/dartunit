import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('annotationMustNotHave preset — valid cases (NotAnnotatedWithPredicate)', () {
    final ctx = emptyCtx();

    test('passes when class has no annotations', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(classSubject('UiWidget'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when class has different annotations', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('Widget', annotations: ['visibleForTesting']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for UI class without DI annotation', () {
      final predicate = NotAnnotatedWithPredicate('singleton');
      final result = predicate.analyze(
        classSubject('LoginPage', annotations: ['immutable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for domain class without infrastructure annotation', () {
      final predicate = NotAnnotatedWithPredicate('sqfliteTable');
      final result = predicate.analyze(
        classSubject('UserEntity', annotations: ['entity']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with empty annotations list', () {
      final predicate = NotAnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('NewFeature', annotations: []),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when annotation differs by case', () {
      final predicate = NotAnnotatedWithPredicate('Injectable');
      final result = predicate.analyze(
        classSubject('Service', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
