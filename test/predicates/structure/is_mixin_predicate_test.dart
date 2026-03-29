import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('IsMixinPredicate', () {
    // Valid cases

    test('passes when declaration is a mixin', () {
      final result = const IsMixinPredicate().analyze(
        classSubject('LoggingMixin', isMixin: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for EquatableMixin', () {
      final result = const IsMixinPredicate().analyze(
        classSubject('EquatableMixin', isMixin: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for CachingMixin', () {
      final result = const IsMixinPredicate().analyze(
        classSubject('CachingMixin', isMixin: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails for a regular class', () {
      final result = const IsMixinPredicate().analyze(
        classSubject('Logger'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails for an abstract class', () {
      final result = const IsMixinPredicate().analyze(
        classSubject('AbstractLogger', isAbstract: true),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains class name', () {
      final result = const IsMixinPredicate().analyze(
        classSubject('NotAMixin'),
        emptyCtx(),
      );
      expect(result.message, contains('NotAMixin'));
    });
  });
}
