import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NameEndsWithPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when name does not end with suffix', () {
      final predicate = NameEndsWithPredicate('Repository');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('"Repository"'));
    });

    test('failure message contains class name', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('UserController'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('UserController'));
    });

    test('fails with case mismatch', () {
      final predicate = NameEndsWithPredicate('service');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when suffix appears in middle', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('ServiceWrapper'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when suffix appears at start', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('ServiceBase'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains "must end with"', () {
      final predicate = NameEndsWithPredicate('Bloc');
      final result = predicate.analyze(classSubject('UserViewModel'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must end with'));
    });
  });
}
