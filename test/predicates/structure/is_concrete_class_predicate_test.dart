import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('IsConcreteClassPredicate', () {
    // Valid cases

    test('passes for a regular concrete class', () {
      final result = const IsConcreteClassPredicate().evaluate(
        classSubject('UserRepositoryImpl'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for a concrete class with fields', () {
      final result = const IsConcreteClassPredicate().evaluate(
        classSubject('CartBloc', fields: [finalField('_repository')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for a plain data class', () {
      final result = const IsConcreteClassPredicate().evaluate(
        classSubject('User', fields: [finalField('id'), finalField('name')]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails for an abstract class', () {
      final result = const IsConcreteClassPredicate().evaluate(
        classSubject('AbstractRepository', isAbstract: true),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails for a mixin', () {
      final result = const IsConcreteClassPredicate().evaluate(
        classSubject('LoggingMixin', isMixin: true),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails for an enum', () {
      final result = const IsConcreteClassPredicate().evaluate(
        classSubject('Status', isEnum: true),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });
  });
}
