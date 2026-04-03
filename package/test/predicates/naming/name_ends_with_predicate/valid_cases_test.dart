import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NameEndsWithPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when name ends with given suffix', () {
      final predicate = NameEndsWithPredicate('Repository');
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when suffix equals full name', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('Service'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for single character suffix', () {
      final predicate = NameEndsWithPredicate('r');
      final result = predicate.analyze(classSubject('Controller'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for common Flutter suffix "Widget"', () {
      final predicate = NameEndsWithPredicate('Widget');
      final result = predicate.analyze(classSubject('UserProfileWidget'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for "Bloc" suffix', () {
      final predicate = NameEndsWithPredicate('Bloc');
      final result = predicate.analyze(classSubject('UserBloc'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when name matches exactly', () {
      final predicate = NameEndsWithPredicate('ViewModel');
      final result = predicate.analyze(classSubject('LoginViewModel'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
