import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('NameStartsWithPredicate', () {
    // Valid cases

    test('passes when name starts with the required prefix', () {
      final result = NameStartsWithPredicate('Abstract')
          .evaluate(classSubject('AbstractRepository'), emptyCtx());
      expect(result.passed, isTrue);
    });

    test('passes with single-letter prefix', () {
      final result = NameStartsWithPredicate('I')
          .evaluate(classSubject('IRepository'), emptyCtx());
      expect(result.passed, isTrue);
    });

    test('passes when name equals prefix exactly', () {
      final result = NameStartsWithPredicate('Base')
          .evaluate(classSubject('Base'), emptyCtx());
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when name does not start with prefix', () {
      final result = NameStartsWithPredicate('Abstract')
          .evaluate(classSubject('UserRepository'), emptyCtx());
      expect(result.passed, isFalse);
    });

    test('fail message contains class name and prefix', () {
      final result = NameStartsWithPredicate('Base')
          .evaluate(classSubject('UserService'), emptyCtx());
      expect(result.message, contains('Base'));
      expect(result.message, contains('UserService'));
    });

    test('fails on case mismatch', () {
      final result = NameStartsWithPredicate('abstract')
          .evaluate(classSubject('AbstractService'), emptyCtx());
      expect(result.passed, isFalse);
    });
  });
}
