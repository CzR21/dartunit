import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('NotPredicate', () {
    // ── valid cases (passes = inner predicate fails) ───────────────────────────

    test('passes when inner predicate fails (negation of fails = pass)', () {
      // ExtendsPredicate fails → NotPredicate passes
      final result = NotPredicate(ExtendsPredicate('Bloc')).analyze(
        classSubject('UserEntity'), // does not extend Bloc
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes: domain class does not depend on data layer', () {
      final result =
          NotPredicate(DependOnFolderPredicate('lib/data')).analyze(
        classSubject('UserEntity',
            imports: ['/project/lib/domain/value_object.dart']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when inner AnnotatedWith fails (no annotation present)', () {
      final result = NotPredicate(AnnotatedWithPredicate('deprecated')).analyze(
        classSubject('ActiveService', annotations: []),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // ── fail cases (fails = inner predicate passes) ────────────────────────────

    test('fails when inner predicate passes (negation of pass = fail)', () {
      // ExtendsPredicate passes → NotPredicate fails
      final result = NotPredicate(ExtendsPredicate('Bloc')).analyze(
        classSubject('CartBloc', extendedType: 'Bloc'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails: domain class depends on data layer (forbidden)', () {
      final result =
          NotPredicate(DependOnFolderPredicate('lib/data')).analyze(
        classSubject('DirtyEntity',
            imports: ['/project/lib/data/repo.dart']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message reuses the inner pass message', () {
      final result =
          NotPredicate(DependOnFolderPredicate('lib/data')).analyze(
        classSubject('BadClass',
            imports: ['/project/lib/data/source.dart']),
        emptyCtx(),
      );
      expect(result.message, contains('lib/data'));
    });
  });
}
