import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('HasMethodPredicate', () {
    // Valid cases

    test('passes when class declares the required method', () {
      final result = HasMethodPredicate('execute').analyze(
        classSubject('GetUserUseCase', methods: [method('execute')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when required method is among many', () {
      final result = HasMethodPredicate('call').analyze(
        classSubject('UseCase', methods: [
          method('init'),
          method('call'),
          method('dispose'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when method name is a private override', () {
      final result = HasMethodPredicate('_buildQuery').analyze(
        classSubject('QueryBuilder', methods: [method('_buildQuery')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when class has no methods', () {
      final result = HasMethodPredicate('execute').analyze(
        classSubject('EmptyClass'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when class has different methods', () {
      final result = HasMethodPredicate('execute').analyze(
        classSubject('MyClass', methods: [method('run'), method('start')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains the expected method name', () {
      final result = HasMethodPredicate('dispose').analyze(
        classSubject('Controller', methods: [method('init')]),
        emptyCtx(),
      );
      expect(result.message, contains('"dispose"'));
    });
  });
}
