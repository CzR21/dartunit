import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsExtensionPredicate — invalid cases', () {
    const predicate = IsExtensionPredicate();
    final ctx = emptyCtx();

    test('fails for a regular class', () {
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('extension'));
    });

    test('fails for abstract class', () {
      final result = predicate.analyze(
        classSubject('AbstractBase', isAbstract: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails for mixin', () {
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

    test('failure message contains class name', () {
      final result = predicate.analyze(classSubject('NotAnExtension'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('NotAnExtension'));
    });

    test('failure message contains "must be declared as an extension"', () {
      final result = predicate.analyze(classSubject('PlainClass'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must be declared as an extension'));
    });
  });
}
