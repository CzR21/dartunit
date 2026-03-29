import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('OrPredicate', () {
    // Valid cases

    test('passes when the first predicate passes', () {
      final result = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Event'),
      ]).analyze(
        classSubject('CartBloc'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when only the last predicate passes', () {
      final result = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Event'),
        NameEndsWithPredicate('State'),
      ]).analyze(
        classSubject('CartState'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when class satisfies the second of two predicates', () {
      final result = OrPredicate([
        IsAbstractPredicate(),
        NameEndsWithPredicate('Impl'),
      ]).analyze(
        classSubject('UserRepositoryImpl'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when no predicate passes', () {
      final result = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('Event'),
      ]).analyze(
        classSubject('UserRepository'), // ends with neither
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails for single-predicate OR that does not pass', () {
      final result = OrPredicate([NameEndsWithPredicate('Service')]).analyze(
        classSubject('UserRepository'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message aggregates all sub-predicate messages', () {
      final result = OrPredicate([
        NameEndsWithPredicate('Bloc'),
        NameEndsWithPredicate('State'),
      ]).analyze(
        classSubject('CartPage'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
      // Both failure messages combined with OR
      expect(result.message, contains('OR'));
    });
  });
}
