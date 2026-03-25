import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('IsEnumPredicate', () {
    // Valid cases

    test('passes when declaration is an enum', () {
      final result = const IsEnumPredicate().analyze(
        classSubject('OrderStatus', isEnum: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for PaymentMethod enum', () {
      final result = const IsEnumPredicate().analyze(
        classSubject('PaymentMethod', isEnum: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for single-value enum', () {
      final result = const IsEnumPredicate().analyze(
        classSubject('Singleton', isEnum: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails for a regular class', () {
      final result = const IsEnumPredicate().analyze(
        classSubject('OrderStatus'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails for an abstract class', () {
      final result = const IsEnumPredicate().analyze(
        classSubject('OrderStatus', isAbstract: true),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains class name', () {
      final result = const IsEnumPredicate().analyze(
        classSubject('NotAnEnum'),
        emptyCtx(),
      );
      expect(result.message, contains('NotAnEnum'));
    });
  });
}
