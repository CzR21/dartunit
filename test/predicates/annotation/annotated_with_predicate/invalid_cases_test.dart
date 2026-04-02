import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('AnnotatedWithPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class has no annotations', () {
      final predicate = AnnotatedWithPredicate('immutable');
      final result = predicate.analyze(
        classSubject('Point'),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('Point'));
      expect(result.message, contains('@immutable'));
    });

    test('fails when annotation list has different annotation', () {
      final predicate = AnnotatedWithPredicate('immutable');
      final result = predicate.analyze(
        classSubject('MyClass', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('MyClass'));
    });

    test('fails when annotation name is a substring but not exact match', () {
      final predicate = AnnotatedWithPredicate('immutable');
      final result = predicate.analyze(
        classSubject('MyClass', annotations: ['mutable']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when annotation case does not match', () {
      final predicate = AnnotatedWithPredicate('Immutable');
      final result = predicate.analyze(
        classSubject('MyClass', annotations: ['immutable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('@Immutable'));
    });

    test('fails for abstract class missing required annotation', () {
      final predicate = AnnotatedWithPredicate('sealed');
      final result = predicate.analyze(
        classSubject('BaseRepo', isAbstract: true, annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('BaseRepo'));
    });

    test('fails when annotations list is empty', () {
      final predicate = AnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('OldThing', annotations: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('@deprecated'));
    });
  });
}
