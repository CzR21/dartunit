import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('layerCannotDependOn preset — invalid cases (NotPredicate + DependOnFolderPredicate)', () {
    final ctx = emptyCtx();

    test('fails when domain class imports from forbidden data layer', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/data/user_dao.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/data'));
    });

    test('fails when class imports from forbidden UI layer', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/ui'));
      final result = predicate.analyze(
        classSubject('DomainService', imports: ['lib/ui/widget.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains the forbidden folder', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/infrastructure'));
      final result = predicate.analyze(
        classSubject('UseCase', imports: ['lib/infrastructure/database.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/infrastructure'));
    });

    test('fails when one of multiple imports is from forbidden layer', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('Mixed', imports: [
          'lib/domain/user.dart',
          'lib/data/dao.dart', // this one violates
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails for domain depending on data — matches import path', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('WrongDomain', imports: ['lib/data/repo_impl.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message reuses DependOnFolder pass message with folder info', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/data/x.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      // Inner predicate pass message contains class name and folder
      expect(result.message, isNotEmpty);
    });
  });
}
