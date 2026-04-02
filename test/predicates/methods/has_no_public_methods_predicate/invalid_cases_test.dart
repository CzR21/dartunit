import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasNoPublicMethodsPredicate — invalid cases', () {
    const predicate = HasNoPublicMethodsPredicate();
    final ctx = emptyCtx();

    test('fails when class has a public method', () {
      final result = predicate.analyze(
        classSubject('Service', methods: [method('fetchUser')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('fetchUser'));
    });

    test('fails when one public among private methods', () {
      final result = predicate.analyze(
        classSubject('Mixed', methods: [method('_private'), method('publicMethod')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('publicMethod'));
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(
        classSubject('Leaky', methods: [method('getData')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('Leaky'));
    });

    test('failure message contains "exposes public methods"', () {
      final result = predicate.analyze(
        classSubject('API', methods: [method('doThing')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('exposes public methods'));
    });

    test('fails with multiple public methods listed in message', () {
      final result = predicate.analyze(
        classSubject('GodClass', methods: [
          method('create'),
          method('read'),
          method('update'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('create'));
      expect(result.message, contains('read'));
    });

    test('fails when public method has non-void return type', () {
      final result = predicate.analyze(
        classSubject('Repo', methods: [method('getAll', returnType: 'List<User>')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('getAll'));
    });
  });
}
