import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('noPublicFields preset — valid cases (HasNoPublicFieldsPredicate)', () {
    const predicate = HasNoPublicFieldsPredicate();
    final ctx = emptyCtx();

    test('passes when class has no fields', () {
      final result = predicate.analyze(classSubject('DomainService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when all fields are private', () {
      final result = predicate.analyze(
        classSubject('UserRepo', fields: [
          AnalyzedField(name: '_db', type: 'Database'),
          AnalyzedField(name: '_cache', type: 'Cache'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when only static fields (excluded)', () {
      final result = predicate.analyze(
        classSubject('Singleton', fields: [staticField('instance')]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for entity with private final fields', () {
      final result = predicate.analyze(
        classSubject('User', fields: [
          AnalyzedField(name: '_id', type: 'String', isFinal: true),
          AnalyzedField(name: '_name', type: 'String', isFinal: true),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes with mix of private and static', () {
      final result = predicate.analyze(
        classSubject('Service', fields: [
          AnalyzedField(name: '_repo', type: 'Repo'),
          staticField('shared'),
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for class with no fields at all', () {
      final result = predicate.analyze(
        classSubject('Calculator', fields: []),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
