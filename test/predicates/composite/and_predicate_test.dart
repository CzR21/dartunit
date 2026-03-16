import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AndPredicate', () {
    // Valid cases

    test('passes when all predicates pass', () {
      final result = AndPredicate([
        NameEndsWithPredicate('Bloc'),
        ExtendsPredicate('Bloc'),
      ]).evaluate(
        classSubject('CartBloc', extendedType: 'Bloc'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for a single-predicate AND', () {
      final result = AndPredicate([NameEndsWithPredicate('Service')]).evaluate(
        classSubject('UserService'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for three passing predicates', () {
      final result = AndPredicate([
        NameEndsWithPredicate('Impl'),
        ImplementsPredicate('Repository'),
        NotPredicate(IsAbstractPredicate()),
      ]).evaluate(
        classSubject('UserRepositoryImpl',
            implementedTypes: ['Repository'], isAbstract: false),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when the first predicate fails (short-circuit)', () {
      final result = AndPredicate([
        NameEndsWithPredicate('Bloc'),
        ExtendsPredicate('Bloc'),
      ]).evaluate(
        classSubject('CartService',
            extendedType: 'Bloc'), // name doesn't end with Bloc
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when a later predicate fails', () {
      final result = AndPredicate([
        NameEndsWithPredicate('Bloc'),
        ExtendsPredicate('Bloc'),
      ]).evaluate(
        classSubject('CartBloc',
            extendedType: 'StatefulWidget'), // wrong extends
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message describes the failing predicate', () {
      final result = AndPredicate([
        NameEndsWithPredicate('Repository'),
        ExtendsPredicate('Equatable'),
      ]).evaluate(
        classSubject('UserRepository'), // doesn't extend Equatable
        emptyCtx(),
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('Equatable'));
    });
  });
}
