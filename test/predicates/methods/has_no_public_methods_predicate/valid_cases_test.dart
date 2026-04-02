import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasNoPublicMethodsPredicate — valid cases', () {
    const predicate = HasNoPublicMethodsPredicate();
    final ctx = emptyCtx();

    test('passes when class has no methods', () {
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when all methods are private', () {
      final result = predicate.analyze(
        classSubject('Internal', methods: [method('_doWork'), method('_validate')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with single private method', () {
      final result = predicate.analyze(
        classSubject('Helper', methods: [method('_compute')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when multiple private methods present', () {
      final result = predicate.analyze(
        classSubject('Utility', methods: [
          method('_step1'),
          method('_step2'),
          method('_step3'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for method starting with double underscore', () {
      final result = predicate.analyze(
        classSubject('Special', methods: [method('__init')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with empty methods list', () {
      final result = predicate.analyze(
        classSubject('Bare', methods: []),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
