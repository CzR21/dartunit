import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('NameContainsPredicate', () {

    // Valid cases

    test('passes when name contains the substring exactly', () {
      final result = NameContainsPredicate('Repository')
          .evaluate(classSubject('UserRepository'), emptyCtx());
      expect(result.passed, isTrue);
    });

    test('passes when substring appears in the middle', () {
      final result = NameContainsPredicate('Data')
          .evaluate(classSubject('UserDataSource'), emptyCtx());
      expect(result.passed, isTrue);
    });

    test('passes when substring is the full name', () {
      final result = NameContainsPredicate('Bloc')
          .evaluate(classSubject('Bloc'), emptyCtx());
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when name does not contain the substring', () {
      final result = NameContainsPredicate('Repository')
          .evaluate(classSubject('UserService'), emptyCtx());
      expect(result.passed, isFalse);
    });

    test('fails when case does not match', () {
      final result = NameContainsPredicate('repository')
          .evaluate(classSubject('UserRepository'), emptyCtx());
      expect(result.passed, isFalse);
    });

    test('fail message contains the missing substring', () {
      final result = NameContainsPredicate('Bloc')
          .evaluate(classSubject('UserService'), emptyCtx());
      expect(result.passed, isFalse);
      expect(result.message, contains('Bloc'));
    });
  });
}
