import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('layerCanOnlyDependOn preset — valid cases (OnlyDependOnFoldersPredicate)', () {
    final ctx = emptyCtx();

    test('passes when class has no imports', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain', 'lib/shared']);
      final result = predicate.analyze(classSubject('DomainClass'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when all imports are within allowed layers', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain', 'lib/shared']);
      final result = predicate.analyze(
        classSubject('UseCase', imports: [
          'lib/domain/user.dart',
          'lib/shared/utils.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when single import is in allowed layer', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('Bloc', imports: ['lib/domain/user_repo.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for domain layer with no dependencies (pure)', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('UserEntity', imports: ['lib/domain/value_object.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when imports match multiple allowed layers', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/data', 'lib/domain', 'lib/shared']);
      final result = predicate.analyze(
        classSubject('Repository', imports: [
          'lib/data/dao.dart',
          'lib/domain/entity.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with self-referencing import from same layer', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/bloc']);
      final result = predicate.analyze(
        classSubject('UserBloc', imports: ['lib/bloc/user_state.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
