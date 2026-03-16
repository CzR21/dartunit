import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('HasNoPublicFieldsPredicate', () {
    // Valid cases

    test('passes when all instance fields are private (underscore prefix)', () {
      final result = const HasNoPublicFieldsPredicate().evaluate(
        classSubject('UserService', fields: [
          finalField('_repository'),
          finalField('_logger'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when there are no instance fields', () {
      final result = const HasNoPublicFieldsPredicate().evaluate(
        classSubject('StatelessClass'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when public fields are static (ignored)', () {
      final result = const HasNoPublicFieldsPredicate().evaluate(
        classSubject('Constants', fields: [
          staticField('baseUrl'),
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when a public instance field is exposed', () {
      final result = const HasNoPublicFieldsPredicate().evaluate(
        classSubject('UserModel', fields: [finalField('name')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains the public field name', () {
      final result = const HasNoPublicFieldsPredicate().evaluate(
        classSubject('CartModel', fields: [
          finalField('id'),
          finalField('total'),
        ]),
        emptyCtx(),
      );
      expect(result.message, contains('id'));
      expect(result.message, contains('total'));
    });

    test('fails for a mutable public field', () {
      final result = const HasNoPublicFieldsPredicate().evaluate(
        classSubject('Counter', fields: [mutableField('count')]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });
  });
}
