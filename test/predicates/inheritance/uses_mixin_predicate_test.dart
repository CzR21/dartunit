import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('UsesMixinPredicate', () {
    // Valid cases

    test('passes when class uses the required mixin', () {
      final result = UsesMixinPredicate('EquatableMixin').analyze(
        classSubject('UserState', mixinTypes: ['EquatableMixin']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when class uses multiple mixins including the required', () {
      final result = UsesMixinPredicate('Serializable').analyze(
        classSubject('UserDto', mixinTypes: ['Comparable', 'Serializable']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes with a single mixin', () {
      final result = UsesMixinPredicate('Logging').analyze(
        classSubject('CartService', mixinTypes: ['Logging']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when class uses no mixins', () {
      final result = UsesMixinPredicate('EquatableMixin').analyze(
        classSubject('UserState', mixinTypes: []),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when class uses different mixins', () {
      final result = UsesMixinPredicate('Logging').analyze(
        classSubject('Service', mixinTypes: ['Caching', 'Retry']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains mixin name and class name', () {
      final result = UsesMixinPredicate('ChangeNotifier').analyze(
        classSubject('CounterViewModel', mixinTypes: []),
        emptyCtx(),
      );
      expect(result.message, contains('ChangeNotifier'));
      expect(result.message, contains('CounterViewModel'));
    });
  });
}
