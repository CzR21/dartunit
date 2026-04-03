import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MaxMethodsPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class has no methods', () {
      final predicate = MaxMethodsPredicate(5);
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when method count equals max', () {
      final predicate = MaxMethodsPredicate(3);
      final result = predicate.analyze(
        classSubject('Small', methods: [method('a'), method('b'), method('c')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when method count is below max', () {
      final predicate = MaxMethodsPredicate(10);
      final result = predicate.analyze(
        classSubject('Slim', methods: [method('fetch'), method('save')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with max = 0 and no methods', () {
      final predicate = MaxMethodsPredicate(0);
      final result = predicate.analyze(classSubject('ZeroMethods'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with single method and max = 1', () {
      final predicate = MaxMethodsPredicate(1);
      final result = predicate.analyze(
        classSubject('Minimal', methods: [method('run')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with large max and many methods', () {
      final methods = List.generate(20, (i) => method('m$i'));
      final predicate = MaxMethodsPredicate(100);
      final result = predicate.analyze(
        classSubject('Rich', methods: methods),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
