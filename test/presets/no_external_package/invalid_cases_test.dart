import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('noExternalPackage preset — invalid cases (NotPredicate + DependOnPackagePredicate)', () {
    final ctx = emptyCtx();

    test('fails when domain class imports forbidden http package', () {
      final predicate = NotPredicate(DependOnPackagePredicate('http'));
      final result = predicate.analyze(
        classSubject('DomainRepo', imports: ['package:http/http.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('http'));
    });

    test('fails when class imports forbidden dio package', () {
      final predicate = NotPredicate(DependOnPackagePredicate('dio'));
      final result = predicate.analyze(
        classSubject('ApiClient', imports: ['package:dio/dio.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message contains package name', () {
      final predicate = NotPredicate(DependOnPackagePredicate('firebase_core'));
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['package:firebase_core/firebase_core.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('firebase_core'));
    });

    test('fails when forbidden package is among multiple imports', () {
      final predicate = NotPredicate(DependOnPackagePredicate('http'));
      final result = predicate.analyze(
        classSubject('Mixed', imports: [
          'lib/domain/user.dart',
          'package:http/http.dart',
        ]),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('fails when deep path from forbidden package is imported', () {
      final predicate = NotPredicate(DependOnPackagePredicate('dio'));
      final result = predicate.analyze(
        classSubject('Client', imports: ['package:dio/src/dio.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
    });

    test('failure message is non-empty with useful content', () {
      final predicate = NotPredicate(DependOnPackagePredicate('bloc'));
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['package:bloc/bloc.dart']),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, isNotEmpty);
    });
  });
}
