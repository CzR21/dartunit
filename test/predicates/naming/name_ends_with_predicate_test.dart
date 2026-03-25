import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('NameEndsWithPredicate', () {
    // Valid cases

    test('passes when name ends with the required suffix', () {
      final result = NameEndsWithPredicate('Repository')
          .analyze(classSubject('UserRepository'), emptyCtx());
      expect(result.passed, isTrue);
    });

    test('passes when suffix is Bloc', () {
      final result = NameEndsWithPredicate('Bloc')
          .analyze(classSubject('CartBloc'), emptyCtx());
      expect(result.passed, isTrue);
    });

    test('passes when name equals suffix exactly', () {
      final result = NameEndsWithPredicate('Service')
          .analyze(classSubject('Service'), emptyCtx());
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when name does not end with suffix', () {
      final result = NameEndsWithPredicate('Repository')
          .analyze(classSubject('UserService'), emptyCtx());
      expect(result.passed, isFalse);
    });

    test('fail message includes the expected suffix', () {
      final result = NameEndsWithPredicate('UseCase')
          .analyze(classSubject('GetUser'), emptyCtx());
      expect(result.message, contains('UseCase'));
    });

    test('fails when suffix is partial match at wrong position', () {
      final result = NameEndsWithPredicate('Service')
          .analyze(classSubject('ServiceHelper'), emptyCtx());
      expect(result.passed, isFalse);
    });
  });
}
