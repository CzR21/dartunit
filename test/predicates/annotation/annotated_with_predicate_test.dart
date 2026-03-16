import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AnnotatedWithPredicate', () {
    // Valid cases

    test('passes when class carries the required annotation', () {
      final result = AnnotatedWithPredicate('immutable').evaluate(
        classSubject('UserEntity', annotations: ['immutable']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test(
        'passes when class carries multiple annotations including the required one',
        () {
      final result = AnnotatedWithPredicate('injectable').evaluate(
        classSubject('UserRepo', annotations: ['singleton', 'injectable']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when annotation is the only one', () {
      final result = AnnotatedWithPredicate('override').evaluate(
        classSubject('ConcreteClass', annotations: ['override']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when class has no annotations', () {
      final result = AnnotatedWithPredicate('immutable').evaluate(
        classSubject('UserEntity', annotations: []),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when class has different annotations', () {
      final result = AnnotatedWithPredicate('immutable').evaluate(
        classSubject('UserEntity', annotations: ['injectable', 'singleton']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains the annotation name', () {
      final result = AnnotatedWithPredicate('immutable').evaluate(
        classSubject('MutableEntity'),
        emptyCtx(),
      );
      expect(result.message, contains('@immutable'));
      expect(result.message, contains('MutableEntity'));
    });
  });
}
