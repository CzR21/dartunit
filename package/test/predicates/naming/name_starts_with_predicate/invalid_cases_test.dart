import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NameStartsWithPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when name does not start with prefix', () {
      final predicate = NameStartsWithPredicate('Abstract');
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('"Abstract"'));
    });

    test('failure message contains class name', () {
      final predicate = NameStartsWithPredicate('Base');
      final result = predicate.analyze(classSubject('ConcreteService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('ConcreteService'));
    });

    test('fails with case mismatch', () {
      final predicate = NameStartsWithPredicate('abstract');
      final result = predicate.analyze(classSubject('AbstractRepo'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when prefix appears in middle of name', () {
      final predicate = NameStartsWithPredicate('Base');
      final result = predicate.analyze(classSubject('AbstractBase'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when prefix appears at end of name', () {
      final predicate = NameStartsWithPredicate('Base');
      final result = predicate.analyze(classSubject('ServiceBase'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains "must start with"', () {
      final predicate = NameStartsWithPredicate('I');
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must start with'));
    });
  });
}
