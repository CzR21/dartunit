import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ExtendsPredicate', () {
    // Valid cases

    test('passes when class extends the required type', () {
      final result = ExtendsPredicate('Equatable').analyze(
        classSubject('UserEntity', extendedType: 'Equatable'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when BLoC class extends Bloc', () {
      final result = ExtendsPredicate('Bloc').analyze(
        classSubject('CartBloc', extendedType: 'Bloc'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    test('passes when class extends a generic base', () {
      final result = ExtendsPredicate('StatelessWidget').analyze(
        classSubject('HomePage', extendedType: 'StatelessWidget'),
        emptyCtx(),
      );
      expect(result.passed, isTrue);
    });

    // Fail cases

    test('fails when class extends a different type', () {
      final result = ExtendsPredicate('Equatable').analyze(
        classSubject('UserEntity', extendedType: 'BaseModel'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
    });

    test('fail message includes both expected and actual type', () {
      final result = ExtendsPredicate('Equatable').analyze(
        classSubject('UserEntity', extendedType: 'BaseModel'),
        emptyCtx(),
      );
      expect(result.message, contains('Equatable'));
      expect(result.message, contains('BaseModel'));
    });

    test('fails when class extends nothing — message says "nothing"', () {
      final result = ExtendsPredicate('Equatable').analyze(
        classSubject('StandaloneClass'),
        emptyCtx(),
      );
      expect(result.passed, isFalse);
      expect(result.message, contains('nothing'));
    });
  });
}
