import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('IsMixinPredicate — valid cases', () {
    const predicate = IsMixinPredicate();
    final ctx = emptyCtx();

    test('passes when class is a mixin', () {
      final result = predicate.analyze(
        classSubject('LoggingMixin', isMixin: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for mixin with typical name', () {
      final result = predicate.analyze(
        classSubject('DisposableMixin', isMixin: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for mixin with methods', () {
      final result = predicate.analyze(
        classSubject('LoggableMixin', isMixin: true, methods: [method('log')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for mixin with annotations', () {
      final result = predicate.analyze(
        classSubject('EquatableMixin', isMixin: true, annotations: ['deprecated']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes regardless of other flags when isMixin true', () {
      final result = predicate.analyze(
        classSubject('MyMixin', isMixin: true, isAbstract: false),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
