import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('UsesMixinPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class uses no mixins', () {
      final predicate = UsesMixinPredicate('EquatableMixin');
      final result = predicate.analyze(classSubject('User'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('EquatableMixin'));
    });

    test('fails when class uses different mixins', () {
      final predicate = UsesMixinPredicate('EquatableMixin');
      final result = predicate.analyze(
        classSubject('User', mixinTypes: ['LoggingMixin', 'DisposableMixin']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = UsesMixinPredicate('LoggingMixin');
      final result = predicate.analyze(
        classSubject('SilentService', mixinTypes: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('SilentService'));
    });

    test('failure message contains required mixin name', () {
      final predicate = UsesMixinPredicate('EquatableMixin');
      final result = predicate.analyze(classSubject('Plain'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('mixin EquatableMixin'));
    });

    test('fails when empty mixinTypes list', () {
      final predicate = UsesMixinPredicate('Mixin');
      final result = predicate.analyze(
        classSubject('NoMixins', mixinTypes: []),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails for substring mixin name (not exact match)', () {
      final predicate = UsesMixinPredicate('EquatableMixin');
      final result = predicate.analyze(
        classSubject('Model', mixinTypes: ['Equatable']),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
