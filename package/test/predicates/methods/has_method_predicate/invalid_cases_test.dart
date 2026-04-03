import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasMethodPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class has no methods', () {
      final predicate = HasMethodPredicate('fetchUser');
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('fetchUser'));
    });

    test('fails when class has different methods', () {
      final predicate = HasMethodPredicate('fetchUser');
      final result = predicate.analyze(
        classSubject('Service', methods: [method('createUser'), method('deleteUser')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = HasMethodPredicate('process');
      final result = predicate.analyze(
        classSubject('Handler', methods: [method('handle')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('Handler'));
    });

    test('failure message contains method name in quotes', () {
      final predicate = HasMethodPredicate('execute');
      final result = predicate.analyze(classSubject('Command'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('"execute"'));
    });

    test('fails when method name is similar but not exact', () {
      final predicate = HasMethodPredicate('fetchUser');
      final result = predicate.analyze(
        classSubject('Repo', methods: [method('fetchUsers')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails for empty methods list', () {
      final predicate = HasMethodPredicate('build');
      final result = predicate.analyze(
        classSubject('Widget', methods: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('must declare a method named'));
    });
  });
}
