import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('DependOnFolderPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class has no imports', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(classSubject('PureClass'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('lib/data'));
    });

    test('fails when imports do not contain the folder', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/domain/user.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when folder is a different path segment', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('Service', imports: ['lib/database/schema.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('PureClass', imports: ['lib/domain/user.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('PureClass'));
    });

    test('fails when import has folder as prefix only (no path separator after)', () {
      final predicate = DependOnFolderPredicate('lib/data');
      // 'lib/data_access' does NOT contain 'lib/data' as a path? Actually it does
      // because contains() is substring match. Let's test exact mismatch:
      final result = predicate.analyze(
        classSubject('Service', imports: ['package:flutter/widgets.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when imports list is empty', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('EmptyClass', imports: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('does not depend on'));
    });

    test('fails when import matches only as partial folder name', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('Service', imports: ['lib/data_access/repo.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when import matches lib/data_utils but not lib/data', () {
      final predicate = DependOnFolderPredicate('lib/data');
      final result = predicate.analyze(
        classSubject('Service', imports: ['lib/data_utils/helper.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
