import '../analyzer/context/analysis_context.dart';
import '../core/entities/violation.dart';
import '../core/enums/rule_severity.dart';
import '../core/selectors/class_selector.dart';
import '../core/selectors/file_selector.dart';
import '../core/selectors/layer_selector.dart';
import '../core/entities/selector.dart';
import '../utils/name_pattern_helper.dart';

/// The object passed to [testArch] and [testArchGroup] callbacks.
///
/// Analogous to [WidgetTester] in Flutter tests — it provides factory methods
/// to build [ArchSubject]s (the "finders") that are then passed to [expect].
///
/// ```dart
/// testArch('UI must not depend on data', (arch) {
///   final ui = arch.classes(folder: 'lib/ui');
///   expect(ui, doesNotDependOn('lib/data'));
/// });
/// ```
class ArchTester {

  final AnalysisContext _context;
  final RuleSeverity defaultSeverity;

  /// Collects failures recorded by [ArchMatcher] during this test run.
  /// Checked by [testArch] after [body] completes to call [fail] outside [expect].
  final List<Violation> failures = [];

  ArchTester(this._context, [this.defaultSeverity = RuleSeverity.error]);

  /// Selects classes matching [folder] and/or a name filter.
  ///
  /// Name filtering accepts either a raw [namePattern] (regex) for advanced
  /// use, or the friendlier [prefix]/[suffix] shortcuts — but not both.
  ///
  /// ```dart
  /// arch.classes(suffix: 'Bloc')           // .*Bloc$
  /// arch.classes(prefix: 'Base')           // ^Base.*
  /// arch.classes(prefix: 'I', suffix: 'Repository') // ^I.*Repository$
  /// arch.classes(namePattern: r'.*Bloc$')  // raw regex
  /// ```
  ///
  /// [exceptions] is a list of file path substrings that are exempt from
  /// the rule (e.g. `['lib/ui/legacy/']`).
  ArchSubject classes({
    String? folder,
    String? namePattern,
    String? prefix,
    String? suffix,
    List<String> exceptions = const [],
  }) {
    return ArchSubject(
      selector: ClassSelector(
        folder: folder,
        namePattern: resolveNamePattern(
          namePattern: namePattern,
          prefix: prefix,
          suffix: suffix,
        ),
      ),
      context: _context,
      defaultSeverity: defaultSeverity,
      exceptions: exceptions,
      tester: this,
    );
  }

  /// Selects files matching [folder] and/or a name filter.
  ///
  /// Name filtering accepts either a raw [namePattern] (regex) for advanced
  /// use, or the friendlier [prefix]/[suffix] shortcuts — but not both.
  ///
  /// ```dart
  /// arch.files(suffix: '_test.dart')       // .*_test\.dart$
  /// arch.files(prefix: 'base_')            // ^base_.*
  /// arch.files(namePattern: r'.*_impl\.dart$') // raw regex
  /// ```
  ///
  /// [exceptions] is a list of folder path substrings to exclude.
  ArchSubject files({
    String? folder,
    String? namePattern,
    String? prefix,
    String? suffix,
    List<String> exceptions = const [],
  }) {
    return ArchSubject(
      selector: FileSelector(
        folder: folder,
        namePattern: resolveNamePattern(
          namePattern: namePattern,
          prefix: prefix,
          suffix: suffix,
        ),
        excludeFolders: exceptions,
      ),
      context: _context,
      defaultSeverity: defaultSeverity,
      exceptions: exceptions,
      tester: this,
    );
  }

  /// Selects all classes belonging to a named architectural layer.
  ///
  /// [name] is a human-readable label; [folder] drives the actual selection.
  /// [exceptions] is a list of file path substrings to exempt.
  ArchSubject layer(
    String name, {
    required String folder,
    List<String> exceptions = const [],
  }) {
    return ArchSubject(
      selector: LayerSelector(layerName: name, layerFolder: folder),
      context: _context,
      defaultSeverity: defaultSeverity,
      exceptions: exceptions,
      tester: this,
    );
  }
}

/// The "finder" object passed to [expect] in architecture tests.
///
/// Carries the [selector], the loaded [context], the [defaultSeverity]
/// inherited from [testArch] or [testArchGroup], and the [exceptions] list.
/// Arch matchers receive this object and use it to analyze the rule.
class ArchSubject {
  final Selector selector;
  final AnalysisContext context;
  final RuleSeverity defaultSeverity;
  final List<String> exceptions;
  final ArchTester tester;

  const ArchSubject({
    required this.selector,
    required this.context,
    required this.defaultSeverity,
    required this.tester,
    this.exceptions = const [],
  });
}
