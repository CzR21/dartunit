import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('namingNamePattern preset — invalid cases (NameMatchesPatternPredicate)', () {
    final ctx = emptyCtx();

    test('fails when class name does not match Bloc/Cubit pattern', () {
      final predicate = NameMatchesPatternPredicate(r'.*(Bloc|Cubit)$');
      final result = predicate.analyze(classSubject('UserViewModel'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('UserViewModel'));
    });

    test('fails when class name does not match abstract prefix pattern', () {
      final predicate = NameMatchesPatternPredicate(r'^Abstract\w+');
      final result = predicate.analyze(classSubject('ConcreteRepository'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains pattern', () {
      final predicate = NameMatchesPatternPredicate(r'\w+Service$');
      final result = predicate.analyze(classSubject('UserBloc'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains(r'\w+Service$'));
    });

    test('fails when anchored pattern does not match substring', () {
      final predicate = NameMatchesPatternPredicate(r'^Repository$');
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains "must match pattern"', () {
      final predicate = NameMatchesPatternPredicate(r'.*(Bloc|Cubit)$');
      final result = predicate.analyze(classSubject('LoginService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must match pattern'));
    });

    test('fails for case-sensitive pattern mismatch', () {
      final predicate = NameMatchesPatternPredicate(r'bloc$');
      final result = predicate.analyze(classSubject('UserBloc'), ctx);
      expect(result.passed, isFalse);
    });
  });
}
