import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsAbstractPredicate — invalid cases', () {
    const predicate = IsAbstractPredicate();
    final ctx = emptyCtx();

    test('fails when class is concrete (not abstract)', () {
      final result = predicate.analyze(
        classSubject('ConcreteService', isAbstract: false),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('abstract'));
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(
        classSubject('UserService'),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('UserService'));
    });

    test('fails for concrete class with methods', () {
      final result = predicate.analyze(
        classSubject('Service', methods: [method('run')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails for mixin (not abstract)', () {
      final result = predicate.analyze(
        classSubject('LoggingMixin', isMixin: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails for enum (not abstract)', () {
      final result = predicate.analyze(
        classSubject('Status', isEnum: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains "must be abstract"', () {
      final result = predicate.analyze(classSubject('ConcreteClass'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must be abstract'));
    });
  });
}
