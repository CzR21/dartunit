import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('DependOnPackagePredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class imports from the given package', () {
      final predicate = DependOnPackagePredicate('flutter');
      final result = predicate.analyze(
        classSubject('MyWidget', imports: ['package:flutter/material.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when one of multiple imports matches the package', () {
      final predicate = DependOnPackagePredicate('get_it');
      final result = predicate.analyze(
        classSubject('ServiceLocator', imports: [
          'package:flutter/material.dart',
          'package:get_it/get_it.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for deep package path import', () {
      final predicate = DependOnPackagePredicate('dio');
      final result = predicate.analyze(
        classSubject('ApiClient', imports: ['package:dio/src/dio.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('pass message contains package name', () {
      final predicate = DependOnPackagePredicate('http');
      final result = predicate.analyze(
        classSubject('HttpClient', imports: ['package:http/http.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
      expect(result.message, contains('http'));
    });

    test('passes for package with underscore in name', () {
      final predicate = DependOnPackagePredicate('shared_preferences');
      final result = predicate.analyze(
        classSubject('PrefService', imports: [
          'package:shared_preferences/shared_preferences.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when multiple imports from same package present', () {
      final predicate = DependOnPackagePredicate('rxdart');
      final result = predicate.analyze(
        classSubject('Stream', imports: [
          'package:rxdart/rxdart.dart',
          'package:rxdart/subjects.dart',
        ]),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
