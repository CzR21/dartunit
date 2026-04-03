import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsConcreteClassPredicate — valid cases', () {
    const predicate = IsConcreteClassPredicate();
    final ctx = emptyCtx();

    test('passes for a plain concrete class', () {
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for concrete class with fields and methods', () {
      final result = predicate.analyze(
        classSubject('UserRepo', methods: [method('fetch')], fields: [finalField('db')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for concrete class with implements', () {
      final result = predicate.analyze(
        classSubject('UserRepoImpl', implementedTypes: ['UserRepo']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for concrete class with extends', () {
      final result = predicate.analyze(
        classSubject('SpecialService', extendedType: 'BaseService'),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for concrete class with all flags false', () {
      final result = predicate.analyze(
        classSubject('Simple',
          isAbstract: false,
          isMixin: false,
          isEnum: false,
          isExtension: false,
        ),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
