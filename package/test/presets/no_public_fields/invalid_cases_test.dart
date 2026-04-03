import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('noPublicFields preset — invalid cases (HasNoPublicFieldsPredicate)', () {
    const predicate = HasNoPublicFieldsPredicate();
    final ctx = emptyCtx();

    test('fails when domain class exposes public field', () {
      final result = predicate.analyze(
        classSubject('UserEntity', fields: [
          AnalyzedField(name: 'id', type: 'String'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('id'));
    });

    test('fails when public field is among private ones', () {
      final result = predicate.analyze(
        classSubject('Service', fields: [
          AnalyzedField(name: '_repo', type: 'Repo'),
          AnalyzedField(name: 'config', type: 'Config'), // public violation
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('config'));
    });

    test('failure message contains class name', () {
      final result = predicate.analyze(
        classSubject('BadModel', fields: [
          AnalyzedField(name: 'data', type: 'dynamic'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('BadModel'));
    });

    test('failure message contains "public instance fields"', () {
      final result = predicate.analyze(
        classSubject('Exposed', fields: [AnalyzedField(name: 'value', type: 'int')]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('public instance fields'));
    });

    test('fails for public final field (final != private)', () {
      final result = predicate.analyze(
        classSubject('PublicFinal', fields: [finalField('name')]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when multiple public fields exposed', () {
      final result = predicate.analyze(
        classSubject('AllPublic', fields: [
          AnalyzedField(name: 'x', type: 'int'),
          AnalyzedField(name: 'y', type: 'int'),
          AnalyzedField(name: 'z', type: 'int'),
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('x'));
      expect(result.message, contains('y'));
    });
  });
}
