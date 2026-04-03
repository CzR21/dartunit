import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('layerCannotDependOn preset — valid cases (NotPredicate + DependOnFolderPredicate)', () {
    final ctx = emptyCtx();

    test('passes when domain class has no imports from data layer', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/domain/other.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when class has no imports at all', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/ui'));
      final result = predicate.analyze(classSubject('PureClass'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when domain class imports only from domain', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('UseCase', imports: [
          'lib/domain/user_repo.dart',
          'lib/domain/order_repo.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when imports are from shared, not forbidden layer', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/infrastructure'));
      final result = predicate.analyze(
        classSubject('DomainService', imports: ['lib/shared/utils.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for class without any forbidden layer imports', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/ui'));
      final result = predicate.analyze(
        classSubject('Bloc', imports: ['lib/domain/user.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when multiple imports all avoid the forbidden layer', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('UseCase', imports: [
          'lib/domain/a.dart',
          'lib/shared/b.dart',
          'lib/core/c.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
