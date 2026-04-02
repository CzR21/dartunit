import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasNoPublicFieldsPredicate — valid cases', () {
    const predicate = HasNoPublicFieldsPredicate();
    final ctx = emptyCtx();

    test('passes when class has no fields', () {
      final result = predicate.analyze(classSubject('Empty'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when all fields are private (start with _)', () {
      final result = predicate.analyze(
        classSubject('PrivateModel', fields: [
          AnalyzedField(name: '_name', type: 'String'),
          AnalyzedField(name: '_email', type: 'String'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when only static fields are present', () {
      final result = predicate.analyze(
        classSubject('Config', fields: [staticField('instance')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when public field is static (static excluded)', () {
      final result = predicate.analyze(
        classSubject('Registry', fields: [
          AnalyzedField(name: 'shared', type: 'Registry', isStatic: true),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with mix of private and static fields', () {
      final result = predicate.analyze(
        classSubject('Service', fields: [
          AnalyzedField(name: '_repo', type: 'Repo'),
          AnalyzedField(name: '_cache', type: 'Cache'),
          staticField('instance'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with single private field', () {
      final result = predicate.analyze(
        classSubject('Wrapper', fields: [AnalyzedField(name: '_value', type: 'int')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
