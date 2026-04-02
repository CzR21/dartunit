import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NameMatchesPatternPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when name matches regex pattern', () {
      final predicate = NameMatchesPatternPredicate(r'.*(Bloc|Cubit)$');
      final result = predicate.analyze(classSubject('UserBloc'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when name matches second alternative in OR pattern', () {
      final predicate = NameMatchesPatternPredicate(r'.*(Bloc|Cubit)$');
      final result = predicate.analyze(classSubject('UserCubit'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with simple prefix pattern', () {
      final predicate = NameMatchesPatternPredicate(r'^Abstract.*');
      final result = predicate.analyze(classSubject('AbstractRepository'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for pattern matching any characters', () {
      final predicate = NameMatchesPatternPredicate(r'User\w+');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for literal string pattern', () {
      final predicate = NameMatchesPatternPredicate('Service');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when name matches exactly with anchors', () {
      final predicate = NameMatchesPatternPredicate(r'^UserRepository$');
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
