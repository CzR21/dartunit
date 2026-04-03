import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('classSizeLimit preset — valid cases', () {
    final ctx = emptyCtx();

    test('MaxMethodsPredicate passes when count is within limit', () {
      final predicate = MaxMethodsPredicate(10);
      final result = predicate.analyze(
        classSubject('UserService', methods: List.generate(5, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('MaxFieldsPredicate passes when count is within limit', () {
      final predicate = MaxFieldsPredicate(8);
      final result = predicate.analyze(
        classSubject('UserModel', fields: List.generate(4, (i) => finalField('f$i'))),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('MaxMethodsPredicate passes when count equals max', () {
      final predicate = MaxMethodsPredicate(5);
      final result = predicate.analyze(
        classSubject('Exact', methods: List.generate(5, (i) => method('m$i'))),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('MaxFieldsPredicate passes when count equals max', () {
      final predicate = MaxFieldsPredicate(3);
      final result = predicate.analyze(
        classSubject('Small', fields: List.generate(3, (i) => finalField('f$i'))),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('MaxMethodsPredicate passes with no methods', () {
      final predicate = MaxMethodsPredicate(20);
      final result = predicate.analyze(classSubject('Passive'), ctx);
      expect(result.passed, isTrue);
    });

    test('Both predicates pass for class within both limits', () {
      final methodPredicate = MaxMethodsPredicate(10);
      final fieldPredicate = MaxFieldsPredicate(5);
      final cls = classSubject('Balanced',
        methods: List.generate(3, (i) => method('m$i')),
        fields: List.generate(2, (i) => finalField('f$i')),
      );
      expect(methodPredicate.analyze(cls, ctx).passed, isTrue);
      expect(fieldPredicate.analyze(cls, ctx).passed, isTrue);
    });
  });
}
