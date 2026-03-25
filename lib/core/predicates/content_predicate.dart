import 'dart:io';

import '../../analyzer/context/analysis_context.dart';
import '../../analyzer/models/analyzed_file.dart';
import '../entities/subject.dart';
import '../entities/predicate.dart';

/// Passes if the file's raw source content matches [pattern].
///
/// The pattern is compiled once at construction time. The file is read from
/// disk each time the predicate is evaluated against a new subject.
///
/// Designed for use with [FileSelector]. Pair with [NotPredicate] to
/// enforce that a pattern is absent:
/// ```dart
/// NotPredicate(
///   FileContentMatchesPredicate(r'\bprint\s*\(', description: 'uses print()'),
/// )
/// ```
class FileContentMatchesPredicate extends Predicate {
  /// The regular expression pattern to search for in the file content.
  final String pattern;

  /// A short human-readable label for the matched pattern, used to compose
  /// violation messages when wrapped in [NotPredicate].
  /// E.g. `'uses print()'`.
  final String description;

  late final RegExp _regex;

  FileContentMatchesPredicate(this.pattern, {this.description = ''}) {
    _regex = RegExp(pattern);
  }

  @override
  PredicateResult analyze(Subject subject, AnalysisContext context) {
    final file = subject.element as AnalyzedFile;

    String content;
    try {
      content = File(file.filePath).readAsStringSync();
    } catch (_) {
      return PredicateResult.fail(
        'Could not read file: ${file.filePath}',
      );
    }

    if (_regex.hasMatch(content)) {
      final detail = description.isEmpty
          ? '${subject.name} matches pattern "$pattern"'
          : '${subject.name} $description';
      return PredicateResult.pass(detail);
    }

    return PredicateResult.fail(
      '${subject.name} does not match pattern "$pattern"',
    );
  }
}
