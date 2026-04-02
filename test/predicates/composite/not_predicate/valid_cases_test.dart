import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('NotPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when inner predicate fails', () {
      // AnnotatedWithPredicate fails → NotPredicate passes
      final predicate = NotPredicate(AnnotatedWithPredicate('injectable'));
      final result = predicate.analyze(classSubject('UserRepo'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when inner NameEndsWith fails', () {
      final predicate = NotPredicate(NameEndsWithPredicate('Service'));
      final result = predicate.analyze(classSubject('UserRepository'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when inner IsAbstractPredicate fails for concrete class', () {
      final predicate = NotPredicate(IsAbstractPredicate());
      final result = predicate.analyze(
        classSubject('ConcreteClass', isAbstract: false),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when inner IsMixinPredicate fails for regular class', () {
      final predicate = NotPredicate(IsMixinPredicate());
      final result = predicate.analyze(classSubject('MyClass'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when wrapped DependOnFolderPredicate fails', () {
      final predicate = NotPredicate(DependOnFolderPredicate('lib/data'));
      final result = predicate.analyze(
        classSubject('DomainClass', imports: ['lib/domain/user.dart']),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when inner AnnotatedWith fails — class has no annotations', () {
      final predicate = NotPredicate(AnnotatedWithPredicate('deprecated'));
      final result = predicate.analyze(
        classSubject('ActiveService', annotations: []),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
