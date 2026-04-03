import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NameStartsWithPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when name starts with given prefix', () {
      final predicate = NameStartsWithPredicate('Abstract');
      final result = predicate.analyze(classSubject('AbstractRepository'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when prefix equals full name', () {
      final predicate = NameStartsWithPredicate('User');
      final result = predicate.analyze(classSubject('User'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for single character prefix', () {
      final predicate = NameStartsWithPredicate('I');
      final result = predicate.analyze(classSubject('IRepository'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with underscore prefix', () {
      final predicate = NameStartsWithPredicate('_');
      final result = predicate.analyze(classSubject('_PrivateHelper'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with multi-word prefix', () {
      final predicate = NameStartsWithPredicate('Base');
      final result = predicate.analyze(classSubject('BaseUseCase'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when name exactly matches prefix (case sensitive)', () {
      final predicate = NameStartsWithPredicate('My');
      final result = predicate.analyze(classSubject('MyClass'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
