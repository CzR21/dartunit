import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('DependOnPackagePredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class has no imports', () {
      final predicate = DependOnPackagePredicate('flutter');
      final result = predicate.analyze(classSubject('PureClass'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('flutter'));
    });

    test('fails when imports are from different packages', () {
      final predicate = DependOnPackagePredicate('dio');
      final result = predicate.analyze(
        classSubject('ApiClient', imports: ['package:http/http.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when package name is a prefix of another package', () {
      final predicate = DependOnPackagePredicate('http');
      final result = predicate.analyze(
        classSubject('Client', imports: ['package:http_parser/http_parser.dart']),
        ctx,
      );
      // 'package:http_parser/' does NOT start with 'package:http/'
      expect(result.passed, isFalse);
    });

    test('failure message contains class name', () {
      final predicate = DependOnPackagePredicate('firebase_core');
      final result = predicate.analyze(
        classSubject('MyClass', imports: ['lib/domain/entity.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('MyClass'));
    });

    test('fails when import is a relative path (not package:)', () {
      final predicate = DependOnPackagePredicate('flutter');
      final result = predicate.analyze(
        classSubject('Widget', imports: ['flutter/material.dart']),
        ctx,
      );
      // Relative path without 'package:' prefix doesn't match
      expect(result.passed, isFalse);
    });

    test('fails with empty imports list and informative message', () {
      final predicate = DependOnPackagePredicate('bloc');
      final result = predicate.analyze(
        classSubject('NoDepsClass', imports: []),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('does not import from package'));
    });
  });
}
