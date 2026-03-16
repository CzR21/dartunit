import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('NameMatchesPatternPredicate', () {
    // Valid cases

    test('passes when name matches BLoC pattern', () {
      final result = NameMatchesPatternPredicate(r'.*Bloc$')
          .evaluate(classSubject('CartBloc'), emptyCtx());
      expect(result.passed, isTrue);
    });

    test('passes when name matches event pattern', () {
      final result = NameMatchesPatternPredicate(r'^Cart.*Event$')
          .evaluate(classSubject('CartAddItemEvent'), emptyCtx());
      expect(result.passed, isTrue);
    });

    test('passes for simple literal pattern', () {
      final result = NameMatchesPatternPredicate(r'UserRepository')
          .evaluate(classSubject('UserRepository'), emptyCtx());
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when name does not match the pattern', () {
      final result = NameMatchesPatternPredicate(r'.*Bloc$')
          .evaluate(classSubject('CartState'), emptyCtx());
      expect(result.passed, isFalse);
    });

    test('fail message contains both name and pattern', () {
      final result = NameMatchesPatternPredicate(r'^I\w+$')
          .evaluate(classSubject('Repository'), emptyCtx());
      expect(result.message, contains('Repository'));
      expect(result.message, contains(r'^I\w+$'));
    });

    test('fails for partial match when anchored', () {
      final result = NameMatchesPatternPredicate(r'^Bloc$')
          .evaluate(classSubject('CartBloc'), emptyCtx());
      expect(result.passed, isFalse);
    });
  });
}
