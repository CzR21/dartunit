import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('OnlyDependOnFoldersPredicate', () {
    // Valid cases

    test('passes when all imports are from allowed folders', () {
      final result =
          OnlyDependOnFoldersPredicate(['lib/domain', 'lib/shared']).analyze(
        classSubject('PresentationClass', imports: [
          '/project/lib/domain/user.dart',
          '/project/lib/shared/utils.dart',
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when there are no imports', () {
      final result = OnlyDependOnFoldersPredicate(['lib/domain']).analyze(
        classSubject('PureEntity'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when all imports are from a single allowed folder', () {
      final result = OnlyDependOnFoldersPredicate(['lib/domain']).analyze(
        classSubject('UseCase', imports: [
          '/project/lib/domain/user.dart',
          '/project/lib/domain/order.dart',
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when an import comes from a forbidden folder', () {
      final result = OnlyDependOnFoldersPredicate(['lib/domain']).analyze(
        classSubject('DirtyDomain', imports: [
          '/project/lib/domain/user.dart',
          '/project/lib/data/repo.dart',
        ]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message lists the forbidden import', () {
      final result = OnlyDependOnFoldersPredicate(['lib/domain']).analyze(
        classSubject('Cls', imports: ['/project/lib/ui/page.dart']),
        emptyCtx(),
      );
      expect(result.message, contains('lib/ui/page.dart'));
    });

    test('fails when none of the imports are from allowed folders', () {
      final result = OnlyDependOnFoldersPredicate(['lib/domain']).analyze(
        classSubject('MixedDeps', imports: [
          '/project/lib/data/a.dart',
          '/project/lib/ui/b.dart',
        ]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });
  });
}
