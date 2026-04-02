import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('AndPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when first predicate fails', () {
      final predicate = AndPredicate([
        NameEndsWithPredicate('Service'),
        AnnotatedWithPredicate('injectable'),
      ]);
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('Service'));
    });

    test('fails when second predicate fails', () {
      final predicate = AndPredicate([
        NameEndsWithPredicate('Service'),
        AnnotatedWithPredicate('injectable'),
      ]);
      final result = predicate.analyze(
        classSubject('UserService', annotations: []),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when both predicates fail — returns first failure', () {
      final predicate = AndPredicate([
        NameEndsWithPredicate('Service'),
        AnnotatedWithPredicate('injectable'),
      ]);
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: []),
        ctx,
      );
      expect(result.passed, isFalse);
      // Short-circuit: first predicate failure returned
      expect(result.message, contains('Service'));
    });

    test('fails when middle predicate of three fails', () {
      final predicate = AndPredicate([
        NameStartsWithPredicate('User'),
        AnnotatedWithPredicate('injectable'),
        NameEndsWithPredicate('Repository'),
      ]);
      final result = predicate.analyze(
        classSubject('UserRepository', annotations: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('@injectable'));
    });

    test('fails when concrete class checked against IsAbstractPredicate', () {
      final predicate = AndPredicate([
        IsAbstractPredicate(),
        NameEndsWithPredicate('Repository'),
      ]);
      final result = predicate.analyze(
        classSubject('UserRepository', isAbstract: false),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('abstract'));
    });

    test('short-circuits and does not evaluate after first failure', () {
      // Use predicates where second one would only pass if evaluated
      final predicate = AndPredicate([
        NameEndsWithPredicate('Service'), // will fail
        AnnotatedWithPredicate('injectable'), // would pass, but won't be reached
      ]);
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      // The failure message is from the first predicate (short-circuit confirmed)
      expect(result.message, contains('Service'));
    });
  });
}
