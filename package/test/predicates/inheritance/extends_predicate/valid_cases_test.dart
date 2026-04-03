import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ExtendsPredicate — valid cases', () {
    final ctx = emptyCtx();

    test('passes when class extends the required type', () {
      final predicate = ExtendsPredicate('StatelessWidget');
      final result = predicate.analyze(
        classSubject('MyWidget', extendedType: 'StatelessWidget'),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for extending a custom base class', () {
      final predicate = ExtendsPredicate('BaseRepository');
      final result = predicate.analyze(
        classSubject('UserRepository', extendedType: 'BaseRepository'),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for extending a generic base class name', () {
      final predicate = ExtendsPredicate('ChangeNotifier');
      final result = predicate.analyze(
        classSubject('UserModel', extendedType: 'ChangeNotifier'),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes for abstract class extending base', () {
      final predicate = ExtendsPredicate('AbstractMapper');
      final result = predicate.analyze(
        classSubject('UserMapper', isAbstract: true, extendedType: 'AbstractMapper'),
        ctx,
      );
      expect(result.passed, isTrue);
    });

    test('passes when extended type matches exactly', () {
      final predicate = ExtendsPredicate('ValueNotifier');
      final result = predicate.analyze(
        classSubject('CountNotifier', extendedType: 'ValueNotifier'),
        ctx,
      );
      expect(result.passed, isTrue);
    });
  });
}
