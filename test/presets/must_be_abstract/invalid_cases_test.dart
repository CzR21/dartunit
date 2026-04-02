import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('mustBeAbstract preset — invalid cases (IsAbstractPredicate)', () {
    const predicate = IsAbstractPredicate();
    final ctx = emptyCtx();

    test('fails when repository implementation is not abstract', () {
      final result = predicate.analyze(
        classSubject('UserRepositoryImpl'),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('abstract'));
    });

    test('fails for concrete class with concrete methods', () {
      final result = predicate.analyze(
        classSubject('ConcreteService', methods: [method('execute')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(classSubject('NotAbstractThing'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('NotAbstractThing'));
    });

    test('failure message contains "must be abstract"', () {
      final result = predicate.analyze(classSubject('ConcreteRepo'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must be abstract'));
    });

    test('fails for mixin (isMixin:true does not set isAbstract)', () {
      final result = predicate.analyze(
        classSubject('LoggingMixin', isMixin: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails for enum', () {
      final result = predicate.analyze(
        classSubject('Status', isEnum: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
