import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('layeredArchitecture preset — valid cases', () {
    final ctx = emptyCtx();

    test('domain class with no imports passes OnlyDependOnFolders for domain', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('UserEntity', imports: ['lib/domain/value_object.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('UI class allowed to import from bloc', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/ui', 'lib/bloc', 'lib/domain']);
      final result = predicate.analyze(
        classSubject('LoginPage', imports: ['lib/bloc/user_bloc.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('bloc class allowed to import from domain', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/bloc', 'lib/domain']);
      final result = predicate.analyze(
        classSubject('UserBloc', imports: ['lib/domain/use_cases/fetch_user.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('data class allowed to import from domain interfaces', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/data', 'lib/domain']);
      final result = predicate.analyze(
        classSubject('UserRepoImpl', imports: [
          'lib/domain/user_repo.dart',
          'lib/data/user_dao.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('domain class not depending on data passes NotPredicate', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('UseCase', imports: ['lib/domain/user.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('domain class not depending on UI passes NotPredicate', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/ui'));
      final result = predicate.analyze(
        classSubject('UserEntity'),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
