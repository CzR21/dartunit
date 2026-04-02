import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NotAnnotatedWithPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class has no annotations', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(classSubject('UserRepo'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when annotation list has different annotation', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('MyClass', annotations: ['immutable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when annotation is absent among multiple others', () {
      final predicate = NotAnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('Service', annotations: ['injectable', 'singleton']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class without the forbidden annotation', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('BaseRepo', isAbstract: true, annotations: ['sealed']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when annotation name has similar but different casing', () {
      // 'Injectable' != 'injectable' — strict case match
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('MyClass', annotations: ['Injectable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when empty annotations list', () {
      final predicate = NotAnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('OldThing', annotations: []),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
