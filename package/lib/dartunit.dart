/// dartunit — Architecture testing tool for Dart and Flutter projects.
///
/// This library exposes all public APIs needed to:
/// - Run the CLI (`DartunitCli`)
/// - Implement custom rules (`CustomArchitectureRule`)
/// - Build rules programmatically (`ArchitectureRule`, `RuleEngine`)
/// - Use selectors, predicates, matchers, and presets

library dartunit;

// CLI
export 'cli/dartunit_cli.dart';
export 'cli/commands/init_command.dart';
export 'cli/commands/analyze_command.dart';
export 'cli/commands/generate_command.dart';
export 'cli/commands/log_command.dart';

// Templates
export 'core/enums/arch_template.dart';

// Core — Rule
export 'core/entities/rule.dart';
export 'core/entities/violation.dart';
export 'core/enums/rule_severity.dart';

// Core — Selectors
export 'core/entities/selector.dart' show Selector;
export 'core/entities/subject.dart' show Subject;
export 'core/selectors/class_selector.dart';
export 'core/selectors/file_selector.dart';
export 'core/selectors/layer_selector.dart';

// Core — Predicates
export 'core/entities/predicate.dart';
export 'core/predicates/depend_on_folder_predicate.dart';
export 'core/predicates/depend_on_package_predicate.dart';
export 'core/predicates/only_depend_on_folders_predicate.dart';
export 'core/predicates/max_imports_predicate.dart';
export 'core/predicates/has_circular_dependency_predicate.dart';
export 'core/predicates/name_ends_with_predicate.dart';
export 'core/predicates/name_starts_with_predicate.dart';
export 'core/predicates/name_contains_predicate.dart';
export 'core/predicates/name_matches_pattern_predicate.dart';
export 'core/predicates/annotation_predicate.dart';
export 'core/predicates/not_annotated_with_predicate.dart';
export 'core/predicates/extends_predicate.dart';
export 'core/predicates/implements_predicate.dart';
export 'core/predicates/uses_mixin_predicate.dart';
export 'core/predicates/is_abstract_predicate.dart';
export 'core/predicates/is_enum_predicate.dart';
export 'core/predicates/is_mixin_predicate.dart';
export 'core/predicates/is_extension_predicate.dart';
export 'core/predicates/is_concrete_class_predicate.dart';
export 'core/predicates/max_methods_predicate.dart';
export 'core/predicates/max_fields_predicate.dart';
export 'core/predicates/min_methods_predicate.dart';
export 'core/predicates/min_fields_predicate.dart';
export 'core/predicates/has_all_final_fields_predicate.dart';
export 'core/predicates/has_no_public_fields_predicate.dart';
export 'core/predicates/has_method_predicate.dart';
export 'core/predicates/has_no_public_methods_predicate.dart';
export 'core/predicates/content_predicate.dart';
export 'core/predicates/composite/and_predicate.dart';
export 'core/predicates/composite/or_predicate.dart';
export 'core/predicates/composite/not_predicate.dart';

// Analyzer
export 'analyzer/project_analyzer.dart';
export 'analyzer/context/analysis_context.dart';
export 'analyzer/models/analyzed_class.dart';
export 'analyzer/models/analyzed_file.dart';
export 'analyzer/models/analyzed_method.dart';
export 'analyzer/models/analyzed_field.dart';
export 'analyzer/graph/dependency_graph.dart';

// Engine
export 'engine/rule_engine.dart';
export 'engine/rule_executor.dart';
export 'engine/custom_rule_loader.dart';

// Runner
export 'runner/arch_runner.dart' show testArch, testArchGroup;
export 'runner/arch_tester.dart' show ArchTester, ArchSubject;
export 'runner/arch_matchers.dart';

// Re-export expect so rule files only need to import dartunit
export 'package:test/test.dart' show expect;

// Rule presets
export 'presets/naming_folder_suffix.dart';
export 'presets/naming_file_suffix.dart';
export 'presets/naming_name_pattern.dart';
export 'presets/must_be_abstract.dart';
export 'presets/must_be_immutable.dart';
export 'presets/no_public_fields.dart';
export 'presets/no_circular_dependencies.dart';
export 'presets/layer_cannot_depend_on.dart';
export 'presets/layer_can_only_depend_on.dart';
export 'presets/layered_architecture.dart';
export 'presets/annotation_must_have.dart';
export 'presets/annotation_must_not_have.dart';
export 'presets/class_size_limit.dart';
export 'presets/no_external_package.dart';
export 'presets/no_banned_calls.dart';

// Reporter
export 'reporter/console_reporter.dart';
export 'reporter/html_report_writer.dart';
