import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('OnlyDependOnFoldersPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when import is outside all allowed folders', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/data/user_dao.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/data/user_dao.dart'));
    });

    test('fails when one of multiple imports is in a forbidden folder', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('MixedClass', imports: [
          'lib/domain/user.dart',
          'lib/data/dao.dart',
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/data/dao.dart'));
    });

    test('failure message contains class name', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('BadDomain', imports: ['lib/ui/widget.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('BadDomain'));
    });

    test('failure message contains "disallowed locations"', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('BadClass', imports: ['lib/data/repo.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('disallowed'));
    });

    test('fails when empty allowed folders and class has imports', () {
      final predicate = OnlyDependOnFoldersPredicate([]);
      final result = predicate.analyze(
        classSubject('Strict', imports: ['lib/domain/user.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains allowed folders list', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain', 'lib/shared']);
      final result = predicate.analyze(
        classSubject('CheatClass', imports: ['lib/data/dao.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/domain'));
      expect(result.message, contains('lib/shared'));
    });
  });
}
