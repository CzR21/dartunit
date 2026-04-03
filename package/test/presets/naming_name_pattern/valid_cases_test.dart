import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('namingNamePattern preset — valid cases (NameMatchesPatternPredicate)', () {
    final ctx = emptyCtx();

    test('passes when class name matches Bloc/Cubit pattern', () {
      final predicate = NameMatchesPatternPredicate(r'.*(Bloc|Cubit)$');
      final result = predicate.analyze(classSubject('UserBloc'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for Cubit alternative', () {
      final predicate = NameMatchesPatternPredicate(r'.*(Bloc|Cubit)$');
      final result = predicate.analyze(classSubject('LoginCubit'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when class name matches abstract prefix pattern', () {
      final predicate = NameMatchesPatternPredicate(r'^Abstract\w+');
      final result = predicate.analyze(classSubject('AbstractRepository'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for snake_case-like numeric suffix pattern', () {
      final predicate = NameMatchesPatternPredicate(r'\w+V\d+$');
      final result = predicate.analyze(classSubject('UserEntityV2'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for simple literal pattern', () {
      final predicate = NameMatchesPatternPredicate('Service');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes for anchored exact match', () {
      final predicate = NameMatchesPatternPredicate(r'^UserRepository$');
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
