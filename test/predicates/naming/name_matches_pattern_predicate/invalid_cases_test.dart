import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NameMatchesPatternPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when name does not match pattern', () {
      final predicate = NameMatchesPatternPredicate(r'.*(Bloc|Cubit)$');
      final result = predicate.analyze(classSubject('UserViewModel'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('UserViewModel'));
    });

    test('failure message contains pattern', () {
      final predicate = NameMatchesPatternPredicate(r'^Abstract.*');
      final result = predicate.analyze(classSubject('ConcreteService'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains(r'^Abstract.*'));
    });

    test('fails when anchored pattern does not match', () {
      final predicate = NameMatchesPatternPredicate(r'^UserRepository$');
      final result = predicate.analyze(classSubject('UserRepositoryImpl'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains "must match pattern"', () {
      final predicate = NameMatchesPatternPredicate(r'\w+Service');
      final result = predicate.analyze(classSubject('UserBloc'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('must match pattern'));
    });

    test('fails for case-sensitive pattern mismatch', () {
      final predicate = NameMatchesPatternPredicate(r'service');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      // RegExp is case-sensitive by default — 'Service' doesn't match 'service'
      expect(result.passed, isFalse);
    });

    test('fails when class name contains pattern only as substring with anchors', () {
      final predicate = NameMatchesPatternPredicate(r'^Repository$');
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isFalse);
    });
  });
}
