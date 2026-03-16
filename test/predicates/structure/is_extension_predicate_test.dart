import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('IsExtensionPredicate', () {
    // Valid cases

    test('passes when declaration is an extension', () {
      final result = const IsExtensionPredicate().evaluate(
        classSubject('StringExtension', isExtension: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for DateTimeExtension', () {
      final result = const IsExtensionPredicate().evaluate(
        classSubject('DateTimeExtension', isExtension: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for ListExtension', () {
      final result = const IsExtensionPredicate().evaluate(
        classSubject('ListExtension', isExtension: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails for a regular class', () {
      final result = const IsExtensionPredicate().evaluate(
        classSubject('StringHelper'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails for a mixin', () {
      final result = const IsExtensionPredicate().evaluate(
        classSubject('StringMixin', isMixin: true),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains class name', () {
      final result = const IsExtensionPredicate().evaluate(
        classSubject('NotAnExtension'),
        emptyCtx(),
      );
      expect(result.message, contains('NotAnExtension'));
    });
  });
}
