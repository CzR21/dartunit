import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('mustBeAbstract preset — valid cases (IsAbstractPredicate)', () {
    const predicate = IsAbstractPredicate();
    final ctx = emptyCtx();

    test('passes when repository interface is abstract', () {
      final result = predicate.analyze(
        classSubject('UserRepository', isAbstract: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when use case class is abstract', () {
      final result = predicate.analyze(
        classSubject('FetchUserUseCase', isAbstract: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with abstract methods', () {
      final result = predicate.analyze(
        classSubject('AbstractMapper', isAbstract: true, methods: [method('map')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with annotations', () {
      final result = predicate.analyze(
        classSubject('AbstractRepo', isAbstract: true, annotations: ['sealed']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with implemented interfaces', () {
      final result = predicate.analyze(
        classSubject('AbstractService', isAbstract: true, implementedTypes: ['Disposable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with no members', () {
      final result = predicate.analyze(
        classSubject('MarkerInterface', isAbstract: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
