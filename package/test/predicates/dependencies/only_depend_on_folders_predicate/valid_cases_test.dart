import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('OnlyDependOnFoldersPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class has no imports', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(classSubject('PureClass'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when all imports are within allowed folder', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('DomainClass', imports: [
          'lib/domain/user.dart',
          'lib/domain/order.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when imports span multiple allowed folders', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain', 'lib/shared']);
      final result = predicate.analyze(
        classSubject('Service', imports: [
          'lib/domain/user.dart',
          'lib/shared/utils.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when single import is within allowed folder', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/data', 'lib/domain']);
      final result = predicate.analyze(
        classSubject('Repo', imports: ['lib/data/dao.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for empty allowed folders when class has no imports', () {
      final predicate = OnlyDependOnFoldersPredicate([]);
      final result = predicate.analyze(
        classSubject('Isolated', imports: []),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when import path contains allowed folder as substring', () {
      final predicate = OnlyDependOnFoldersPredicate(['lib/domain']);
      final result = predicate.analyze(
        classSubject('Entity', imports: ['lib/domain/entities/user.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
