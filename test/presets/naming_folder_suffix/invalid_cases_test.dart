import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('namingFolderSuffix preset — invalid cases (NameEndsWithPredicate)', () {
    final ctx = emptyCtx();

    test('fails when class in service folder lacks "Service" suffix', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('UserHelper'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('"Service"'));
    });

    test('fails when repository class has wrong suffix', () {
      final predicate = NameEndsWithPredicate('Repository');
      final result = predicate.analyze(classSubject('UserStore'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = NameEndsWithPredicate('Bloc');
      final result = predicate.analyze(classSubject('UserController'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('UserController'));
    });

    test('fails with case mismatch on suffix', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('UserSERVICE'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when suffix appears in middle of name', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('ServiceWrapper'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains "must end with"', () {
      final predicate = NameEndsWithPredicate('Widget');
      final result = predicate.analyze(classSubject('UserCard'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must end with'));
    });
  });
}
