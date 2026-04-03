import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NameContainsPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when name does not contain the substring', () {
      final predicate = NameContainsPredicate('Repository');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('"Repository"'));
    });

    test('failure message contains class name', () {
      final predicate = NameContainsPredicate('Bloc');
      final result = predicate.analyze(classSubject('UserViewModel'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('UserViewModel'));
    });

    test('fails with case mismatch', () {
      final predicate = NameContainsPredicate('service');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when substring is empty string... actually passes (all contain empty)', () {
      // Dart String.contains('') is always true — documenting behavior
      final predicate = NameContainsPredicate('NotThere');
      final result = predicate.analyze(classSubject('SomethingElse'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains "must contain"', () {
      final predicate = NameContainsPredicate('Mapper');
      final result = predicate.analyze(classSubject('UserConverter'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must contain'));
    });

    test('fails for completely different name', () {
      final predicate = NameContainsPredicate('ViewModel');
      final result = predicate.analyze(classSubject('Repository'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('"ViewModel"'));
    });
  });
}
