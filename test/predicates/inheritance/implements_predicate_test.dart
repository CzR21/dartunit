import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ImplementsPredicate', () {
    // Valid cases

    test('passes when class implements the required interface', () {
      final result = ImplementsPredicate('UserRepository').evaluate(
        classSubject('UserRepositoryImpl',
            implementedTypes: ['UserRepository']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test(
        'passes when class implements multiple interfaces including the required',
        () {
      final result = ImplementsPredicate('Serializable').evaluate(
        classSubject('UserDto',
            implementedTypes: ['Comparable', 'Serializable']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes with a single-word interface', () {
      final result = ImplementsPredicate('Comparable').evaluate(
        classSubject('Money', implementedTypes: ['Comparable']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when class does not implement any interface', () {
      final result = ImplementsPredicate('UserRepository').evaluate(
        classSubject('UserRepositoryImpl', implementedTypes: []),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when class implements different interfaces', () {
      final result = ImplementsPredicate('UserRepository').evaluate(
        classSubject('UserRepositoryImpl',
            implementedTypes: ['CartRepository', 'OrderRepository']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains the interface name', () {
      final result = ImplementsPredicate('PaymentGateway').evaluate(
        classSubject('StripeService', implementedTypes: []),
        emptyCtx(),
      );
      expect(result.message, contains('PaymentGateway'));
    });
  });
}
