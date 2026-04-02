import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MinMethodsPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when method count equals min', () {
      final predicate = MinMethodsPredicate(2);
      final result = predicate.analyze(
        classSubject('Service', methods: [method('a'), method('b')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when method count exceeds min', () {
      final predicate = MinMethodsPredicate(2);
      final result = predicate.analyze(
        classSubject('Rich', methods: [method('a'), method('b'), method('c')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with min = 0 and no methods', () {
      final predicate = MinMethodsPredicate(0);
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with min = 0 and several methods', () {
      final predicate = MinMethodsPredicate(0);
      final result = predicate.analyze(
        classSubject('Any', methods: [method('x'), method('y')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with min = 1 and one method', () {
      final predicate = MinMethodsPredicate(1);
      final result = predicate.analyze(
        classSubject('Single', methods: [method('run')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with large min satisfied', () {
      final methods = List.generate(10, (i) => method('m$i'));
      final predicate = MinMethodsPredicate(5);
      final result = predicate.analyze(
        classSubject('LargeClass', methods: methods),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
