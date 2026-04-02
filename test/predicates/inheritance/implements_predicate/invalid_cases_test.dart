import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ImplementsPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class implements nothing', () {
      final predicate = ImplementsPredicate('UserRepository');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('UserRepository'));
    });

    test('fails when class implements different interfaces', () {
      final predicate = ImplementsPredicate('UserRepository');
      final result = predicate.analyze(
        classSubject('UserService', implementedTypes: ['Loggable', 'Disposable']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = ImplementsPredicate('Serializable');
      final result = predicate.analyze(
        classSubject('BadClass', implementedTypes: ['Entity']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('BadClass'));
    });

    test('failure message contains required interface name', () {
      final predicate = ImplementsPredicate('Repository');
      final result = predicate.analyze(classSubject('Service'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('Repository'));
    });

    test('fails with empty implementedTypes list', () {
      final predicate = ImplementsPredicate('Comparable');
      final result = predicate.analyze(
        classSubject('Value', implementedTypes: []),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when interface is substring of required but not exact', () {
      final predicate = ImplementsPredicate('UserRepository');
      final result = predicate.analyze(
        classSubject('Impl', implementedTypes: ['Repository']),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
