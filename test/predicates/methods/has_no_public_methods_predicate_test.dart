import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('HasNoPublicMethodsPredicate', () {
    // Valid cases

    test('passes when all methods are private', () {
      final result = const HasNoPublicMethodsPredicate().analyze(
        classSubject('InternalHelper', methods: [
          method('_compute'),
          method('_validate'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when class has no methods', () {
      final result = const HasNoPublicMethodsPredicate().analyze(
        classSubject('DataHolder'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes with only one private method', () {
      final result = const HasNoPublicMethodsPredicate().analyze(
        classSubject('Singleton', methods: [method('_getInstance')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when class has a public method', () {
      final result = const HasNoPublicMethodsPredicate().analyze(
        classSubject('Service', methods: [method('execute')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message lists the public method names', () {
      final result = const HasNoPublicMethodsPredicate().analyze(
        classSubject('Repo', methods: [
          method('findById'),
          method('save'),
          method('_validate'),
        ]),
        emptyCtx(),
      );
      expect(result.message, contains('findById'));
      expect(result.message, contains('save'));
      expect(result.message, isNot(contains('_validate')));
    });

    test('fails for a single public method', () {
      final result = const HasNoPublicMethodsPredicate().analyze(
        classSubject('Validator', methods: [method('validate')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });
  });
}
