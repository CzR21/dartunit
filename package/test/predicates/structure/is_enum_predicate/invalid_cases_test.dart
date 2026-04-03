import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsEnumPredicate — invalid cases', () {
    const predicate = IsEnumPredicate();
    final ctx = emptyCtx();

    test('fails when class is a regular class', () {
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('enum'));
    });

    test('fails when class is abstract', () {
      final result = predicate.analyze(
        classSubject('AbstractBase', isAbstract: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when class is a mixin', () {
      final result = predicate.analyze(
        classSubject('LoggingMixin', isMixin: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(classSubject('Status'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('Status'));
    });

    test('failure message contains "must be declared as an enum"', () {
      final result = predicate.analyze(classSubject('Color'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must be declared as an enum'));
    });

    test('fails when isEnum is explicitly false', () {
      final result = predicate.analyze(
        classSubject('NotEnum', isEnum: false),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
