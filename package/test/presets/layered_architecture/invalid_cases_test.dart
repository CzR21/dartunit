import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('layeredArchitecture preset — invalid cases', () {
    final ctx = emptyCtx();

    test('domain importing from data layer violates dependency rule', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('UserEntity', imports: ['lib/data/user_dao.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/data'));
    });

    test('domain importing from UI layer violates dependency rule', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/ui'));
      final result = predicate.analyze(
        classSubject('UseCase', imports: ['lib/ui/pages/login.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('data layer class not within its only-allowed layers fails', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/data', 'lib/domain']);
      final result = predicate.analyze(
        classSubject('UserRepoImpl', imports: ['lib/ui/widget.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('bloc importing from data layer (not allowed)', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/bloc', 'lib/domain']);
      final result = predicate.analyze(
        classSubject('UserBloc', imports: ['lib/data/dao.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('UI importing from data layer (skipping bloc/domain)', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/ui', 'lib/bloc', 'lib/domain']);
      final result = predicate.analyze(
        classSubject('LoginPage', imports: ['lib/data/user_dao.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message shows disallowed import path', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('UseCase', imports: ['lib/infrastructure/db.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/infrastructure/db.dart'));
    });
  });
}
