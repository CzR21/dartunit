import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('noExternalPackage preset — valid cases (NotPredicate + DependOnPackagePredicate)', () {
    final ctx = emptyCtx();

    test('passes when domain class has no package imports', () {
      final predicate = NotPredicate(DependOnPackagePredicate('http'));
      final result = predicate.analyze(classSubject('DomainClass'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when class imports allowed package, not forbidden', () {
      final predicate = NotPredicate(DependOnPackagePredicate('http'));
      final result = predicate.analyze(
        classSubject('DomainService', imports: ['package:flutter/material.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when class only has internal imports', () {
      final predicate = NotPredicate(DependOnPackagePredicate('dio'));
      final result = predicate.analyze(
        classSubject('UseCase', imports: ['lib/domain/user.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when similar package name but not exact', () {
      final predicate = NotPredicate(DependOnPackagePredicate('http'));
      // http_parser is not http
      final result = predicate.analyze(
        classSubject('Parser', imports: ['package:http_parser/http_parser.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for empty imports list', () {
      final predicate = NotPredicate(DependOnPackagePredicate('firebase_core'));
      final result = predicate.analyze(
        classSubject('DomainEntity', imports: []),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when forbidden package imported via relative path (no package: scheme)', () {
      final predicate = NotPredicate(DependOnPackagePredicate('dio'));
      final result = predicate.analyze(
        classSubject('Client', imports: ['dio/dio.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
