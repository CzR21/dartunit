import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsExtensionPredicate — valid cases', () {
    const predicate = IsExtensionPredicate();
    final ctx = emptyCtx();

    test('passes when class is an extension', () {
      final result = predicate.analyze(
        classSubject('StringExt', isExtension: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for extension with typical name', () {
      final result = predicate.analyze(
        classSubject('DateTimeExtension', isExtension: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for extension with annotations', () {
      final result = predicate.analyze(
        classSubject('IntExtension', isExtension: true, annotations: ['deprecated']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with methods defined', () {
      final result = predicate.analyze(
        classSubject('ListExt', isExtension: true, methods: [method('firstOrNull')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes regardless of other flags when isExtension true', () {
      final result = predicate.analyze(
        classSubject('NumExt', isExtension: true, isAbstract: false),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
