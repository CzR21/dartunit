import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('UsesMixinPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class uses the required mixin', () {
      final predicate = UsesMixinPredicate('EquatableMixin');
      final result = predicate.analyze(
        classSubject('User', mixinTypes: ['EquatableMixin']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when mixin is among multiple mixins', () {
      final predicate = UsesMixinPredicate('LoggingMixin');
      final result = predicate.analyze(
        classSubject('Service', mixinTypes: ['DisposableMixin', 'LoggingMixin']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class using mixin', () {
      final predicate = UsesMixinPredicate('Comparable');
      final result = predicate.analyze(
        classSubject('AbstractModel', isAbstract: true, mixinTypes: ['Comparable']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when single mixin matches', () {
      final predicate = UsesMixinPredicate('ChangeNotifierMixin');
      final result = predicate.analyze(
        classSubject('ViewModel', mixinTypes: ['ChangeNotifierMixin']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for mixin with exact name match', () {
      final predicate = UsesMixinPredicate('Mixin');
      final result = predicate.analyze(
        classSubject('MyClass', mixinTypes: ['Mixin']),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
