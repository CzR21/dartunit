import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasMethodPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class has the required method', () {
      final predicate = HasMethodPredicate('fetchUser');
      final result = predicate.analyze(
        classSubject('UserRepo', methods: [method('fetchUser')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when required method is among several', () {
      final predicate = HasMethodPredicate('save');
      final result = predicate.analyze(
        classSubject('Store', methods: [method('load'), method('save'), method('delete')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for private method match', () {
      final predicate = HasMethodPredicate('_validate');
      final result = predicate.analyze(
        classSubject('Service', methods: [method('_validate'), method('process')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for method named "build"', () {
      final predicate = HasMethodPredicate('build');
      final result = predicate.analyze(
        classSubject('MyWidget', methods: [method('build', returnType: 'Widget')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when class has exactly one method that matches', () {
      final predicate = HasMethodPredicate('execute');
      final result = predicate.analyze(
        classSubject('Command', methods: [method('execute')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes regardless of return type', () {
      final predicate = HasMethodPredicate('getUser');
      final result = predicate.analyze(
        classSubject('Repo', methods: [method('getUser', returnType: 'Future<User>')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
