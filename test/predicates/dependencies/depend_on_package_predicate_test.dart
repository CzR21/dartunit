import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('DependOnPackagePredicate', () {
    // Valid cases

    test('passes when import matches the package prefix', () {
      final result = DependOnPackagePredicate('http').evaluate(
        classSubject('ApiClient', imports: ['package:http/http.dart']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when one of multiple imports is the package', () {
      final result = DependOnPackagePredicate('dio').evaluate(
        classSubject('DataSource', imports: [
          'package:flutter/material.dart',
          'package:dio/dio.dart',
        ]),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when sub-path of package is imported', () {
      final result = DependOnPackagePredicate('bloc').evaluate(
        classSubject('CartBloc', imports: ['package:bloc/bloc.dart']),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when no import matches the package', () {
      final result = DependOnPackagePredicate('http').evaluate(
        classSubject('DomainEntity',
            imports: ['package:equatable/equatable.dart']),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when imports are empty', () {
      final result = DependOnPackagePredicate('dio').evaluate(
        classSubject('PureEntity'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains the package name', () {
      final result = DependOnPackagePredicate('http').evaluate(
        classSubject('Repository'),
        emptyCtx(),
      );
      expect(result.message, contains('"http"'));
    });
  });
}
