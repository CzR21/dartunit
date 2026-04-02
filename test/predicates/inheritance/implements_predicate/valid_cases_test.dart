import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ImplementsPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class implements the required type', () {
      final predicate = ImplementsPredicate('UserRepository');
      final result = predicate.analyze(
        classSubject('UserRepositoryImpl', implementedTypes: ['UserRepository']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when class implements multiple interfaces including required', () {
      final predicate = ImplementsPredicate('Serializable');
      final result = predicate.analyze(
        classSubject('User', implementedTypes: ['Entity', 'Serializable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class implementing interface', () {
      final predicate = ImplementsPredicate('Repository');
      final result = predicate.analyze(
        classSubject('AbstractRepo', isAbstract: true, implementedTypes: ['Repository']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when only one interface and it matches', () {
      final predicate = ImplementsPredicate('Comparable');
      final result = predicate.analyze(
        classSubject('MyValue', implementedTypes: ['Comparable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for interface with generic name', () {
      final predicate = ImplementsPredicate('Disposable');
      final result = predicate.analyze(
        classSubject('Service', implementedTypes: ['Disposable', 'Loggable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
