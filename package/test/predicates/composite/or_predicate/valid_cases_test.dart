import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('OrPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when first predicate passes', () {
      final predicate = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Cubit'),
      ]);
      final result = predicate.analyze(classSubject('UserBloc'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when second predicate passes', () {
      final predicate = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Cubit'),
      ]);
      final result = predicate.analyze(classSubject('UserCubit'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when both predicates pass', () {
      final predicate = OrPredicate([
        NameStartsWithPredicate('User'),
        NameEndsWithPredicate('Service'),
      ]);
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when single predicate passes', () {
      final predicate = OrPredicate([AnnotatedWithPredicate('injectable')]);
      final result = predicate.analyze(
        classSubject('MyRepo', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when last of three predicates passes', () {
      final predicate = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Cubit'),
        NameEndsWithPredicate('ViewModel'),
      ]);
      final result = predicate.analyze(classSubject('LoginViewModel'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when first of three predicates passes (short-circuit)', () {
      final predicate = OrPredicate([
        NameStartsWithPredicate('Abstract'),
        AnnotatedWithPredicate('injectable'),
        IsAbstractPredicate(),
      ]);
      final result = predicate.analyze(classSubject('AbstractService'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
