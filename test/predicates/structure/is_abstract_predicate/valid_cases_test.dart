import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsAbstractPredicate — valid cases', () {
    const predicate = IsAbstractPredicate();
    final ctx = emptyCtx();

    test('passes when class is abstract', () {
      final result = predicate.analyze(
        classSubject('AbstractRepo', isAbstract: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with methods', () {
      final result = predicate.analyze(
        classSubject('BaseService', isAbstract: true, methods: [method('execute')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with annotations', () {
      final result = predicate.analyze(
        classSubject('AbstractModel', isAbstract: true, annotations: ['sealed']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with implements', () {
      final result = predicate.analyze(
        classSubject('AbstractRepo', isAbstract: true, implementedTypes: ['Repository']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class with no members', () {
      final result = predicate.analyze(
        classSubject('EmptyAbstract', isAbstract: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
