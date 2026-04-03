import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('OrPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when all predicates fail', () {
      final predicate = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Cubit'),
      ]);
      final result = predicate.analyze(classSubject('UserViewModel'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains "None of the OR conditions"', () {
      final predicate = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Cubit'),
      ]);
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('None of the OR conditions'));
    });

    test('failure message includes all individual failure reasons', () {
      final predicate = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Cubit'),
      ]);
      final result = predicate.analyze(classSubject('UserViewModel'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('Bloc'));
      expect(result.message, contains('Cubit'));
    });

    test('fails when single predicate fails', () {
      final predicate = OrPredicate([AnnotatedWithPredicate('injectable')]);
      final result = predicate.analyze(classSubject('MyRepo'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when three predicates all fail', () {
      final predicate = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Cubit'),
        AnnotatedWithPredicate('injectable'),
      ]);
      final result = predicate.analyze(
        classSubject('UserViewModel', annotations: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('None of the OR conditions'));
    });

    test('fails with combined message from all predicates', () {
      final predicate = OrPredicate([
        AnnotatedWithPredicate('injectable'),
        IsAbstractPredicate(),
      ]);
      final result = predicate.analyze(
        classSubject('ConcreteService', isAbstract: false, annotations: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('@injectable'));
      expect(result.message, contains('abstract'));
    });
  });
}
