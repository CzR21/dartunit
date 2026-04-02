import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NameContainsPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when name contains the substring', () {
      final predicate = NameContainsPredicate('Repository');
      final result = predicate.analyze(classSubject('UserRepositoryImpl'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when substring is at the start', () {
      final predicate = NameContainsPredicate('User');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when substring is at the end', () {
      final predicate = NameContainsPredicate('Service');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when substring equals full name', () {
      final predicate = NameContainsPredicate('Service');
      final result = predicate.analyze(classSubject('Service'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for single character substring', () {
      final predicate = NameContainsPredicate('X');
      final result = predicate.analyze(classSubject('XmlParser'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when substring appears multiple times', () {
      final predicate = NameContainsPredicate('User');
      final result = predicate.analyze(classSubject('UserUserHelper'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
