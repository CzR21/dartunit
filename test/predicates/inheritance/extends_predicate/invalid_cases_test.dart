import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ExtendsPredicate — invalid cases', () {
    final ctx = emptyCtx();

    test('fails when class extends nothing', () {
      final predicate = ExtendsPredicate('StatelessWidget');
      final result = predicate.analyze(classSubject('MyClass'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('StatelessWidget'));
    });

    test('fails when class extends a different type', () {
      final predicate = ExtendsPredicate('StatelessWidget');
      final result = predicate.analyze(
        classSubject('MyWidget', extendedType: 'StatefulWidget'),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('StatefulWidget'));
    });

    test('failure message contains class name', () {
      final predicate = ExtendsPredicate('BaseRepo');
      final result = predicate.analyze(
        classSubject('UserService', extendedType: 'BaseService'),
        ctx,
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('UserService'));
    });

    test('failure message mentions required type', () {
      final predicate = ExtendsPredicate('ChangeNotifier');
      final result = predicate.analyze(classSubject('Broken'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('ChangeNotifier'));
    });

    test('fails with "nothing" when extendedType is null', () {
      final predicate = ExtendsPredicate('Base');
      final result = predicate.analyze(classSubject('Child', extendedType: null), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('nothing'));
    });

    test('fails with case mismatch', () {
      final predicate = ExtendsPredicate('StatelessWidget');
      final result = predicate.analyze(
        classSubject('MyWidget', extendedType: 'statelessWidget'),
        ctx,
      );
      expect(result.passed, isFalse);
    });
  });
}
