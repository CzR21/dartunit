import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('layerCanOnlyDependOn preset — invalid cases (OnlyDependOnFoldersPredicate)', () {
    final ctx = emptyCtx();

    test('fails when domain class imports from UI layer', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain', 'lib/shared']);
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/ui/widget.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/ui/widget.dart'));
    });

    test('fails when one import is outside allowed layers', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('UseCase', imports: [
          'lib/domain/user.dart',
          'lib/data/dao.dart', // forbidden
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains "disallowed"', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('Violator', imports: ['lib/infrastructure/db.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('disallowed'));
    });

    test('fails for bloc depending on UI layer', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain', 'lib/shared']);
      final result = predicate.analyze(
        classSubject('UserBloc', imports: ['lib/ui/pages/login_page.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message lists allowed folders', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain', 'lib/shared']);
      final result = predicate.analyze(
        classSubject('BadClass', imports: ['lib/data/repo.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/domain'));
    });

    test('fails when all imports are from forbidden layers', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('WrongClass', imports: [
          'lib/data/something.dart',
          'lib/ui/screen.dart',
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
