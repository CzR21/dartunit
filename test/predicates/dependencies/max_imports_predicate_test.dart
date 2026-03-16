import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('MaxImportsPredicate', () {
    // Valid cases

    test('passes when import count is below the limit', () {
      final result = MaxImportsPredicate(5).evaluate(
        classSubject('Service', imports: ['lib/a.dart', 'lib/b.dart']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when import count equals the limit exactly', () {
      final result = MaxImportsPredicate(2).evaluate(
        classSubject('TwoImports', imports: ['lib/a.dart', 'lib/b.dart']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when there are no imports', () {
      final result = MaxImportsPredicate(10).evaluate(
        classSubject('StandaloneClass'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when import count exceeds the limit', () {
      final result = MaxImportsPredicate(2).evaluate(
        classSubject('HighlyCoupled', imports: [
          'lib/a.dart',
          'lib/b.dart',
          'lib/c.dart',
        ]),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message includes actual count and limit', () {
      final result = MaxImportsPredicate(1).evaluate(
        classSubject('Cls', imports: ['lib/a.dart', 'lib/b.dart']),
        emptyCtx(),
      );
      expect(result.message, contains('2'));
      expect(result.message, contains('1'));
    });

    test('fails with limit 0 when any import exists', () {
      final result = MaxImportsPredicate(0).evaluate(
        classSubject('Cls', imports: ['lib/a.dart']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });
  });
}
