import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('IsAbstractPredicate', () {
    // Valid cases

    test('passes when class is abstract', () {
      final result = const IsAbstractPredicate().analyze(
        classSubject('AbstractRepository', isAbstract: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract use case base', () {
      final result = const IsAbstractPredicate().analyze(
        classSubject('UseCase', isAbstract: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract widget', () {
      final result = const IsAbstractPredicate().analyze(
        classSubject('BaseScreen', isAbstract: true),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when class is concrete', () {
      final result = const IsAbstractPredicate().analyze(
        classSubject('UserRepositoryImpl', isAbstract: false),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fails when class is an enum', () {
      final result = const IsAbstractPredicate().analyze(
        classSubject('Status', isEnum: true),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message contains class name', () {
      final result = const IsAbstractPredicate().analyze(
        classSubject('ConcreteService'),
        emptyCtx(),
      );
      expect(result.message, contains('ConcreteService'));
      expect(result.message, contains('abstract'));
    });
  });
}
