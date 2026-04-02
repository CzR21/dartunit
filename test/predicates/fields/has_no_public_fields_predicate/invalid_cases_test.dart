import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HasNoPublicFieldsPredicate — invalid cases', () {
    const predicate = HasNoPublicFieldsPredicate();
    final ctx = emptyCtx();

    test('fails when class has a public instance field', () {
      final result = predicate.analyze(
        classSubject('BadModel', fields: [
          AnalyzedField(name: 'name', type: 'String'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('name'));
    });

    test('fails when one of multiple fields is public', () {
      final result = predicate.analyze(
        classSubject('Mixed', fields: [
          AnalyzedField(name: '_private', type: 'String'),
          AnalyzedField(name: 'publicField', type: 'int'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('publicField'));
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(
        classSubject('ExposedClass', fields: [
          AnalyzedField(name: 'value', type: 'int'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('ExposedClass'));
    });

    test('failure message contains "public instance fields"', () {
      final result = predicate.analyze(
        classSubject('Leaky', fields: [AnalyzedField(name: 'data', type: 'dynamic')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('public instance fields'));
    });

    test('fails when multiple public fields listed', () {
      final result = predicate.analyze(
        classSubject('AllPublic', fields: [
          AnalyzedField(name: 'x', type: 'int'),
          AnalyzedField(name: 'y', type: 'int'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('x'));
      expect(result.message, contains('y'));
    });

    test('fails when public final field is present (final does not make it private)', () {
      final result = predicate.analyze(
        classSubject('FinalPublic', fields: [finalField('name')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('name'));
    });
  });
}
