import 'package:test/test.dart';

import '../analyzer/project_analyzer.dart';
import '../analyzer/context/analysis_context.dart';
import '../core/entities/rule.dart';
import 'rule_runner.dart';

/// Registers [rule] as a single test compatible with `flutter test` / `dart test`
/// and emits structured data for `dartunit analyze`.
///
/// ```dart
/// void main() => testArch(
///   ArchitectureRule(
///     description: 'UI must not depend on data',
///     severity: RuleSeverity.error,
///     selector: ClassSelector(folder: 'lib/ui'),
///     predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
///   ),
/// );
/// ```
void testArch(ArchitectureRule rule, {String projectRoot = '.'}) {
  test(rule.description, () async {
    final context = await ProjectAnalyzer(projectRoot).analyze();
    runRule(rule, context);
  });
}

/// Registers [rules] as a named test group, analyzing the project **once**
/// for all rules in the group.
///
/// Prefer this over multiple [testArch] calls when rules share the same
/// [projectRoot] — it avoids re-analyzing the project for each rule.
///
/// ```dart
/// void main() {
///   testArchGroup('Domain Layer Isolation', [
///     ArchitectureRule(
///       description: 'Domain must not depend on the data layer',
///       severity: RuleSeverity.error,
///       selector: ClassSelector(folder: 'lib/domain'),
///       predicate: NotPredicate(DependOnFolderPredicate('lib/data')),
///     ),
///     ArchitectureRule(
///       description: 'Domain must be Flutter-agnostic',
///       severity: RuleSeverity.error,
///       selector: ClassSelector(folder: 'lib/domain'),
///       predicate: NotPredicate(DependOnPackagePredicate('flutter')),
///     ),
///   ]);
/// }
/// ```
void testArchGroup(
  String groupName,
  List<ArchitectureRule> rules, {
  String projectRoot = '.',
}) {
  group(groupName, () {
    late AnalysisContext context;

    setUpAll(() async {
      context = await ProjectAnalyzer(projectRoot).analyze();
    });

    for (final rule in rules) {
      test(rule.description, () => runRule(rule, context));
    }
  });
}
