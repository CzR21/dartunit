import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('DependOnFolderPredicate', () {
    // Valid cases

    test('passes when imports contain the target folder path', () {
      final result = DependOnFolderPredicate('lib/data').evaluate(
        classSubject('UserBloc',
            imports: ['/project/lib/data/user_repository.dart']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when one of multiple imports matches the folder', () {
      final result = DependOnFolderPredicate('lib/domain').evaluate(
        classSubject('DataRepo', imports: [
          '/project/lib/data/datasource.dart',
          '/project/lib/domain/user.dart',
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes message includes folder and matching imports', () {
      final result = DependOnFolderPredicate('lib/data').evaluate(
        classSubject('Bloc', imports: ['/project/lib/data/repo.dart']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
      expect(result.message, contains('lib/data'));
    });

    // Fail cases

    test('fails when no imports match the folder', () {
      final result = DependOnFolderPredicate('lib/data').evaluate(
        classSubject('UserBloc', imports: ['/project/lib/domain/user.dart']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when imports list is empty', () {
      final result = DependOnFolderPredicate('lib/data').evaluate(
        classSubject('UserBloc'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains the folder name', () {
      final result = DependOnFolderPredicate('lib/ui').evaluate(
        classSubject('DomainClass',
            imports: ['/project/lib/domain/entity.dart']),
        emptyCtx(),
      );
      expect(result.message, contains('lib/ui'));
    });
  });
}
