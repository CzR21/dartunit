import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('AnnotatedWithPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when annotation exactly matches', () {
      final predicate = AnnotatedWithPredicate('immutable');
      final result = predicate.analyze(
        classSubject('Point', annotations: ['immutable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when class has multiple annotations and target is present', () {
      final predicate = AnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: ['injectable', 'singleton']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for annotation named "override"', () {
      final predicate = AnnotatedWithPredicate('override');
      final result = predicate.analyze(
        classSubject('MyWidget', annotations: ['override']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for annotation named "deprecated"', () {
      final predicate = AnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('OldService', annotations: ['deprecated']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when annotation is the only one in the list', () {
      final predicate = AnnotatedWithPredicate('entity');
      final result = predicate.analyze(
        classSubject('User', annotations: ['entity']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with matching annotation', () {
      final predicate = AnnotatedWithPredicate('sealed');
      final result = predicate.analyze(
        classSubject('BaseRepo', isAbstract: true, annotations: ['sealed']),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
