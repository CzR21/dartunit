import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('namingFileSuffix preset — valid cases (NameMatchesPatternPredicate)', () {
    final ctx = emptyCtx();

    test('passes when file ends with auto-derived suffix (_services.dart)', () {
      final predicate = NameMatchesPatternPredicate(r'.*_services\.dart$');
      final result = predicate.analyze(fileSubject('user_services.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when file ends with auto-derived suffix (_repository.dart)', () {
      final predicate = NameMatchesPatternPredicate(r'.*_repository\.dart$');
      final result = predicate.analyze(fileSubject('user_repository.dart', folder: 'lib/repository'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when file ends with auto-derived suffix (_bloc.dart)', () {
      final predicate = NameMatchesPatternPredicate(r'.*_bloc\.dart$');
      final result = predicate.analyze(fileSubject('auth_bloc.dart', folder: 'lib/bloc'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with explicit suffix override (_service.dart)', () {
      final predicate = NameMatchesPatternPredicate(r'.*_service\.dart$');
      final result = predicate.analyze(fileSubject('user_service.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with prefix + suffix combination', () {
      final predicate = NameMatchesPatternPredicate(r'^remote_.*_datasource\.dart$');
      final result = predicate.analyze(fileSubject('remote_user_datasource.dart', folder: 'lib/data'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes with raw namePattern override', () {
      final predicate = NameMatchesPatternPredicate(r'.*(bloc|cubit)\.dart$');
      final result = predicate.analyze(fileSubject('auth_cubit.dart', folder: 'lib/bloc'), ctx);
      expect(result.passed, isTrue);
    });

    test('passes when file name equals suffix only', () {
      final predicate = NameMatchesPatternPredicate(r'.*_service\.dart$');
      final result = predicate.analyze(fileSubject('_service.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isTrue);
    });
  });
}
