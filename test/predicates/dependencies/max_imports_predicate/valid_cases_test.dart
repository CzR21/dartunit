import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MaxImportsPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class has no imports (0 <= max)', () {
      final predicate = MaxImportsPredicate(5);
      final result = predicate.analyze(classSubject('PureClass'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when import count equals max', () {
      final predicate = MaxImportsPredicate(3);
      final result = predicate.analyze(
        classSubject('MyClass', imports: ['a.dart', 'b.dart', 'c.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when import count is below max', () {
      final predicate = MaxImportsPredicate(10);
      final result = predicate.analyze(
        classSubject('SmallClass', imports: ['a.dart', 'b.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with max of 0 when no imports', () {
      final predicate = MaxImportsPredicate(0);
      final result = predicate.analyze(
        classSubject('ZeroImports', imports: []),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when import count is exactly 1 and max is 1', () {
      final predicate = MaxImportsPredicate(1);
      final result = predicate.analyze(
        classSubject('MinimalClass', imports: ['dart:core']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with large max value and many imports', () {
      final imports = List.generate(20, (i) => 'lib/file_$i.dart');
      final predicate = MaxImportsPredicate(100);
      final result = predicate.analyze(
        classSubject('BigClass', imports: imports),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
