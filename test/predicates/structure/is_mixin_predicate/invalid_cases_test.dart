import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsMixinPredicate — invalid cases', () {
    const predicate = IsMixinPredicate();
    final ctx = emptyCtx();

    test('fails for a regular class', () {
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('mixin'));
    });

    test('fails for abstract class', () {
      final result = predicate.analyze(
        classSubject('AbstractBase', isAbstract: true),
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

    test('fails for extension', () {
      final result = predicate.analyze(
        classSubject('StringExt', isExtension: true),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(classSubject('NotAMixin'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('NotAMixin'));
    });

    test('failure message contains "must be declared as a mixin"', () {
      final result = predicate.analyze(classSubject('PlainClass'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must be declared as a mixin'));
    });
  });
}
