import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NotAnnotatedWithPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class has the forbidden annotation', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('UserRepo', annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('UserRepo'));
      expect(result.message, contains('@injectable'));
    });

    test('fails when forbidden annotation is among several', () {
      final predicate = NotAnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('OldService', annotations: ['injectable', 'deprecated']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('OldService'));
    });

    test('fails when annotation name is exactly "deprecated"', () {
      final predicate = NotAnnotatedWithPredicate('deprecated');
      final result = predicate.analyze(
        classSubject('Legacy', annotations: ['deprecated']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('@deprecated'));
    });

    test('fails for abstract class with forbidden annotation', () {
      final predicate = NotAnnotatedWithPredicate('injectable');
      final result = predicate.analyze(
        classSubject('AbstractRepo', isAbstract: true, annotations: ['injectable']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('AbstractRepo'));
    });

    test('fails when only the forbidden annotation is present', () {
      final predicate = NotAnnotatedWithPredicate('singleton');
      final result = predicate.analyze(
        classSubject('Cache', annotations: ['singleton']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('must NOT'));
    });

    test('failure message contains NOT keyword', () {
      final predicate = NotAnnotatedWithPredicate('visibleForTesting');
      final result = predicate.analyze(
        classSubject('Foo', annotations: ['visibleForTesting']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('NOT'));
    });
  });
}
