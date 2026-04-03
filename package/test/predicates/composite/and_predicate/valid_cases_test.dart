import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('AndPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when both predicates pass', () {
      final predicate = AndPredicate([
        NameEndsWithPredicate('Service'),
        AnnotatedWithPredicate('injectable'),
      ]);
      final result = predicate.analyze(
        classSubject('UserService', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with single predicate that passes', () {
      final predicate = AndPredicate([NameStartsWithPredicate('My')]);
      final result = predicate.analyze(classSubject('MyClass'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with three predicates all passing', () {
      final predicate = AndPredicate([
        NameStartsWithPredicate('User'),
        NameEndsWithPredicate('Repository'),
        AnnotatedWithPredicate('injectable'),
      ]);
      final result = predicate.analyze(
        classSubject('UserRepository', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with abstract class matching all conditions', () {
      final predicate = AndPredicate([
        IsAbstractPredicate(),
        NameEndsWithPredicate('Repository'),
      ]);
      final result = predicate.analyze(
        classSubject('UserRepository', isAbstract: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with two naming predicates both satisfied', () {
      final predicate = AndPredicate([
        NameStartsWithPredicate('Abstract'),
        NameContainsPredicate('Service'),
      ]);
      final result = predicate.analyze(
        classSubject('AbstractServiceBase'),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with empty predicates list', () {
      final predicate = AndPredicate([]);
      final result = predicate.analyze(classSubject('Anything'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
