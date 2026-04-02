import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsEnumPredicate — valid cases', () {
    const predicate = IsEnumPredicate();
    final ctx = emptyCtx();

    test('passes when class is an enum', () {
      final result = predicate.analyze(
        classSubject('Status', isEnum: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for enum with name ending in typical suffix', () {
      final result = predicate.analyze(
        classSubject('UserStatus', isEnum: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for enum with annotations', () {
      final result = predicate.analyze(
        classSubject('Color', isEnum: true, annotations: ['deprecated']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for enum in lib/core path', () {
      final result = predicate.analyze(
        classSubject('Priority', isEnum: true, filePath: 'lib/core/priority.dart'),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes regardless of other flags when isEnum is true', () {
      final result = predicate.analyze(
        classSubject('Direction', isEnum: true, isAbstract: false),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
