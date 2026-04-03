import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('annotationMustHave preset — invalid cases (AnnotatedWithPredicate)', () {
    final ctx = emptyCtx();

    test('fails when class is missing required annotation', () {
      final predicate = AnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('@injectable'));
    });

    test('fails when class has different annotation', () {
      final predicate = AnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('OrderRepo', annotations: ['singleton']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when annotation has wrong case', () {
      final predicate = AnnotatedWithPredicate('Injectable');
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails for class with no annotations at all', () {
      final predicate = AnnotatedWithPredicate('immutable');
      final result = predicate.analyze(classSubject('User'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('User'));
    });

    test('fails when annotation is substring match only', () {
      final predicate = AnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('Repo', annotations: ['notInjectable']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name and annotation', () {
      final predicate = AnnotatedWithPredicate('entity');
      final result = predicate.analyze(classSubject('User'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('User'));
      expect(result.message, contains('@entity'));
    });
  });
}
