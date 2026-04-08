import 'package:test/test.dart';
import 'package:dartunit/dartunit.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('namingFileSuffix preset — invalid cases (NameMatchesPatternPredicate)', () {
    final ctx = emptyCtx();

    test('fails when file ends with wrong suffix (helper instead of service)', () {
      final predicate = NameMatchesPatternPredicate(r'.*_service\.dart$');
      final result = predicate.analyze(fileSubject('user_helper.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when suffix appears in middle of file name', () {
      final predicate = NameMatchesPatternPredicate(r'.*_service\.dart$');
      final result = predicate.analyze(fileSubject('service_wrapper.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails on case mismatch in suffix', () {
      final predicate = NameMatchesPatternPredicate(r'.*_service\.dart$');
      final result = predicate.analyze(fileSubject('user_SERVICE.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when suffix is missing entirely', () {
      final predicate = NameMatchesPatternPredicate(r'.*_service\.dart$');
      final result = predicate.analyze(fileSubject('user.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isFalse);
    });

    test('failure message contains the file name', () {
      final predicate = NameMatchesPatternPredicate(r'.*_service\.dart$');
      final result = predicate.analyze(fileSubject('user_helper.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isFalse);
      expect(result.message, contains('user_helper.dart'));
    });

    test('fails with explicit suffix override when file has wrong name', () {
      final predicate = NameMatchesPatternPredicate(r'.*_service\.dart$');
      final result = predicate.analyze(fileSubject('user_repository.dart', folder: 'lib/services'), ctx);
      expect(result.passed, isFalse);
    });

    test('fails when prefix is present but suffix is missing', () {
      final predicate = NameMatchesPatternPredicate(r'^remote_.*_datasource\.dart$');
      final result = predicate.analyze(fileSubject('remote_user_repository.dart', folder: 'lib/data'), ctx);
      expect(result.passed, isFalse);
    });
  });
}
