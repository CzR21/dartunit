import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('namingClassSuffix preset — valid cases (NameEndsWithPredicate)', () {
    final ctx = emptyCtx();

    test('passes when service class ends with "Service"', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('UserService'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when repository class ends with "Repository"', () {
      final predicate = NameEndsWithPredicate('Repository');
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when bloc class ends with "Bloc"', () {
      final predicate = NameEndsWithPredicate('Bloc');
      final result = predicate.analyze(classSubject('AuthBloc'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when widget class ends with "Widget"', () {
      final predicate = NameEndsWithPredicate('Widget');
      final result = predicate.analyze(classSubject('UserCardWidget'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when suffix equals the class name', () {
      final predicate = NameEndsWithPredicate('Service');
      final result = predicate.analyze(classSubject('Service'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when abstract class ends with required suffix', () {
      final predicate = NameEndsWithPredicate('Repository');
      final result = predicate.analyze(
        classSubject('AbstractRepository', isAbstract: true),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
