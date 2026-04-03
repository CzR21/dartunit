import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('annotationMustHave preset — valid cases (AnnotatedWithPredicate)', () {
    final ctx = emptyCtx();

    test('passes when class has required annotation', () {
      final predicate = AnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when class has required annotation among many', () {
      final predicate = AnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('OrderRepo', annotations: ['singleton', 'injectable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for immutable annotation on value object', () {
      final predicate = AnnotatedWithPredicate('immutable');
      final result = predicate.analyze(
        classSubject('UserId', annotations: ['immutable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for entity annotation in domain layer', () {
      final predicate = AnnotatedWithPredicate('entity');
      final result = predicate.analyze(
        classSubject('Product', annotations: ['entity']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for annotation on abstract class', () {
      final predicate = AnnotatedWithPredicate('sealed');
      final result = predicate.analyze(
        classSubject('AbstractRepo', isAbstract: true, annotations: ['sealed']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for any annotation that is exactly present', () {
      final predicate = AnnotatedWithPredicate('visibleForTesting');
      final result = predicate.analyze(
        classSubject('TestHelper', annotations: ['visibleForTesting']),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
