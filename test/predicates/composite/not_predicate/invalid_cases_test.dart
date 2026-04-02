import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NotPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when inner predicate passes', () {
      // AnnotatedWithPredicate passes → NotPredicate fails
      final predicate = NotPredicate(AnnotatedWithPredicate('injectable'));
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when inner NameEndsWith passes', () {
      final predicate = NotPredicate(NameEndsWithPredicate('Service'));
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when inner IsAbstractPredicate passes for abstract class', () {
      final predicate = NotPredicate(IsAbstractPredicate());
      final result = predicate.analyze(
        classSubject('AbstractRepo', isAbstract: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when inner DependOnFolderPredicate passes', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/data/user_repo.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message is reused from inner pass message when non-empty', () {
      // DependOnFolderPredicate.pass() returns a non-empty message
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/data/user_repo.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      // The inner pass message mentions the folder
      expect(result.message, contains('lib/data'));
    });

    test('failure message contains subject name when inner pass message is empty', () {
      // AnnotatedWithPredicate passes with empty message (const PredicateResult.pass())
      // NotPredicate falls back to "subject must NOT satisfy the condition"
      final predicate = NotPredicate(AnnotatedWithPredicate('injectable'));
      final result = predicate.analyze(
        classSubject('MyRepo', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, isNotEmpty);
    });
  });
}
