import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsConcreteClassPredicate — invalid cases', () {
    const predicate = IsConcreteClassPredicate();
    final ctx = emptyCtx();

    test('fails when class is abstract', () {
      final result = predicate.analyze(
        classSubject('AbstractRepo', isAbstract: true),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('concrete'));
    });

    test('fails when class is a mixin', () {
      final result = predicate.analyze(
        classSubject('LoggingMixin', isMixin: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when class is an enum', () {
      final result = predicate.analyze(
        classSubject('Status', isEnum: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when class is an extension', () {
      final result = predicate.analyze(
        classSubject('StringExt', isExtension: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(
        classSubject('MyAbstract', isAbstract: true),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('MyAbstract'));
    });

    test('failure message contains "must be a concrete class"', () {
      final result = predicate.analyze(
        classSubject('SomeMixin', isMixin: true),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('must be a concrete class'));
    });
  });
}
