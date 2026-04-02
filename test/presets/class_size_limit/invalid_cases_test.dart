import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('classSizeLimit preset — invalid cases', () {
    final ctx = emptyCtx();

    test('MaxMethodsPredicate fails when method count exceeds max', () {
      final predicate = MaxMethodsPredicate(5);
      final result = predicate.analyze(
        classSubject('GodClass', methods: List.generate(10, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('10'));
      expect(result.message, contains('5'));
    });

    test('MaxFieldsPredicate fails when field count exceeds max', () {
      final predicate = MaxFieldsPredicate(3);
      final result = predicate.analyze(
        classSubject('BloatedModel', fields: List.generate(8, (i) => finalField('f$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('8'));
    });

    test('MaxMethodsPredicate failure message contains class name', () {
      final predicate = MaxMethodsPredicate(3);
      final result = predicate.analyze(
        classSubject('TooLargeService', methods: List.generate(6, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('TooLargeService'));
    });

    test('MaxFieldsPredicate failure message contains "maximum allowed"', () {
      final predicate = MaxFieldsPredicate(2);
      final result = predicate.analyze(
        classSubject('HugeModel', fields: List.generate(5, (i) => finalField('f$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('maximum allowed'));
    });

    test('MaxMethodsPredicate fails with exactly one over limit', () {
      final predicate = MaxMethodsPredicate(4);
      final result = predicate.analyze(
        classSubject('OverLimit', methods: List.generate(5, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('MaxFieldsPredicate fails with zero max and any fields', () {
      final predicate = MaxFieldsPredicate(0);
      final result = predicate.analyze(
        classSubject('NonEmpty', fields: [finalField('x')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
